import { initializeApp, getApps, cert, type App } from 'firebase-admin/app';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { getMessaging, type Messaging } from 'firebase-admin/messaging';
import { getAuth, type Auth } from 'firebase-admin/auth';

let _app: App;

function getAdminApp(): App {
  if (getApps().length > 0) return getApps()[0];
  const sa = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (sa) {
    _app = initializeApp({ credential: cert(JSON.parse(sa)) });
  } else {
    _app = initializeApp({ projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID });
  }
  return _app;
}

export const adminApp = getAdminApp();
export const adminDb: Firestore = getFirestore(adminApp);
export const adminAuth: Auth = getAuth(adminApp);
export const adminMessaging: Messaging = getMessaging(adminApp);
