'use client';

import { Search, Bell } from 'lucide-react';
import { Input } from '@/components/ui/input';

export default function Header() {
  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-gray-200 bg-white px-6">
      <div className="flex items-center gap-4">
        <div className="relative">
          <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
          <Input
            placeholder="بحث..."
            className="w-64 pr-10 text-right"
            dir="rtl"
          />
        </div>
      </div>
      <div className="flex items-center gap-4">
        <button className="relative rounded-full p-2 hover:bg-gray-100">
          <Bell className="h-5 w-5 text-gray-600" />
          <span className="absolute -top-0.5 -left-0.5 h-4 w-4 rounded-full bg-red-500 text-[10px] font-bold text-white flex items-center justify-center">
            3
          </span>
        </button>
        <div className="flex items-center gap-2">
          <div className="h-8 w-8 rounded-full bg-[#5C0A2A] flex items-center justify-center text-white text-sm font-bold">
            A
          </div>
          <span className="text-sm font-medium text-gray-700">المدير</span>
        </div>
      </div>
    </header>
  );
}
