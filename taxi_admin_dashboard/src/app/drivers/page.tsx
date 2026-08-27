'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, updateDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Search, Eye, Ban, ShieldOff, ShieldCheck, CheckCircle, XCircle } from 'lucide-react';
import type { Driver, DriverStatus, ApprovalStatus } from '@/lib/types';
import { DRIVER_STATUS_LABELS, APPROVAL_STATUS_LABELS } from '@/lib/types';
import Link from 'next/link';

const statusColor: Record<DriverStatus, 'success' | 'default' | 'warning' | 'destructive'> = {
  online: 'success', offline: 'default', busy: 'warning', suspended: 'destructive',
};
const approvalColor: Record<ApprovalStatus, 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', approved: 'success', rejected: 'destructive',
};

type FilterTab = 'all' | DriverStatus | 'pending_approval';

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<FilterTab>('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'drivers'), (snap) => {
      const data = snap.docs.map((d) => {
        const raw = d.data();
        return {
          uid: d.id, name: raw.name || '', email: raw.email || '', phone: raw.phone || '',
          carModel: raw.carModel || '', carPlate: raw.carPlate || '',
          pricePerKm: raw.pricePerKm || 0, status: (raw.status || 'offline') as DriverStatus,
          location: raw.location ? { latitude: raw.location.latitude, longitude: raw.location.longitude } : null,
          rating: raw.rating || 5.0, isBlocked: raw.isBlocked || false,
          isDisabled: raw.isDisabled || false,
          approvalStatus: (raw.approvalStatus || 'approved') as ApprovalStatus,
          createdAt: (raw.createdAt as Timestamp)?.toDate(),
          lastUpdated: (raw.lastUpdated as Timestamp)?.toDate(),
        };
      });
      setDrivers(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const filtered = drivers.filter((d) => {
    const matchesSearch = d.name.toLowerCase().includes(search.toLowerCase()) ||
      d.phone.includes(search) || d.carPlate.includes(search);
    if (!matchesSearch) return false;
    if (filter === 'all') return true;
    if (filter === 'pending_approval') return d.approvalStatus === 'pending';
    return d.status === filter;
  });

  const approveDriver = async (uid: string) => {
    await updateDoc(doc(db, 'drivers', uid), { approvalStatus: 'approved' });
  };
  const rejectDriver = async (uid: string) => {
    await updateDoc(doc(db, 'drivers', uid), { approvalStatus: 'rejected' });
  };
  const toggleBlock = async (uid: string, current: boolean) => {
    try {
      await updateDoc(doc(db, 'drivers', uid), { isBlocked: !current });
    } catch (e) { console.error('Block error:', e); alert('فشل تحديث حالة الحظر'); }
  };
  const toggleDisable = async (uid: string, current: boolean) => {
    try {
      const updates: Record<string, unknown> = { isDisabled: !current };
      if (!current) updates.status = 'offline';
      await updateDoc(doc(db, 'drivers', uid), updates);
    } catch (e) { console.error('Disable error:', e); alert('فشل تحديث حالة التعطيل'); }
  };

  const tabs: { key: FilterTab; label: string; count: number }[] = [
    { key: 'all', label: 'الكل', count: drivers.length },
    { key: 'online', label: '🟢 متصل', count: drivers.filter(d => d.status === 'online').length },
    { key: 'busy', label: '🟡 في رحلة', count: drivers.filter(d => d.status === 'busy').length },
    { key: 'offline', label: '⚫ غير متصل', count: drivers.filter(d => d.status === 'offline').length },
    { key: 'pending_approval', label: '⏳ بانتظار موافقة', count: drivers.filter(d => d.approvalStatus === 'pending').length },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">إدارة السائقين</h1>
        <p className="text-gray-500 mt-1">{drivers.length} سائق مسجل</p>
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2 flex-wrap">
        {tabs.map((tab) => (
          <button key={tab.key} onClick={() => setFilter(tab.key)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors cursor-pointer ${
              filter === tab.key ? 'bg-[#5C0A2A] text-white' : 'bg-white border border-gray-200 hover:bg-gray-50'
            }`}>
            {tab.label} ({tab.count})
          </button>
        ))}
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input placeholder="بحث بالاسم أو الهاتف أو اللوحة..." value={search} onChange={(e) => setSearch(e.target.value)} className="pr-10" />
      </div>

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-right p-4 font-medium text-gray-600">الاسم</th>
                  <th className="text-right p-4 font-medium text-gray-600">الهاتف</th>
                  <th className="text-right p-4 font-medium text-gray-600">السيارة</th>
                  <th className="text-right p-4 font-medium text-gray-600">اللوحة</th>
                  <th className="text-right p-4 font-medium text-gray-600">السعر/كم</th>
                  <th className="text-right p-4 font-medium text-gray-600">التقييم</th>
                  <th className="text-right p-4 font-medium text-gray-600">الحالة</th>
                  <th className="text-right p-4 font-medium text-gray-600">الموافقة</th>
                  <th className="text-right p-4 font-medium text-gray-600">إجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {loading ? (
                  <tr><td colSpan={9} className="text-center p-8 text-gray-400">جاري التحميل...</td></tr>
                ) : filtered.length === 0 ? (
                  <tr><td colSpan={9} className="text-center p-8 text-gray-400">لا توجد نتائج</td></tr>
                ) : filtered.map((driver) => (
                  <tr key={driver.uid} className="hover:bg-gray-50">
                    <td className="p-4 font-medium">{driver.name}</td>
                    <td className="p-4 text-gray-600" dir="ltr">{driver.phone}</td>
                    <td className="p-4">{driver.carModel}</td>
                    <td className="p-4 font-mono">{driver.carPlate}</td>
                    <td className="p-4">{driver.pricePerKm} ريال</td>
                    <td className="p-4">⭐ {driver.rating.toFixed(1)}</td>
                    <td className="p-4">
                      {driver.isBlocked ? <Badge variant="destructive">محظور</Badge>
                       : <Badge variant={statusColor[driver.status]}>{DRIVER_STATUS_LABELS[driver.status]}</Badge>}
                    </td>
                    <td className="p-4">
                      <Badge variant={approvalColor[driver.approvalStatus]}>{APPROVAL_STATUS_LABELS[driver.approvalStatus]}</Badge>
                    </td>
                    <td className="p-4">
                      <div className="flex items-center gap-1">
                        <Link href={`/drivers/${driver.uid}`}>
                          <Button variant="ghost" size="icon" title="تفاصيل"><Eye className="h-4 w-4" /></Button>
                        </Link>
                        {driver.approvalStatus === 'pending' && (
                          <>
                            <Button variant="ghost" size="icon" onClick={() => approveDriver(driver.uid)} title="موافقة">
                              <CheckCircle className="h-4 w-4 text-green-600" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={() => rejectDriver(driver.uid)} title="رفض">
                              <XCircle className="h-4 w-4 text-red-600" />
                            </Button>
                          </>
                        )}
                        <Button variant="ghost" size="icon" onClick={() => toggleDisable(driver.uid, driver.isDisabled)} title={driver.isDisabled ? 'تفعيل' : 'تعطيل'}>
                          {driver.isDisabled ? <ShieldCheck className="h-4 w-4 text-green-600" /> : <ShieldOff className="h-4 w-4 text-yellow-600" />}
                        </Button>
                        <Button variant="ghost" size="icon" onClick={() => toggleBlock(driver.uid, driver.isBlocked)} title={driver.isBlocked ? 'رفع الحظر' : 'حظر'}>
                          <Ban className={`h-4 w-4 ${driver.isBlocked ? 'text-green-600' : 'text-red-600'}`} />
                        </Button>
                      </div>
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
