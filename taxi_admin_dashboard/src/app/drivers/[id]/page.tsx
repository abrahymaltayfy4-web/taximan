'use client';

import { useEffect, useState } from 'react';
import { doc, onSnapshot, collection, query, where, orderBy, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ArrowRight, User, Phone, Car, CreditCard, Star, MapPin } from 'lucide-react';
import { formatDate, formatCurrency, formatDistance } from '@/lib/utils';
import { DRIVER_STATUS_LABELS, RIDE_STATUS_LABELS, type DriverStatus, type RideStatus, type Driver, type Ride } from '@/lib/types';
import Link from 'next/link';
import { use } from 'react';

const rideStatusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', accepted: 'info', driver_arrived: 'info',
  started: 'default', completed: 'success', cancelled: 'destructive',
};

export default function DriverDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [driver, setDriver] = useState<Driver | null>(null);
  const [rides, setRides] = useState<Ride[]>([]);

  useEffect(() => {
    const unsub1 = onSnapshot(doc(db, 'drivers', id), (snap) => {
      if (snap.exists()) {
        const d = snap.data();
        setDriver({
          uid: snap.id, name: d.name || '', email: d.email || '', phone: d.phone || '',
          carModel: d.carModel || '', carPlate: d.carPlate || '', pricePerKm: d.pricePerKm || 0,
          status: d.status || 'offline', location: d.location ? { latitude: d.location.latitude, longitude: d.location.longitude } : null,
          rating: d.rating || 5.0, isBlocked: d.isBlocked || false, isDisabled: d.isDisabled || false,
          approvalStatus: d.approvalStatus || 'approved',
        });
      }
    });

    const q = query(collection(db, 'rides'), where('driverId', '==', id), orderBy('createdAt', 'desc'));
    const unsub2 = onSnapshot(q, (snap) => {
      setRides(snap.docs.map((d) => {
        const data = d.data();
        return {
          rideId: d.id, customerId: data.customerId, customerName: data.customerName || '',
          customerPhone: data.customerPhone || '', driverId: data.driverId || null,
          driverName: data.driverName || null, driverPhone: data.driverPhone || null,
          driverCarModel: data.driverCarModel || null, driverCarPlate: data.driverCarPlate || null,
          pickupLocation: { latitude: 0, longitude: 0 }, pickupAddress: data.pickupAddress || '',
          destinationLocation: { latitude: 0, longitude: 0 }, destinationAddress: data.destinationAddress || '',
          status: data.status, fare: data.fare || 0, distanceKm: data.distanceKm || 0,
          createdAt: (data.createdAt as Timestamp)?.toDate() || new Date(),
          acceptedAt: (data.acceptedAt as Timestamp)?.toDate() || null,
          completedAt: (data.completedAt as Timestamp)?.toDate() || null,
        };
      }));
    });

    return () => { unsub1(); unsub2(); };
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
        {/* Driver Info */}
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

        {/* Stats */}
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

      {/* Rides */}
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
