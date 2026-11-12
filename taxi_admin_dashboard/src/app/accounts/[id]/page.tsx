'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ArrowRight, Receipt, ArrowDownCircle, ArrowUpCircle } from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';
import { useAuth } from '@/lib/auth-context';
import { useDriver } from '@/features/drivers/data/useDrivers';
import { useDriverTransactions } from '@/features/accounts/data/useDriverTransactions';
import { recordPayment, recordCharge } from '@/features/accounts/application/accountService';
import Link from 'next/link';
import { use } from 'react';

export default function DriverAccountPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { user } = useAuth();
  const { driver } = useDriver(id);
  const { transactions, loading } = useDriverTransactions(id);

  const [showModal, setShowModal] = useState<'payment' | 'charge' | null>(null);
  const [modalAmount, setModalAmount] = useState('');
  const [modalNote, setModalNote] = useState('');
  const [saving, setSaving] = useState(false);

  const driverName = driver?.name || '';
  const totalOwed = driver?.totalCommissionOwed || 0;
  const totalPaid = driver?.totalPaid || 0;

  const handleSubmit = async () => {
    const amount = parseFloat(modalAmount);
    if (!amount || amount <= 0) return;
    setSaving(true);
    try {
      if (showModal === 'payment') {
        await recordPayment({ driverId: id, driverName, amount, note: modalNote, adminEmail: user?.email || 'admin' });
      } else if (showModal === 'charge') {
        await recordCharge({ driverId: id, driverName, amount, note: modalNote, adminEmail: user?.email || 'admin' });
      }
      setShowModal(null); setModalAmount(''); setModalNote('');
    } catch (e) {
      console.error(e);
      alert('حدث خطأ');
    }
    setSaving(false);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Link href="/accounts"><Button variant="ghost" size="icon"><ArrowRight className="h-5 w-5" /></Button></Link>
        <div>
          <h1 className="text-2xl font-bold">{driverName}</h1>
          <p className="text-gray-500" dir="ltr">{driver?.phone || ''}</p>
        </div>
      </div>

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
