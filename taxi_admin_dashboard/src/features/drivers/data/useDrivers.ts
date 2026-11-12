'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, doc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapDriver } from '@/features/shared/mappers';
import type { Driver } from '@/lib/types';

/** مراقبة جميع السائقين */
export function useDrivers() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'drivers'), (snap) => {
      const data = snap.docs.map((d) => mapDriver(d.id, d.data()));
      setDrivers(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return { drivers, loading };
}

/** مراقبة سائق واحد بالـ ID */
export function useDriver(id: string) {
  const [driver, setDriver] = useState<Driver | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'drivers', id), (snap) => {
      if (snap.exists()) {
        setDriver(mapDriver(snap.id, snap.data()));
      }
      setLoading(false);
    });
    return () => unsub();
  }, [id]);

  return { driver, loading };
}
