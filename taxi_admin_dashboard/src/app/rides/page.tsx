'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Search } from 'lucide-react';
import { formatDate, formatCurrency, formatDistance } from '@/lib/utils';
import { RIDE_STATUS_LABELS, type RideStatus, type Ride } from '@/lib/types';
import Link from 'next/link';

const statusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', accepted: 'info', driver_arrived: 'info',
  started: 'default', completed: 'success', cancelled: 'destructive',
};

type FilterTab = 'all' | RideStatus;

export default function RidesPage() {
  const [rides, setRides] = useState<Ride[]>([]);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<FilterTab>('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'rides'), (snap) => {
      const data = snap.docs.map((d) => {
        const raw = d.data();
        return {
          rideId: d.id, customerId: raw.customerId || '', customerName: raw.customerName || '',
          customerPhone: raw.customerPhone || '', driverId: raw.driverId || null,
          driverName: raw.driverName || null, driverPhone: raw.driverPhone || null,
          driverCarModel: raw.driverCarModel || null, driverCarPlate: raw.driverCarPlate || null,
          pickupLocation: raw.pickupLocation ? { latitude: raw.pickupLocation.latitude, longitude: raw.pickupLocation.longitude } : { latitude: 0, longitude: 0 },
          pickupAddress: raw.pickupAddress || '', destinationLocation: raw.destinationLocation ? { latitude: raw.destinationLocation.latitude, longitude: raw.destinationLocation.longitude } : { latitude: 0, longitude: 0 },
          destinationAddress: raw.destinationAddress || '', status: (raw.status || 'pending') as RideStatus,
          fare: raw.fare || 0, distanceKm: raw.distanceKm || 0,
          createdAt: (raw.createdAt as Timestamp)?.toDate() || new Date(),
          acceptedAt: (raw.acceptedAt as Timestamp)?.toDate() || null,
          completedAt: (raw.completedAt as Timestamp)?.toDate() || null,
        };
      }).sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
      setRides(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const filtered = rides.filter((r) => {
    const matchesSearch = r.customerName.includes(search) || (r.driverName?.includes(search) ?? false) || r.pickupAddress.includes(search);
    if (!matchesSearch) return false;
    if (filter === 'all') return true;
    return r.status === filter;
  });

  const tabs: { key: FilterTab; label: string; count: number }[] = [
    { key: 'all', label: 'الكل', count: rides.length },
    { key: 'pending', label: 'في الانتظار', count: rides.filter(r => r.status === 'pending').length },
    { key: 'accepted', label: 'مقبولة', count: rides.filter(r => r.status === 'accepted').length },
    { key: 'started', label: 'جارية', count: rides.filter(r => r.status === 'started' || r.status === 'driver_arrived').length },
    { key: 'completed', label: 'مكتملة', count: rides.filter(r => r.status === 'completed').length },
    { key: 'cancelled', label: 'ملغية', count: rides.filter(r => r.status === 'cancelled').length },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">مراقبة الرحلات</h1>
        <p className="text-gray-500 mt-1">جميع رحلات النظام في الوقت الفعلي</p>
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

      <div className="relative max-w-md">
        <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input placeholder="بحث بالعميل أو السائق أو العنوان..." value={search} onChange={(e) => setSearch(e.target.value)} className="pr-10" />
      </div>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-right p-4 font-medium text-gray-600">التاريخ</th>
                  <th className="text-right p-4 font-medium text-gray-600">العميل</th>
                  <th className="text-right p-4 font-medium text-gray-600">السائق</th>
                  <th className="text-right p-4 font-medium text-gray-600">من</th>
                  <th className="text-right p-4 font-medium text-gray-600">إلى</th>
                  <th className="text-right p-4 font-medium text-gray-600">المسافة</th>
                  <th className="text-right p-4 font-medium text-gray-600">السعر</th>
                  <th className="text-right p-4 font-medium text-gray-600">الحالة</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {loading ? (
                  <tr><td colSpan={8} className="text-center p-8 text-gray-400">جاري التحميل...</td></tr>
                ) : filtered.length === 0 ? (
                  <tr><td colSpan={8} className="text-center p-8 text-gray-400">لا توجد رحلات</td></tr>
                ) : filtered.map((ride) => (
                  <tr key={ride.rideId} className="hover:bg-gray-50 cursor-pointer" onClick={() => window.location.href = `/rides/${ride.rideId}`}>
                    <td className="p-4 text-xs">{formatDate(ride.createdAt)}</td>
                    <td className="p-4 font-medium">{ride.customerName}</td>
                    <td className="p-4">{ride.driverName || <span className="text-gray-400">بانتظار</span>}</td>
                    <td className="p-4 text-xs max-w-[120px] truncate">{ride.pickupAddress}</td>
                    <td className="p-4 text-xs max-w-[120px] truncate">{ride.destinationAddress}</td>
                    <td className="p-4">{formatDistance(ride.distanceKm)}</td>
                    <td className="p-4 font-semibold text-[#5C0A2A]">{formatCurrency(ride.fare)}</td>
                    <td className="p-4"><Badge variant={statusVariant[ride.status]}>{RIDE_STATUS_LABELS[ride.status]}</Badge></td>
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
