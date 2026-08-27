'use client';

import { useEffect, useState } from 'react';
import { doc, onSnapshot, collection, query, where, orderBy, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ArrowRight, User, Mail, Phone, Calendar } from 'lucide-react';
import { formatDate, formatCurrency, formatDistance } from '@/lib/utils';
import { RIDE_STATUS_LABELS, type RideStatus, type Client, type Ride } from '@/lib/types';
import Link from 'next/link';
import { use } from 'react';

const statusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', accepted: 'info', driver_arrived: 'info',
  started: 'default', completed: 'success', cancelled: 'destructive',
};

export default function CustomerDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [client, setClient] = useState<Client | null>(null);
  const [rides, setRides] = useState<Ride[]>([]);

  useEffect(() => {
    const unsub1 = onSnapshot(doc(db, 'clients', id), (snap) => {
      if (snap.exists()) {
        const d = snap.data();
        setClient({
          uid: snap.id, name: d.name || '', email: d.email || '',
          phone: d.phone || '', createdAt: (d.createdAt as Timestamp)?.toDate() || new Date(),
          isBlocked: d.isBlocked || false, isDisabled: d.isDisabled || false,
        });
      }
    });

    const q = query(collection(db, 'rides'), where('customerId', '==', id), orderBy('createdAt', 'desc'));
    const unsub2 = onSnapshot(q, (snap) => {
      setRides(snap.docs.map((d) => {
        const data = d.data();
        return {
          rideId: d.id, customerId: data.customerId, customerName: data.customerName,
          customerPhone: data.customerPhone, driverId: data.driverId || null,
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

  if (!client) return <div className="flex items-center justify-center h-64 text-gray-400">جاري التحميل...</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Link href="/customers"><Button variant="ghost" size="icon"><ArrowRight className="h-5 w-5" /></Button></Link>
        <h1 className="text-3xl font-bold">تفاصيل العميل</h1>
      </div>

      {/* Client Info */}
      <Card>
        <CardHeader><CardTitle>المعلومات الشخصية</CardTitle></CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-[#5C0A2A]/10 p-2"><User className="h-5 w-5 text-[#5C0A2A]" /></div>
              <div><p className="text-xs text-gray-500">الاسم</p><p className="font-medium">{client.name}</p></div>
            </div>
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-blue-50 p-2"><Mail className="h-5 w-5 text-blue-600" /></div>
              <div><p className="text-xs text-gray-500">البريد</p><p className="font-medium" dir="ltr">{client.email}</p></div>
            </div>
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-green-50 p-2"><Phone className="h-5 w-5 text-green-600" /></div>
              <div><p className="text-xs text-gray-500">الهاتف</p><p className="font-medium" dir="ltr">{client.phone}</p></div>
            </div>
            <div className="flex items-center gap-3">
              <div className="rounded-full bg-purple-50 p-2"><Calendar className="h-5 w-5 text-purple-600" /></div>
              <div><p className="text-xs text-gray-500">تاريخ التسجيل</p><p className="font-medium">{formatDate(client.createdAt)}</p></div>
            </div>
          </div>
          <div className="mt-4">
            {client.isBlocked ? <Badge variant="destructive">محظور</Badge>
             : client.isDisabled ? <Badge variant="warning">معطل</Badge>
             : <Badge variant="success">نشط</Badge>}
          </div>
        </CardContent>
      </Card>

      {/* Rides History */}
      <Card>
        <CardHeader><CardTitle>سجل الرحلات ({rides.length})</CardTitle></CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-right p-3 font-medium text-gray-600">التاريخ</th>
                  <th className="text-right p-3 font-medium text-gray-600">الكابتن</th>
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
                    <td className="p-3">{ride.driverName || '-'}</td>
                    <td className="p-3 text-xs max-w-[150px] truncate">{ride.pickupAddress}</td>
                    <td className="p-3 text-xs max-w-[150px] truncate">{ride.destinationAddress}</td>
                    <td className="p-3">{formatDistance(ride.distanceKm)}</td>
                    <td className="p-3 font-semibold text-[#5C0A2A]">{formatCurrency(ride.fare)}</td>
                    <td className="p-3"><Badge variant={statusVariant[ride.status]}>{RIDE_STATUS_LABELS[ride.status]}</Badge></td>
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
