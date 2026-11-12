import { authFetch } from '@/lib/auth-fetch';

/**
 * مولد مفتاح Idempotency فريد
 */
function generateIdempotencyKey(): string {
  return `txn_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
}

/** تسجيل سداد عمولات (سند قبض) — عبر API خادمي محمي */
export async function recordPayment(params: {
  driverId: string;
  driverName: string;
  amount: number;
  note: string;
  adminEmail: string;
}) {
  const res = await authFetch('/api/financial-transaction', {
    type: 'payment',
    driverId: params.driverId,
    amount: params.amount,
    note: params.note || `سداد عمولات — ${params.amount.toFixed(0)} ريال`,
    idempotencyKey: generateIdempotencyKey(),
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'فشل تنفيذ العملية');
  return data;
}

/** إضافة رسوم على سائق (سند صرف) — عبر API خادمي محمي */
export async function recordCharge(params: {
  driverId: string;
  driverName: string;
  amount: number;
  note: string;
  adminEmail: string;
}) {
  const res = await authFetch('/api/financial-transaction', {
    type: 'charge',
    driverId: params.driverId,
    amount: params.amount,
    note: params.note || `إضافة رسوم — ${params.amount.toFixed(0)} ريال`,
    idempotencyKey: generateIdempotencyKey(),
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'فشل تنفيذ العملية');
  return data;
}
