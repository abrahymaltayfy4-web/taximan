import { adminDb } from './firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';

/**
 * تسجيل عملية في سجل المراجعة
 */
export async function auditLog(params: {
  action: string;
  adminUid: string;
  adminEmail: string;
  details: Record<string, unknown>;
  targetCollection?: string;
  targetId?: string;
}) {
  try {
    await adminDb.collection('audit_logs').add({
      action: params.action,
      adminUid: params.adminUid,
      adminEmail: params.adminEmail,
      targetCollection: params.targetCollection || null,
      targetId: params.targetId || null,
      details: params.details,
      timestamp: FieldValue.serverTimestamp(),
      ip: null, // يمكن إضافته لاحقاً
    });
  } catch (e) {
    // لا نوقف العملية إذا فشل التسجيل
    console.error('Audit log error:', e);
  }
}
