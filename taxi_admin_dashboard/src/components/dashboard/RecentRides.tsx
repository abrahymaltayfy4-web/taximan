'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, orderBy, limit, onSnapshot, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { RIDE_STATUS_LABELS, type RideStatus } from '@/lib/types';
import { formatDate, formatCurrency } from '@/lib/utils';

interface RecentRide {
  id: string;
  customerName: string;
  driverName: string | null;
  status: RideStatus;
  fare: number;
  createdAt: Date;
}

const statusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning',
  accepted: 'info',
  driver_arrived: 'info',
  started: 'default',
  completed: 'success',
  cancelled: 'destructive',
};

export default function RecentRides() {
  const [rides, setRides] = useState<RecentRide[]>([]);

  useEffect(() => {
    const q = query(collection(db, 'rides'), orderBy('createdAt', 'desc'), limit(10));
    const unsub = onSnapshot(q, (snap) => {
      const data = snap.docs.map((doc) => {
        const d = doc.data();
        return {
          id: doc.id,
          customerName: d.customerName || 'عميل',
          driverName: d.driverName || null,
          status: d.status as RideStatus,
          fare: d.fare || 0,
          createdAt: (d.createdAt as Timestamp)?.toDate() || new Date(),
        };
      });
      setRides(data);
    });
    return () => unsub();
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">آخر الرحلات</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          {rides.length === 0 ? (
            <p className="text-gray-400 text-center py-4">لا توجد رحلات</p>
          ) : (
            rides.map((ride) => (
              <div key={ride.id} className="flex items-center justify-between border-b border-gray-50 pb-3 last:border-0">
                <div className="flex-1">
                  <p className="text-sm font-medium">{ride.customerName}</p>
                  <p className="text-xs text-gray-400">
                    {ride.driverName ? `الكابتن: ${ride.driverName}` : 'بانتظار كابتن'}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <Badge variant={statusVariant[ride.status]}>
                    {RIDE_STATUS_LABELS[ride.status]}
                  </Badge>
                  <span className="text-sm font-semibold text-[#5C0A2A] min-w-[70px] text-left">
                    {formatCurrency(ride.fare)}
                  </span>
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  );
}
