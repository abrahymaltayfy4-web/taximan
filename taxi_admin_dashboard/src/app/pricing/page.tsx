'use client';

import { useEffect, useState } from 'react';
import { doc, onSnapshot, setDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Save, DollarSign, Percent, MapPin, Flag } from 'lucide-react';
import type { PricingSettings } from '@/lib/types';
import { useAuth } from '@/lib/auth-context';

export default function PricingPage() {
  const { user } = useAuth();
  const [settings, setSettings] = useState<PricingSettings>({
    defaultPricePerKm: 500,
    minimumFare: 500,
    commissionPercentage: 10,
    baseFare: 0,
    updatedAt: new Date(),
    updatedBy: '',
  });
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'settings', 'pricing'), (snap) => {
      if (snap.exists()) {
        const d = snap.data();
        setSettings({
          defaultPricePerKm: d.defaultPricePerKm ?? d.pricePerKm ?? 500,
          minimumFare: d.minimumFare ?? 500,
          commissionPercentage: d.commissionPercentage ?? 10,
          baseFare: d.baseFare ?? 0,
          updatedAt: (d.updatedAt as Timestamp)?.toDate() || new Date(),
          updatedBy: d.updatedBy || '',
        });
      }
    });
    return () => unsub();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    await setDoc(doc(db, 'settings', 'pricing'), {
      ...settings,
      updatedAt: Timestamp.now(),
      updatedBy: user?.email || 'admin',
    });
    setSaving(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const fields = [
    { key: 'defaultPricePerKm' as const, label: 'سعر الكيلومتر الافتراضي', icon: MapPin, suffix: 'ريال/كم', color: 'text-blue-600', bg: 'bg-blue-50' },
    { key: 'minimumFare' as const, label: 'الحد الأدنى للسعر', icon: Flag, suffix: 'ريال', color: 'text-green-600', bg: 'bg-green-50' },
    { key: 'commissionPercentage' as const, label: 'نسبة العمولة', icon: Percent, suffix: '%', color: 'text-purple-600', bg: 'bg-purple-50' },
    { key: 'baseFare' as const, label: 'رسوم بدء الرحلة', icon: DollarSign, suffix: 'ريال', color: 'text-orange-600', bg: 'bg-orange-50' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">التحكم بالأسعار</h1>
        <p className="text-gray-500 mt-1">تعديل إعدادات التسعير للنظام</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl">
        {fields.map((field) => (
          <Card key={field.key}>
            <CardContent className="p-6">
              <div className="flex items-center gap-3 mb-4">
                <div className={`rounded-full p-2 ${field.bg}`}>
                  <field.icon className={`h-5 w-5 ${field.color}`} />
                </div>
                <label className="font-medium">{field.label}</label>
              </div>
              <div className="flex items-center gap-2">
                <Input
                  type="number"
                  step="0.5"
                  min="0"
                  value={settings[field.key]}
                  onChange={(e) => setSettings({ ...settings, [field.key]: parseFloat(e.target.value) || 0 })}
                  className="text-lg font-bold text-center"
                  dir="ltr"
                />
                <span className="text-sm text-gray-500 min-w-[50px]">{field.suffix}</span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="flex items-center gap-4">
        <Button variant="burgundy" onClick={handleSave} disabled={saving} className="min-w-[150px]">
          <Save className="h-4 w-4 ml-2" />
          {saving ? 'جاري الحفظ...' : 'حفظ التغييرات'}
        </Button>
        {saved && <span className="text-green-600 text-sm font-medium">✅ تم الحفظ بنجاح</span>}
      </div>
    </div>
  );
}
