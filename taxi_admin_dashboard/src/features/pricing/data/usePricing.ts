'use client';

import { useEffect, useState } from 'react';
import { doc, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { mapPricingSettings } from '@/features/shared/mappers';
import type { PricingSettings } from '@/lib/types';

const DEFAULT_SETTINGS: PricingSettings = {
  defaultPricePerKm: 500, minimumFare: 500,
  commissionPercentage: 10, baseFare: 0,
  updatedAt: new Date(), updatedBy: '',
};

/** مراقبة إعدادات التسعير */
export function usePricing() {
  const [settings, setSettings] = useState<PricingSettings>(DEFAULT_SETTINGS);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'settings', 'pricing'), (snap) => {
      if (snap.exists()) {
        setSettings(mapPricingSettings(snap.data()));
      }
      setLoading(false);
    });
    return () => unsub();
  }, []);

  return { settings, setSettings, loading };
}
