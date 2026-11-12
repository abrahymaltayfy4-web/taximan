'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, orderBy, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ArrowRight, User, Phone, Car, CreditCard, Star, MapPin } from 'lucide-react';
import { formatDate, formatCurrency, formatDistance } from '@/lib/utils';
import { DRIVER_STATUS_LABELS, RIDE_STATUS_LABELS, type DriverStatus, type RideStatus, type Ride } from '@/lib/types';
import { useDriver } from '@/features/drivers/data/useDrivers';
import { mapRide } from '@/features/shared/mappers';
import Link from 'next/link';
import { use } from 'react';

const rideStatusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', accepted: 'info', driver_arrived: 'info',
  started: 'default', completed: 'success', cancelled: 'destructive',
};

export default function DriverDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { driver } = useDriver(id);
  const [rides, setRides] = useState<Ride[]>([]);

  useEffect(() => {
    const q = query(collection(db, 'rides'), where('driverId', '==', id), orderBy('createdAt', 'desc'));
    const unsub = onSnapshot(q, (snap) => {
      setRides(snap.docs.map((d) => mapRide(d.id, d.data())));
    });
    return () => unsub();
  }, [id]);

  if (!driver) return <div className="flex items-center justify-center h-64 text-gray-400">جاري التحميل...</div>;

  const totalEarnings = rides.filter(r => r.status === 'completed').reduce((sum, r) => sum + r.fare, 0);
  const completedCount = rides.filter(r => r.status === 'completed').length;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Link href="/drivers"><Button variant="ghost" size="icon"><ArrowRight className="h-5 w-5" /></Button></Link>
        <h1 className="text-3xl font-bold">تفاصيل السائق</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>المعلومات الشخصية</CardTitle></CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-6">
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-[#5C0A2A]/10 p-2"><User className="h-5 w-5 text-[#5C0A2A]" /></div>
                <div><p className="text-xs text-gray-500">الاسم</p><p className="font-medium">{driver.name}</p></div>
              </div>
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-green-50 p-2"><Phone className="h-5 w-5 text-green-600" /></div>
                <div><p className="text-xs text-gray-500">الهاتف</p><p className="font-medium" dir="ltr">{driver.phone}</p></div>
              </div>
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-blue-50 p-2"><Car className="h-5 w-5 text-blue-600" /></div>
                <div><p className="text-xs text-gray-500">السيارة</p><p className="font-medium">{driver.carModel}</p></div>
              </div>
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-purple-50 p-2"><CreditCard className="h-5 w-5 text-purple-600" /></div>
                <div><p className="text-xs text-gray-500">اللوحة</p><p className="font-medium font-mono">{driver.carPlate}</p></div>
              </div>
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-yellow-50 p-2"><Star className="h-5 w-5 text-yellow-600" /></div>
                <div><p className="text-xs text-gray-500">التقييم</p><p className="font-medium">⭐ {driver.rating.toFixed(1)}</p></div>
              </div>
              <div className="flex items-center gap-3">
                <div className="rounded-full bg-orange-50 p-2"><MapPin className="h-5 w-5 text-orange-600" /></div>
                <div><p className="text-xs text-gray-500">سعر الكيلومتر</p><p className="font-medium">{driver.pricePerKm} ريال</p></div>
              </div>
            </div>
          </CardContent>
        </Card>

        <div className="space-y-4">
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-sm text-gray-500">إجمالي الأرباح</p>
              <p className="text-2xl font-bold text-[#5C0A2A] mt-1">{formatCurrency(totalEarnings)}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-sm text-gray-500">الرحلات المكتملة</p>
              <p className="text-2xl font-bold mt-1">{completedCount}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-sm text-gray-500">الحالة</p>
              <Badge variant={driver.isBlocked ? 'destructive' : 'success'} className="mt-2">
                {driver.isBlocked ? 'محظور' : DRIVER_STATUS_LABELS[driver.status as DriverStatus]}
              </Badge>
            </CardContent>
          </Card>
        </div>
      </div>

      <Card>
        <CardHeader><CardTitle>سجل الرحلات ({rides.length})</CardTitle></CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-right p-3 font-medium text-gray-600">التاريخ</th>
                  <th className="text-right p-3 font-medium text-gray-600">العميل</th>
                  <th className="text-right p-3 font-medium text-gray-600">من</th>
                  <th className="text-right p-3 font-medium text-gray-600">إلى</th>
                  <th className="text-right p-3 font-medium text-gray-600">المسافة</th>
                  <th className="text-right p-3 font-medium text-gray-600">السعر</th>
                  <th className="text-right p-3 font-medium text-gray-600">الحالة</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {rides.length === 0 ? (
                  <tr><td colSpan={7} className="text-center p-6 text-gray-400">لا توجد رحلات</td></tr>
                ) : rides.map((ride) => (
                  <tr key={ride.rideId} className="hover:bg-gray-50">
                    <td className="p-3 text-xs">{formatDate(ride.createdAt)}</td>
                    <td className="p-3">{ride.customerName}</td>
                    <td className="p-3 text-xs max-w-[150px] truncate">{ride.pickupAddress}</td>
                    <td className="p-3 text-xs max-w-[150px] truncate">{ride.destinationAddress}</td>
                    <td className="p-3">{formatDistance(ride.distanceKm)}</td>
                    <td className="p-3 font-semibold text-[#5C0A2A]">{formatCurrency(ride.fare)}</td>
                    <td className="p-3"><Badge variant={rideStatusVariant[ride.status]}>{RIDE_STATUS_LABELS[ride.status]}</Badge></td>
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
