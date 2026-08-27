'use client';

import { useEffect, useState } from 'react';
import { collection, addDoc, onSnapshot, query, orderBy, limit, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Send, Users, Car, User } from 'lucide-react';
import { formatDate } from '@/lib/utils';
import { useAuth } from '@/lib/auth-context';
import type { AdminNotification, NotificationTarget } from '@/lib/types';

const targets: { key: NotificationTarget; label: string; icon: React.ElementType }[] = [
  { key: 'all_users', label: 'جميع العملاء', icon: Users },
  { key: 'all_drivers', label: 'جميع السائقين', icon: Car },
  { key: 'specific_user', label: 'عميل محدد', icon: User },
  { key: 'specific_driver', label: 'سائق محدد', icon: Car },
];

export default function NotificationsPage() {
  const { user } = useAuth();
  const [target, setTarget] = useState<NotificationTarget>('all_users');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetId, setTargetId] = useState('');
  const [targetName, setTargetName] = useState('');
  const [sending, setSending] = useState(false);
  const [sent, setSent] = useState(false);
  const [history, setHistory] = useState<AdminNotification[]>([]);

  useEffect(() => {
    const q = query(collection(db, 'notifications'), orderBy('sentAt', 'desc'), limit(20));
    const unsub = onSnapshot(q, (snap) => {
      setHistory(snap.docs.map((d) => {
        const data = d.data();
        return {
          id: d.id, title: data.title, body: data.body, target: data.target,
          targetId: data.targetId, targetName: data.targetName,
          sentAt: (data.sentAt as Timestamp)?.toDate() || new Date(),
          sentBy: data.sentBy || '',
        };
      }));
    });
    return () => unsub();
  }, []);

  const handleSend = async () => {
    if (!title.trim() || !body.trim()) return;
    setSending(true);
    try {
      // حفظ في Firestore (للإشعارات عند فتح التطبيق)
      await addDoc(collection(db, 'notifications'), {
        title, body, target, targetId: targetId || null, targetName: targetName || null,
        sentAt: Timestamp.now(), sentBy: user?.email || 'admin',
      });

      // إرسال FCM (للإشعارات عند إغلاق التطبيق)
      const res = await fetch('/api/send-notification', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, body, target, targetId: targetId || null }),
      });
      const result = await res.json();
      console.log('FCM result:', result);

      setTitle(''); setBody(''); setTargetId(''); setTargetName('');
      setSent(true);
      setTimeout(() => setSent(false), 3000);
    } catch (e) {
      console.error('Send error:', e);
      alert('تم الحفظ لكن فشل إرسال الإشعار');
    }
    setSending(false);
  };

  const targetLabel: Record<NotificationTarget, string> = {
    all_users: 'جميع العملاء', all_drivers: 'جميع السائقين',
    specific_user: 'عميل محدد', specific_driver: 'سائق محدد',
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">الإشعارات</h1>
        <p className="text-gray-500 mt-1">إرسال إشعارات للمستخدمين والسائقين</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Send Form */}
        <Card>
          <CardHeader><CardTitle>إرسال إشعار جديد</CardTitle></CardHeader>
          <CardContent className="space-y-4">
            {/* Target Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">الهدف</label>
              <div className="grid grid-cols-2 gap-2">
                {targets.map((t) => (
                  <button key={t.key} onClick={() => setTarget(t.key)}
                    className={`flex items-center gap-2 p-3 rounded-lg border text-sm font-medium transition-colors cursor-pointer ${
                      target === t.key ? 'border-[#5C0A2A] bg-[#5C0A2A]/5 text-[#5C0A2A]' : 'border-gray-200 hover:bg-gray-50'
                    }`}>
                    <t.icon className="h-4 w-4" />
                    {t.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Specific Target ID */}
            {(target === 'specific_user' || target === 'specific_driver') && (
              <div className="space-y-2">
                <Input placeholder="اسم المستخدم" value={targetName} onChange={(e) => setTargetName(e.target.value)} />
                <Input placeholder="معرف المستخدم (UID)" value={targetId} onChange={(e) => setTargetId(e.target.value)} dir="ltr" />
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">عنوان الإشعار</label>
              <Input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="مثال: عرض خاص!" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">محتوى الإشعار</label>
              <textarea value={body} onChange={(e) => setBody(e.target.value)} placeholder="اكتب محتوى الإشعار هنا..."
                className="w-full min-h-[100px] rounded-md border border-gray-200 bg-white px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950" />
            </div>

            <div className="flex items-center gap-3">
              <Button variant="burgundy" onClick={handleSend} disabled={sending || !title.trim() || !body.trim()}>
                <Send className="h-4 w-4 ml-2" />
                {sending ? 'جاري الإرسال...' : 'إرسال'}
              </Button>
              {sent && <span className="text-green-600 text-sm">✅ تم الإرسال</span>}
            </div>
          </CardContent>
        </Card>

        {/* History */}
        <Card>
          <CardHeader><CardTitle>سجل الإشعارات</CardTitle></CardHeader>
          <CardContent>
            <div className="space-y-3 max-h-[500px] overflow-y-auto">
              {history.length === 0 ? (
                <p className="text-center text-gray-400 py-8">لا توجد إشعارات مرسلة</p>
              ) : history.map((n) => (
                <div key={n.id} className="border border-gray-100 rounded-lg p-3">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="font-medium text-sm">{n.title}</h4>
                    <Badge variant="secondary" className="text-xs">{targetLabel[n.target]}</Badge>
                  </div>
                  <p className="text-xs text-gray-600 mb-2">{n.body}</p>
                  <div className="flex items-center justify-between text-xs text-gray-400">
                    <span>{n.sentBy}</span>
                    <span>{formatDate(n.sentAt)}</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
