import { doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';

/** حظر/رفع حظر عميل */
export async function toggleClientBlock(uid: string, currentlyBlocked: boolean) {
  await updateDoc(doc(db, 'clients', uid), { isBlocked: !currentlyBlocked });
}

/** تعطيل/تفعيل عميل */
export async function toggleClientDisable(uid: string, currentlyDisabled: boolean) {
  await updateDoc(doc(db, 'clients', uid), { isDisabled: !currentlyDisabled });
}

/** حذف عميل */
export async function deleteClient(uid: string) {
  await deleteDoc(doc(db, 'clients', uid));
}
