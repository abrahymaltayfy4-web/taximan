import { NextRequest } from 'next/server';
import { adminAuth, adminDb } from './firebase-admin';

export interface VerifiedAdmin {
  uid: string;
  email: string;
  name: string;
}

/**
 * يتحقق من أن الطلب من أدمن مصرّح:
 * 1. يستخرج Bearer token من الهيدر
 * 2. يتحقق منه عبر Firebase Admin Auth
 * 3. يتحقق من وجود المستخدم في مجموعة admin
 */
export async function verifyAdmin(request: NextRequest): Promise<VerifiedAdmin | null> {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) return null;

    const idToken = authHeader.slice(7);
    const decoded = await adminAuth.verifyIdToken(idToken);

    // التحقق من مجموعة admin
    const adminDoc = await adminDb.collection('admin').doc(decoded.uid).get();
    if (!adminDoc.exists) return null;

    return {
      uid: decoded.uid,
      email: decoded.email || '',
      name: adminDoc.data()?.name || 'admin',
    };
  } catch {
    return null;
  }
}
