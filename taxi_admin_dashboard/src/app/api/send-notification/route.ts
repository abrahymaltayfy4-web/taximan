import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { NextRequest, NextResponse } from 'next/server';

// تهيئة Firebase Admin
if (getApps().length === 0) {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (serviceAccount) {
    initializeApp({ credential: cert(JSON.parse(serviceAccount)) });
  } else {
    // fallback: default credentials
    initializeApp({ projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID });
  }
}

export async function POST(request: NextRequest) {
  try {
    const { title, body, target, targetId } = await request.json();

    if (!title || !body || !target) {
      return NextResponse.json({ error: 'Missing fields' }, { status: 400 });
    }

    const db = getFirestore();
    const messaging = getMessaging();
    const tokens: string[] = [];

    if (target === 'all_users') {
      const snap = await db.collection('clients').where('fcmToken', '!=', null).get();
      snap.forEach((doc) => { if (doc.data().fcmToken) tokens.push(doc.data().fcmToken); });
    } else if (target === 'all_drivers') {
      const snap = await db.collection('drivers').where('fcmToken', '!=', null).get();
      snap.forEach((doc) => { if (doc.data().fcmToken) tokens.push(doc.data().fcmToken); });
    } else if (target === 'specific_user' && targetId) {
      const doc = await db.collection('clients').doc(targetId).get();
      if (doc.exists && doc.data()?.fcmToken) tokens.push(doc.data()!.fcmToken);
    } else if (target === 'specific_driver' && targetId) {
      const doc = await db.collection('drivers').doc(targetId).get();
      if (doc.exists && doc.data()?.fcmToken) tokens.push(doc.data()!.fcmToken);
    }

    if (tokens.length === 0) {
      return NextResponse.json({ sent: 0, message: 'لا يوجد أجهزة متصلة' });
    }

    // إرسال FCM لكل الأجهزة
    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'ride_channel' },
      },
    });

    return NextResponse.json({
      sent: response.successCount,
      failed: response.failureCount,
      total: tokens.length,
    });
  } catch (error) {
    console.error('FCM error:', error);
    return NextResponse.json({ error: 'Failed to send' }, { status: 500 });
  }
}
