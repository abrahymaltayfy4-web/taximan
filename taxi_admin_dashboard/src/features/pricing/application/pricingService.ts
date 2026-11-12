import { doc, setDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import type { PricingSettings } from '@/lib/types';

/** حفظ إعدادات التسعير */
export async function savePricingSettings(settings: PricingSettings, adminEmail: string) {
  await setDoc(doc(db, 'settings', 'pricing'), {
    ...settings,
    pricePerKm: settings.defaultPricePerKm, // اسم موحد للتطبيقات
    updatedAt: Timestamp.now(),
    updatedBy: adminEmail,
  });
}
