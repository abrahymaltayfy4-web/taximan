'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, query, where, doc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapTransaction } from '@/features/shared/mappers';
import type { Transaction } from '@/features/shared/mappers';

/** مراقبة معاملات سائق محدد */
export function useDriverTransactions(driverId: string) {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, 'transactions'), where('driverId', '==', driverId));
    const unsub = onSnapshot(q, (snap) => {
      const txList = snap.docs
        .map((d) => mapTransaction(d.id, d.data()))
        .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
      setTransactions(txList);
      setLoading(false);
    }, () => setLoading(false));
    return () => unsub();
  }, [driverId]);

  return { transactions, loading };
}

export type { Transaction };
