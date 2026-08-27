'use client';

import { useEffect, useState } from 'react';
import { collection, query, where, onSnapshot, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface DayData {
  day: string;
  rides: number;
}

export default function RidesChart() {
  const [data, setData] = useState<DayData[]>([]);

  useEffect(() => {
    // جلب رحلات آخر 7 أيام
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const q = query(
      collection(db, 'rides'),
      where('createdAt', '>=', Timestamp.fromDate(sevenDaysAgo))
    );

    const unsub = onSnapshot(q, (snap) => {
      const dayMap: Record<string, number> = {};

      // تهيئة آخر 7 أيام
      for (let i = 6; i >= 0; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        const key = d.toLocaleDateString('ar-SA', { weekday: 'short' });
        dayMap[key] = 0;
      }

      snap.forEach((doc) => {
        const createdAt = (doc.data().createdAt as Timestamp)?.toDate();
        if (createdAt) {
          const key = createdAt.toLocaleDateString('ar-SA', { weekday: 'short' });
          if (key in dayMap) {
            dayMap[key]++;
          }
        }
      });

      const chartData = Object.entries(dayMap).map(([day, rides]) => ({ day, rides }));
      setData(chartData);
    });

    return () => unsub();
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">رحلات آخر 7 أيام</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-[250px]">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="day" tick={{ fontSize: 12 }} />
              <YAxis tick={{ fontSize: 12 }} allowDecimals={false} />
              <Tooltip
                contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
                labelStyle={{ fontWeight: 'bold' }}
              />
              <Bar dataKey="rides" name="الرحلات" fill="#5C0A2A" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}
