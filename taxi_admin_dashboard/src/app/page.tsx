'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, onSnapshot, getCountFromServer } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, Car, MapPin, CheckCircle, XCircle, Wifi } from 'lucide-react';
import { DashboardStats } from '@/lib/types';
import { formatCurrency } from '@/lib/utils';
import RecentRides from '@/components/dashboard/RecentRides';
import RidesChart from '@/components/dashboard/RidesChart';

const statCards = [
  { key: 'totalCustomers' as const, label: 'إجمالي العملاء', icon: Users, color: 'text-blue-600', bg: 'bg-blue-50' },
  { key: 'totalDrivers' as const, label: 'إجمالي السائقين', icon: Car, color: 'text-purple-600', bg: 'bg-purple-50' },
  { key: 'onlineDrivers' as const, label: 'السائقين المتصلين', icon: Wifi, color: 'text-green-600', bg: 'bg-green-50' },
  { key: 'activeRides' as const, label: 'الرحلات النشطة', icon: MapPin, color: 'text-orange-600', bg: 'bg-orange-50' },
  { key: 'completedRides' as const, label: 'الرحلات المكتملة', icon: CheckCircle, color: 'text-emerald-600', bg: 'bg-emerald-50' },
  { key: 'cancelledRides' as const, label: 'الرحلات الملغية', icon: XCircle, color: 'text-red-600', bg: 'bg-red-50' },
];

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    totalCustomers: 0,
    totalDrivers: 0,
    onlineDrivers: 0,
    activeRides: 0,
    completedRides: 0,
    cancelledRides: 0,
    totalRevenue: 0,
  });

  useEffect(() => {
    // Real-time listeners for each stat
    const unsubscribes: (() => void)[] = [];

    // العملاء
    const clientsUnsub = onSnapshot(collection(db, 'clients'), (snap) => {
      setStats((prev) => ({ ...prev, totalCustomers: snap.size }));
    });
    unsubscribes.push(clientsUnsub);

    // السائقين
    const driversUnsub = onSnapshot(collection(db, 'drivers'), (snap) => {
      setStats((prev) => ({ ...prev, totalDrivers: snap.size }));
    });
    unsubscribes.push(driversUnsub);

    // السائقين المتصلين
    const onlineQuery = query(collection(db, 'drivers'), where('status', '==', 'online'));
    const onlineUnsub = onSnapshot(onlineQuery, (snap) => {
      setStats((prev) => ({ ...prev, onlineDrivers: snap.size }));
    });
    unsubscribes.push(onlineUnsub);

    // الرحلات النشطة (pending, accepted, driver_arrived, started)
    const activeQuery = query(collection(db, 'rides'), where('status', 'in', ['pending', 'accepted', 'driver_arrived', 'started']));
    const activeUnsub = onSnapshot(activeQuery, (snap) => {
      setStats((prev) => ({ ...prev, activeRides: snap.size }));
    });
    unsubscribes.push(activeUnsub);

    // الرحلات المكتملة
    const completedQuery = query(collection(db, 'rides'), where('status', '==', 'completed'));
    const completedUnsub = onSnapshot(completedQuery, (snap) => {
      let revenue = 0;
      snap.forEach((doc) => {
        revenue += doc.data().fare || 0;
      });
      setStats((prev) => ({ ...prev, completedRides: snap.size, totalRevenue: revenue }));
    });
    unsubscribes.push(completedUnsub);

    // الرحلات الملغية
    const cancelledQuery = query(collection(db, 'rides'), where('status', '==', 'cancelled'));
    const cancelledUnsub = onSnapshot(cancelledQuery, (snap) => {
      setStats((prev) => ({ ...prev, cancelledRides: snap.size }));
    });
    unsubscribes.push(cancelledUnsub);

    return () => unsubscribes.forEach((unsub) => unsub());
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">لوحة التحكم</h1>
        <p className="text-gray-500 mt-1">نظرة عامة على نظام رحال</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {statCards.map((stat) => (
          <Card key={stat.key}>
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-500">{stat.label}</p>
                  <p className="text-3xl font-bold mt-1">
                    {stats[stat.key].toLocaleString('ar-SA')}
                  </p>
                </div>
                <div className={`rounded-full p-3 ${stat.bg}`}>
                  <stat.icon className={`h-6 w-6 ${stat.color}`} />
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Revenue Card */}
      <Card>
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-500">إجمالي الإيرادات</p>
              <p className="text-3xl font-bold mt-1 text-[#5C0A2A]">
                {formatCurrency(stats.totalRevenue)}
              </p>
            </div>
            <div className="rounded-full p-3 bg-[#5C0A2A]/10">
              <span className="text-2xl">💰</span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Charts + Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RidesChart />
        <RecentRides />
      </div>
    </div>
  );
}
