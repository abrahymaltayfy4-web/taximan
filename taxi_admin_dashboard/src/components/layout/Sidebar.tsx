'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Car,
  MapPin,
  DollarSign,
  Bell,
  Map,
  LogOut,
  Wallet,
} from 'lucide-react';
import { auth } from '@/lib/firebase';
import { signOut } from 'firebase/auth';
import { useRouter } from 'next/navigation';

const menuItems = [
  { href: '/', label: 'لوحة التحكم', icon: LayoutDashboard },
  { href: '/customers', label: 'إدارة العملاء', icon: Users },
  { href: '/drivers', label: 'إدارة السائقين', icon: Car },
  { href: '/rides', label: 'مراقبة الرحلات', icon: MapPin },
  { href: '/map', label: 'خريطة السائقين', icon: Map },
  { href: '/pricing', label: 'التحكم بالأسعار', icon: DollarSign },
  { href: '/accounts', label: 'كشف الحسابات', icon: Wallet },
  { href: '/notifications', label: 'الإشعارات', icon: Bell },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = async () => {
    await signOut(auth);
    router.push('/login');
  };

  return (
    <aside className="fixed right-0 top-0 z-40 h-screen w-64 border-l border-gray-200 bg-white flex flex-col">
      {/* Logo */}
      <div className="flex h-16 items-center justify-center border-b border-gray-200 px-4">
        <h1 className="text-xl font-bold text-[#5C0A2A]">🚕 Rahal Admin</h1>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-1">
        {menuItems.map((item) => {
          const isActive = pathname === item.href || 
            (item.href !== '/' && pathname.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-[#5C0A2A] text-white'
                  : 'text-gray-700 hover:bg-gray-100'
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="border-t border-gray-200 p-4">
        <button
          onClick={handleLogout}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors cursor-pointer"
        >
          <LogOut className="h-5 w-5" />
          تسجيل الخروج
        </button>
      </div>
    </aside>
  );
}
