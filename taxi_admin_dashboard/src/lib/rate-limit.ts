/**
 * Rate Limiter بسيط في الذاكرة — يمنع الطلبات المتكررة
 * لكل IP أو UID خلال فترة زمنية محددة
 */
const store = new Map<string, { count: number; resetAt: number }>();

const CLEANUP_INTERVAL = 60_000; // تنظيف كل دقيقة
let lastCleanup = Date.now();

function cleanup() {
  const now = Date.now();
  if (now - lastCleanup < CLEANUP_INTERVAL) return;
  lastCleanup = now;
  for (const [key, entry] of store) {
    if (entry.resetAt < now) store.delete(key);
  }
}

/**
 * يتحقق من عدم تجاوز الحد المسموح
 * @returns true إذا مسموح، false إذا تم تجاوز الحد
 */
export function rateLimit(
  key: string,
  maxRequests: number,
  windowMs: number
): boolean {
  cleanup();
  const now = Date.now();
  const entry = store.get(key);

  if (!entry || entry.resetAt < now) {
    store.set(key, { count: 1, resetAt: now + windowMs });
    return true;
  }

  if (entry.count >= maxRequests) return false;

  entry.count++;
  return true;
}
