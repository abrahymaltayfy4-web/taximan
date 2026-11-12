'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapClient } from '@/features/shared/mappers';
import type { Client } from '@/lib/types';

/** مراقبة جميع العملاء */
export function useCustomers() {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'clients'), (snap) => {
      const data = snap.docs.map((d) => mapClient(d.id, d.data()));
      setClients(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return { clients, loading };
}
