'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Search, Wallet, TrendingUp } from 'lucide-react';
import { formatCurrency } from '@/lib/utils';
import Link from 'next/link';

interface DriverAccount {
  uid: string;
  name: string;
  phone: string;
  totalCommissionOwed: number;
  totalPaid: number;
}

export default function AccountsPage() {
  const [drivers, setDrivers] = useState<DriverAccount[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'owed'>('all');

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'drivers'), (snap) => {
      const list = snap.docs.map((d) => ({
        uid: d.id,
        name: d.data().name || '',
        phone: d.data().phone || '',
        totalCommissionOwed: d.data().totalCommissionOwed || 0,
        totalPaid: d.data().totalPaid || 0,
      }));
      setDrivers(list);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const filtered = drivers.filter((d) => {
    const matchesSearch = d.name.includes(search) || d.phone.includes(search);
    const matchesFilter = filter === 'all' || d.totalCommissionOwed > 0;
    return matchesSearch && matchesFilter;
  });

  const totalOwed = drivers.reduce((sum, d) => sum + d.totalCommissionOwed, 0);
  const totalPaid = drivers.reduce((sum, d) => sum + d.totalPaid, 0);

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">💰 كشف الحسابات</h1>

      {/* بطاقات الملخص */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-3 bg-red-100 rounded-lg"><Wallet className="h-6 w-6 text-red-600" /></div>
            <div>
              <p className="text-sm text-gray-500">إجمالي العمولات المستحقة</p>
              <p className="text-2xl font-bold text-red-600">{formatCurrency(totalOwed)}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-3 bg-green-100 rounded-lg"><TrendingUp className="h-6 w-6 text-green-600" /></div>
            <div>
              <p className="text-sm text-gray-500">إجمالي المدفوعات</p>
              <p className="text-2xl font-bold text-green-600">{formatCurrency(totalPaid)}</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-3 bg-blue-100 rounded-lg"><Wallet className="h-6 w-6 text-blue-600" /></div>
            <div>
              <p className="text-sm text-gray-500">عدد السائقين بمستحقات</p>
              <p className="text-2xl font-bold text-blue-600">{drivers.filter(d => d.totalCommissionOwed > 0).length}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* بحث وفلتر */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between gap-4">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input placeholder="بحث بالاسم أو رقم الهاتف..." value={search} onChange={(e) => setSearch(e.target.value)} className="pr-10" />
            </div>
            <div className="flex gap-2">
              <button onClick={() => setFilter('all')} className={`px-4 py-2 rounded-lg text-sm font-medium transition ${filter === 'all' ? 'bg-[#5C0A2A] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>الكل ({drivers.length})</button>
              <button onClick={() => setFilter('owed')} className={`px-4 py-2 rounded-lg text-sm font-medium transition ${filter === 'owed' ? 'bg-red-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>لديهم مستحقات ({drivers.filter(d => d.totalCommissionOwed > 0).length})</button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-right text-sm">
              <thead className="bg-gray-50 text-gray-500">
                <tr>
                  <th className="p-4">الاسم</th>
                  <th className="p-4">الهاتف</th>
                  <th className="p-4">عمولات مستحقة</th>
                  <th className="p-4">إجمالي المدفوع</th>
                  <th className="p-4">الحالة</th>
                  <th className="p-4">إجراء</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {loading ? (
                  <tr><td colSpan={6} className="text-center p-8 text-gray-400">جاري التحميل...</td></tr>
                ) : filtered.length === 0 ? (
                  <tr><td colSpan={6} className="text-center p-8 text-gray-400">لا يوجد سائقين</td></tr>
                ) : filtered.map((d) => (
                  <tr key={d.uid} className="hover:bg-gray-50">
                    <td className="p-4 font-medium">{d.name}</td>
                    <td className="p-4" dir="ltr">{d.phone}</td>
                    <td className="p-4 font-bold text-red-600">{formatCurrency(d.totalCommissionOwed)}</td>
                    <td className="p-4 text-green-600">{formatCurrency(d.totalPaid)}</td>
                    <td className="p-4">
                      {d.totalCommissionOwed > 0
                        ? <Badge variant="destructive">مستحقات</Badge>
                        : <Badge variant="success">لا مستحقات</Badge>}
                    </td>
                    <td className="p-4">
                      <Link href={`/accounts/${d.uid}`} className="text-[#5C0A2A] hover:underline font-medium">التفاصيل</Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
