import { collection, addDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { authFetch } from '@/lib/auth-fetch';
import type { NotificationTarget } from '@/lib/types';

/** إرسال إشعار (Firestore + FCM عبر API محمي) */
export async function sendNotification(params: {
  title: string;
  body: string;
  target: NotificationTarget;
  targetId?: string | null;
  targetName?: string | null;
  sentBy: string;
}) {
  // حفظ في Firestore (للإشعارات عند فتح التطبيق)
  await addDoc(collection(db, 'notifications'), {
    title: params.title,
    body: params.body,
    target: params.target,
    targetId: params.targetId || null,
    targetName: params.targetName || null,
    sentAt: Timestamp.now(),
    sentBy: params.sentBy,
  });

  // إرسال FCM عبر Server Route المحمي
  const res = await authFetch('/api/send-notification', {
    title: params.title,
    body: params.body,
    target: params.target,
    targetId: params.targetId || null,
  });

  if (!res.ok) {
    const data = await res.json().catch(() => ({}));
    throw new Error(data.error || 'فشل إرسال الإشعار');
  }
}
