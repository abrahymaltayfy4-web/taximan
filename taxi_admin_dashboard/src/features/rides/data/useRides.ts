'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapRide } from '@/features/shared/mappers';
import type { Ride } from '@/lib/types';

/** مراقبة جميع الرحلات في الوقت الفعلي */
export function useRides() {
  const [rides, setRides] = useState<Ride[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'rides'), (snap) => {
      const data = snap.docs
        .map((d) => mapRide(d.id, d.data()))
        .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
      setRides(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return { rides, loading };
}
