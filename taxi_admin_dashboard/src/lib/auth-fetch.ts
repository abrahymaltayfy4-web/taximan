import { auth } from '@/lib/firebase';

/**
 * يرسل طلب مصادق للـ API — يُضيف Bearer token تلقائياً
 */
export async function authFetch(url: string, body: Record<string, unknown>): Promise<Response> {
  const user = auth.currentUser;
  if (!user) throw new Error('غير مسجل الدخول');

  const idToken = await user.getIdToken();

  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`,
    },
    body: JSON.stringify(body),
  });
}
