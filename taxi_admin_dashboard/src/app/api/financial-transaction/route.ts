import { z } from 'zod';
import { NextRequest, NextResponse } from 'next/server';
import { FieldValue } from 'firebase-admin/firestore';
import { adminDb, adminMessaging } from '@/lib/firebase-admin';
import { verifyAdmin } from '@/lib/verify-admin';
import { rateLimit } from '@/lib/rate-limit';
import { auditLog } from '@/lib/audit-log';

// ═══════════════════════════════════════════
// Zod Schema
// ═══════════════════════════════════════════
const transactionSchema = z.object({
  type: z.enum(['payment', 'charge']),
  driverId: z.string().min(1).max(128),
  amount: z.number().positive('المبلغ يجب أن يكون أكبر من صفر').max(1_000_000),
  note: z.string().max(500).optional().default(''),
  idempotencyKey: z.string().min(8).max(64, 'مفتاح التكرار غير صالح'),
});

export async function POST(request: NextRequest) {
  // ═══════════════════════════════════════════
  // 1. التحقق من جلسة الأدمن
  // ═══════════════════════════════════════════
  const admin = await verifyAdmin(request);
  if (!admin) {
    return NextResponse.json({ error: 'غير مصرّح' }, { status: 401 });
  }

  // ═══════════════════════════════════════════
  // 2. Rate Limiting — 5 عمليات مالية / دقيقة
  // ═══════════════════════════════════════════
  if (!rateLimit(`fin:${admin.uid}`, 5, 60_000)) {
    return NextResponse.json({ error: 'طلبات كثيرة. حاول بعد دقيقة.' }, { status: 429 });
  }

  // ═══════════════════════════════════════════
  // 3. تحقق المدخلات
  // ═══════════════════════════════════════════
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'بيانات غير صالحة' }, { status: 400 });
  }

  const parsed = transactionSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: 'مدخلات غير صالحة', fields: parsed.error.flatten().fieldErrors },
      { status: 400 }
    );
  }

  const { type, driverId, amount, note, idempotencyKey } = parsed.data;

  try {
    // ═══════════════════════════════════════════
    // 4. Idempotency Check — منع تكرار العملية
    // ═══════════════════════════════════════════
    const idempotencyRef = adminDb.collection('idempotency_keys').doc(idempotencyKey);
    const idempotencyDoc = await idempotencyRef.get();
    if (idempotencyDoc.exists) {
      return NextResponse.json(
        { error: 'تم تنفيذ هذه العملية مسبقاً', transactionId: idempotencyDoc.data()?.transactionId },
        { status: 409 }
      );
    }

    // ═══════════════════════════════════════════
    // 5. التحقق من وجود السائق
    // ═══════════════════════════════════════════
    const driverRef = adminDb.collection('drivers').doc(driverId);
    const driverDoc = await driverRef.get();
    if (!driverDoc.exists) {
      return NextResponse.json({ error: 'السائق غير موجود' }, { status: 404 });
    }

    const driverData = driverDoc.data()!;
    const driverName = driverData.name || '';

    // ═══════════════════════════════════════════
    // 6. Firestore Transaction — عملية ذرية
    // ═══════════════════════════════════════════
    let transactionId = '';

    await adminDb.runTransaction(async (tx) => {
      // إعادة قراءة السائق داخل الـ transaction
      const freshDriver = await tx.get(driverRef);
      if (!freshDriver.exists) throw new Error('السائق غير موجود');

      // إنشاء المعاملة
      const txRef = adminDb.collection('transactions').doc();
      transactionId = txRef.id;

      const defaultNote = type === 'payment'
        ? `سداد عمولات — ${amount.toFixed(0)} ريال`
        : `إضافة رسوم — ${amount.toFixed(0)} ريال`;

      tx.create(txRef, {
        driverId,
        driverName,
        type,
        amount,
        rideId: null,
        rideFare: 0,
        note: note || defaultNote,
        createdAt: FieldValue.serverTimestamp(),
        createdBy: admin.email,
        adminUid: admin.uid,
      });

      // تحديث رصيد السائق ذرياً
      if (type === 'payment') {
        tx.update(driverRef, {
          totalCommissionOwed: FieldValue.increment(-amount),
          totalPaid: FieldValue.increment(amount),
        });
      } else {
        tx.update(driverRef, {
          totalCommissionOwed: FieldValue.increment(amount),
        });
      }

      // تسجيل مفتاح التكرار
      tx.create(idempotencyRef, {
        transactionId: txRef.id,
        adminUid: admin.uid,
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    // ═══════════════════════════════════════════
    // 7. إشعار السائق (خارج الـ transaction)
    // ═══════════════════════════════════════════
    if (type === 'payment') {
      // حفظ إشعار في Firestore
      await adminDb.collection('notifications').add({
        title: '✅ تم تسجيل سداد',
        body: `تم تسجيل سداد ${amount.toFixed(0)} ريال من عمولاتك. شكراً لك!`,
        target: 'specific_driver',
        targetId: driverId,
        targetName: driverName,
        sentAt: FieldValue.serverTimestamp(),
        sentBy: admin.email,
      });

      // FCM
      if (driverData.fcmToken) {
        try {
          await adminMessaging.send({
            token: driverData.fcmToken,
            notification: {
              title: '✅ تم تسجيل سداد',
              body: `تم تسجيل سداد ${amount.toFixed(0)} ريال من عمولاتك. شكراً لك!`,
            },
            android: { priority: 'high', notification: { sound: 'default', channelId: 'ride_channel' } },
          });
        } catch (fcmErr: unknown) {
          // Token منتهي — حذفه
          const errCode = (fcmErr as { code?: string })?.code;
          if (
            errCode === 'messaging/invalid-registration-token' ||
            errCode === 'messaging/registration-token-not-registered'
          ) {
            await driverRef.update({ fcmToken: null });
          }
        }
      }
    }

    // ═══════════════════════════════════════════
    // 8. Audit Log
    // ═══════════════════════════════════════════
    await auditLog({
      action: type === 'payment' ? 'record_payment' : 'record_charge',
      adminUid: admin.uid,
      adminEmail: admin.email,
      targetCollection: 'drivers',
      targetId: driverId,
      details: {
        transactionId,
        amount,
        driverName,
        note: note || '',
        idempotencyKey,
      },
    });

    return NextResponse.json({ success: true, transactionId });
  } catch (error) {
    console.error('Financial transaction error:', error);
    return NextResponse.json({ error: 'فشل تنفيذ العملية' }, { status: 500 });
  }
}
