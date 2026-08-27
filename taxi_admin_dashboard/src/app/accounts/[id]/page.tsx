'use client';

import { useEffect, useState } from 'react';
import { doc, onSnapshot, collection, query, where, orderBy, addDoc, updateDoc, Timestamp, increment } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { ArrowRight, Receipt, ArrowDownCircle, ArrowUpCircle } from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';
import { useAuth } from '@/lib/auth-context';
import Link from 'next/link';
import { use } from 'react';

interface Transaction {
  id: string;
  type: 'commission' | 'payment';
  amount: number;
  rideFare: number;
  note: string;
  createdAt: Date;
}

export default function DriverAccountPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { user } = useAuth();
  const [driverName, setDriverName] = useState('');
  const [driverPhone, setDriverPhone] = useState('');
  const [totalOwed, setTotalOwed] = useState(0);
  const [totalPaid, setTotalPaid] = useState(0);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  // نافذة سند القبض/الصرف
  const [showModal, setShowModal] = useState<'payment' | 'charge' | null>(null);
  const [modalAmount, setModalAmount] = useState('');
  const [modalNote, setModalNote] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    // بيانات السائق
    const unsubDriver = onSnapshot(doc(db, 'drivers', id), (snap) => {
      if (snap.exists()) {
        const d = snap.data();
        setDriverName(d.name || '');
        setDriverPhone(d.phone || '');
        setTotalOwed(d.totalCommissionOwed || 0);
        setTotalPaid(d.totalPaid || 0);
      }
    });

    // المعاملات
    const q = query(
      collection(db, 'transactions'),
      where('driverId', '==', id),
      orderBy('createdAt', 'desc')
    );
    const unsubTx = onSnapshot(q, (snap) => {
      setTransactions(snap.docs.map((d) => ({
        id: d.id,
        type: d.data().type || 'commission',
        amount: d.data().amount || 0,
        rideFare: d.data().rideFare || 0,
        note: d.data().note || '',
        createdAt: (d.data().createdAt as Timestamp)?.toDate() || new Date(),
      })));
      setLoading(false);
    });

    return () => { unsubDriver(); unsubTx(); };
  }, [id]);

  const handleSubmit = async () => {
    const amount = parseFloat(modalAmount);
    if (!amount || amount <= 0) return;
    setSaving(true);

    try {
      if (showModal === 'payment') {
        // سند قبض — خصم من المستحقات
        await addDoc(collection(db, 'transactions'), {
          driverId: id,
          driverName,
          type: 'payment',
          amount,
          rideId: null,
          rideFare: 0,
          note: modalNote || `سداد عمولات — ${amount.toFixed(0)} ريال`,
          createdAt: Timestamp.now(),
          createdBy: user?.email || 'admin',
        });

        await updateDoc(doc(db, 'drivers', id), {
          totalCommissionOwed: increment(-amount),
          totalPaid: increment(amount),
        });

        // إرسال إشعار للسائق
        await addDoc(collection(db, 'notifications'), {
          title: '✅ تم تسجيل سداد',
          body: `تم تسجيل سداد ${amount.toFixed(0)} ريال من عمولاتك. شكراً لك!`,
          target: 'specific_driver',
          targetId: id,
          targetName: driverName,
          sentAt: Timestamp.now(),
          sentBy: user?.email || 'admin',
        });

        // إرسال FCM
        try {
          await fetch('/api/send-notification', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              title: '✅ تم تسجيل سداد',
              body: `تم تسجيل سداد ${amount.toFixed(0)} ريال من عمولاتك. شكراً لك!`,
              target: 'specific_driver',
              targetId: id,
            }),
          });
        } catch (_) {}

      } else if (showModal === 'charge') {
        // سند صرف — إضافة على المستحقات
        await addDoc(collection(db, 'transactions'), {
          driverId: id,
          driverName,
          type: 'commission',
          amount,
          rideId: null,
          rideFare: 0,
          note: modalNote || `إضافة رسوم — ${amount.toFixed(0)} ريال`,
          createdAt: Timestamp.now(),
          createdBy: user?.email || 'admin',
        });

        await updateDoc(doc(db, 'drivers', id), {
          totalCommissionOwed: increment(amount),
        });
      }

      setShowModal(null);
      setModalAmount('');
      setModalNote('');
    } catch (e) {
      console.error(e);
      alert('حدث خطأ');
    }
    setSaving(false);
  };

  return (
    <div className="space-y-6">
      {/* العنوان */}
      <div className="flex items-center gap-3">
        <Link href="/accounts"><Button variant="ghost" size="icon"><ArrowRight className="h-5 w-5" /></Button></Link>
        <div>
          <h1 className="text-2xl font-bold">{driverName}</h1>
          <p className="text-gray-500" dir="ltr">{driverPhone}</p>
        </div>
      </div>

      {/* بطاقات الرصيد */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card className="border-r-4 border-r-red-500">
          <CardContent className="p-6 text-center">
            <p className="text-gray-500 text-sm">عمولات مستحقة</p>
            <p className="text-3xl font-bold text-red-600 mt-2">{formatCurrency(totalOwed)}</p>
            <Button onClick={() => setShowModal('payment')} className="mt-4 bg-green-600 hover:bg-green-700 w-full">
              <Receipt className="h-4 w-4 ml-2" /> سند قبض (تسجيل سداد)
            </Button>
          </CardContent>
        </Card>
        <Card className="border-r-4 border-r-green-500">
          <CardContent className="p-6 text-center">
            <p className="text-gray-500 text-sm">إجمالي المدفوع</p>
            <p className="text-3xl font-bold text-green-600 mt-2">{formatCurrency(totalPaid)}</p>
            <Button onClick={() => setShowModal('charge')} variant="outline" className="mt-4 border-red-300 text-red-600 hover:bg-red-50 w-full">
              <Receipt className="h-4 w-4 ml-2" /> سند صرف (إضافة رسوم)
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* سجل المعاملات */}
      <Card>
        <CardHeader><CardTitle>📋 سجل المعاملات</CardTitle></CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-center text-gray-400 p-8">جاري التحميل...</p>
          ) : transactions.length === 0 ? (
            <p className="text-center text-gray-400 p-8">لا توجد معاملات</p>
          ) : (
            <div className="space-y-3">
              {transactions.map((tx) => (
                <div key={tx.id} className={`flex items-center gap-3 p-4 rounded-lg border-r-4 ${tx.type === 'commission' ? 'border-r-red-400 bg-red-50/50' : 'border-r-green-400 bg-green-50/50'}`}>
                  {tx.type === 'commission'
                    ? <ArrowUpCircle className="h-8 w-8 text-red-500 shrink-0" />
                    : <ArrowDownCircle className="h-8 w-8 text-green-500 shrink-0" />}
                  <div className="flex-1">
                    <p className="font-medium text-sm">{tx.note}</p>
                    <p className="text-xs text-gray-400 mt-1">{formatDate(tx.createdAt)}</p>
                  </div>
                  <span className={`text-lg font-bold ${tx.type === 'commission' ? 'text-red-600' : 'text-green-600'}`}>
                    {tx.type === 'commission' ? '+' : '-'}{formatCurrency(tx.amount)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Modal سند القبض/الصرف */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md space-y-4">
            <h2 className="text-xl font-bold text-center">
              {showModal === 'payment' ? '📥 سند قبض (تسجيل سداد)' : '📤 سند صرف (إضافة رسوم)'}
            </h2>
            <p className="text-sm text-gray-500 text-center">
              {showModal === 'payment'
                ? `سيتم خصم المبلغ من عمولات ${driverName} المستحقة`
                : `سيتم إضافة المبلغ على عمولات ${driverName}`}
            </p>
            <div>
              <label className="text-sm font-medium text-gray-700">المبلغ (ريال)</label>
              <Input type="number" value={modalAmount} onChange={(e) => setModalAmount(e.target.value)} placeholder="أدخل المبلغ" className="mt-1" autoFocus />
            </div>
            <div>
              <label className="text-sm font-medium text-gray-700">ملاحظة (اختياري)</label>
              <Input value={modalNote} onChange={(e) => setModalNote(e.target.value)} placeholder="ملاحظة..." className="mt-1" />
            </div>
            <div className="flex gap-3">
              <Button onClick={handleSubmit} disabled={saving || !modalAmount} className={`flex-1 ${showModal === 'payment' ? 'bg-green-600 hover:bg-green-700' : 'bg-red-600 hover:bg-red-700'}`}>
                {saving ? 'جاري الحفظ...' : 'تأكيد'}
              </Button>
              <Button variant="outline" onClick={() => { setShowModal(null); setModalAmount(''); setModalNote(''); }} className="flex-1">إلغاء</Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
