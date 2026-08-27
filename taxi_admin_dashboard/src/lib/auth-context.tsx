'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { User, onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '@/lib/firebase';
import { useRouter, usePathname } from 'next/navigation';

interface AuthContextType {
  user: User | null;
  adminName: string;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  adminName: '',
  loading: true,
});

export const useAuth = () => useContext(AuthContext);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [adminName, setAdminName] = useState('');
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        // تحقق أن المستخدم موجود في مجموعة admins
        const adminDoc = await getDoc(doc(db, 'admin', firebaseUser.uid));
        if (adminDoc.exists()) {
          setUser(firebaseUser);
          setAdminName(adminDoc.data()?.name || 'المدير');
          if (pathname === '/login') {
            router.push('/');
          }
        } else {
          // ليس admin — سجل خروج
          await auth.signOut();
          setUser(null);
          router.push('/login');
        }
      } else {
        setUser(null);
        if (pathname !== '/login') {
          router.push('/login');
        }
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [router, pathname]);

  return (
    <AuthContext.Provider value={{ user, adminName, loading }}>
      {children}
    </AuthContext.Provider>
  );
}
