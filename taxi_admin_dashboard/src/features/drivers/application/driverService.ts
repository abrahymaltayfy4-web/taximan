import { doc, updateDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

/** موافقة على سائق */
export async function approveDriver(uid: string) {
  await updateDoc(doc(db, 'drivers', uid), { approvalStatus: 'approved' });
}

/** رفض سائق */
export async function rejectDriver(uid: string) {
  await updateDoc(doc(db, 'drivers', uid), { approvalStatus: 'rejected' });
}

/** حظر/رفع حظر سائق */
export async function toggleDriverBlock(uid: string, currentlyBlocked: boolean) {
  await updateDoc(doc(db, 'drivers', uid), { isBlocked: !currentlyBlocked });
}

/** تعطيل/تفعيل سائق */
export async function toggleDriverDisable(uid: string, currentlyDisabled: boolean) {
  const updates: Record<string, unknown> = { isDisabled: !currentlyDisabled };
  if (!currentlyDisabled) updates.status = 'offline';
  await updateDoc(doc(db, 'drivers', uid), updates);
}
