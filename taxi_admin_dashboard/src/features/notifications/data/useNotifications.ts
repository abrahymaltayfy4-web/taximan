'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, query, orderBy, limit } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapNotification } from '@/features/shared/mappers';
import type { AdminNotification } from '@/lib/types';

/** مراقبة سجل الإشعارات */
export function useNotifications(maxItems = 20) {
  const [history, setHistory] = useState<AdminNotification[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'notifications'), orderBy('sentAt', 'desc'), limit(maxItems));
    const unsub = onSnapshot(q, (snap) => {
      setHistory(snap.docs.map((d) => mapNotification(d.id, d.data())));
      setLoading(false);
    });
    return () => unsub();
  }, [maxItems]);

  return { history, loading };
}
