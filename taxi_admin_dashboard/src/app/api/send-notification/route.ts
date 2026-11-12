import { z } from 'zod';
import { NextRequest, NextResponse } from 'next/server';
import { adminDb, adminMessaging } from '@/lib/firebase-admin';
import { verifyAdmin } from '@/lib/verify-admin';
import { rateLimit } from '@/lib/rate-limit';
import { auditLog } from '@/lib/audit-log';

// ═══════════════════════════════════════════
// Zod Schema — تحقق صارم من المدخلات
// ═══════════════════════════════════════════
const VALID_TARGETS = ['all_users', 'all_drivers', 'specific_user', 'specific_driver'] as const;

const sendNotificationSchema = z.object({
  title: z.string().min(1, 'العنوان مطلوب').max(200),
  body: z.string().min(1, 'المحتوى مطلوب').max(1000),
  target: z.enum(VALID_TARGETS),
  targetId: z.string().min(1).max(128).nullable().optional(),
}).refine(
  (data) => {
    // targetId مطلوب عند الإرسال لمستخدم محدد
    if (data.target === 'specific_user' || data.target === 'specific_driver') {
      return !!data.targetId;
    }
    return true;
  },
  { message: 'targetId مطلوب عند الإرسال لمستخدم محدد' }
);

export async function POST(request: NextRequest) {
  // ═══════════════════════════════════════════
  // 1. التحقق من جلسة الأدمن
  // ═══════════════════════════════════════════
  const admin = await verifyAdmin(request);
  if (!admin) {
    return NextResponse.json({ error: 'غير مصرّح' }, { status: 401 });
  }

  // ═══════════════════════════════════════════
  // 2. Rate Limiting — 10 طلبات / دقيقة لكل أدمن
  // ═══════════════════════════════════════════
  if (!rateLimit(`notif:${admin.uid}`, 10, 60_000)) {
    return NextResponse.json({ error: 'طلبات كثيرة. حاول بعد دقيقة.' }, { status: 429 });
  }

  // ═══════════════════════════════════════════
  // 3. تحقق من المدخلات بـ Zod
  // ═══════════════════════════════════════════
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: 'بيانات غير صالحة' }, { status: 400 });
  }

  const parsed = sendNotificationSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: 'مدخلات غير صالحة', fields: parsed.error.flatten().fieldErrors },
      { status: 400 }
    );
  }

  const { title, body: notifBody, target, targetId } = parsed.data;

  try {
    // ═══════════════════════════════════════════
    // 4. جمع FCM tokens
    // ═══════════════════════════════════════════
    const tokens: string[] = [];

    if (target === 'all_users') {
      const snap = await adminDb.collection('clients').where('fcmToken', '!=', null).get();
      snap.forEach((doc) => { if (doc.data().fcmToken) tokens.push(doc.data().fcmToken); });
    } else if (target === 'all_drivers') {
      const snap = await adminDb.collection('drivers').where('fcmToken', '!=', null).get();
      snap.forEach((doc) => { if (doc.data().fcmToken) tokens.push(doc.data().fcmToken); });
    } else if (target === 'specific_user' && targetId) {
      const doc = await adminDb.collection('clients').doc(targetId).get();
      if (doc.exists && doc.data()?.fcmToken) tokens.push(doc.data()!.fcmToken);
    } else if (target === 'specific_driver' && targetId) {
      const doc = await adminDb.collection('drivers').doc(targetId).get();
      if (doc.exists && doc.data()?.fcmToken) tokens.push(doc.data()!.fcmToken);
    }

    if (tokens.length === 0) {
      return NextResponse.json({ sent: 0, message: 'لا يوجد أجهزة متصلة' });
    }

    // ═══════════════════════════════════════════
    // 5. إرسال FCM
    // ═══════════════════════════════════════════
    const response = await adminMessaging.sendEachForMulticast({
      tokens,
      notification: { title, body: notifBody },
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'ride_channel' },
      },
    });

    // ═══════════════════════════════════════════
    // 6. حذف FCM tokens المنتهية
    // ═══════════════════════════════════════════
    response.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error) {
        const code = resp.error.code;
        if (
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/registration-token-not-registered'
        ) {
          console.warn(`Expired FCM token at index ${idx}`);
        }
      }
    });

    // حذف tokens المنتهية بالبحث
    if (response.failureCount > 0) {
      const failedTokens = tokens.filter((_, i) => !response.responses[i].success);
      for (const token of failedTokens) {
        const errCode = response.responses[tokens.indexOf(token)]?.error?.code;
        if (
          errCode === 'messaging/invalid-registration-token' ||
          errCode === 'messaging/registration-token-not-registered'
        ) {
          // بحث وحذف في clients
          const clientSnap = await adminDb.collection('clients').where('fcmToken', '==', token).get();
          for (const d of clientSnap.docs) {
            await d.ref.update({ fcmToken: null });
          }
          // بحث وحذف في drivers
          const driverSnap = await adminDb.collection('drivers').where('fcmToken', '==', token).get();
          for (const d of driverSnap.docs) {
            await d.ref.update({ fcmToken: null });
          }
        }
      }
    }

    // ═══════════════════════════════════════════
    // 7. Audit Log
    // ═══════════════════════════════════════════
    await auditLog({
      action: 'send_notification',
      adminUid: admin.uid,
      adminEmail: admin.email,
      targetCollection: target.includes('user') ? 'clients' : 'drivers',
      targetId: targetId || undefined,
      details: { title, target, sent: response.successCount, failed: response.failureCount },
    });

    return NextResponse.json({
      sent: response.successCount,
      failed: response.failureCount,
      total: tokens.length,
    });
  } catch (error) {
    console.error('FCM error:', error);
    // لا نعرض تفاصيل الخطأ الداخلي
    return NextResponse.json({ error: 'فشل إرسال الإشعار' }, { status: 500 });
  }
}
