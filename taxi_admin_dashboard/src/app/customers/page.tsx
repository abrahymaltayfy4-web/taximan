'use client';

import { useEffect, useState } from 'react';
import { collection, onSnapshot, doc, updateDoc, deleteDoc, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Search, Eye, Ban, Trash2, ShieldOff, ShieldCheck } from 'lucide-react';
import { formatDate } from '@/lib/utils';
import type { Client } from '@/lib/types';
import Link from 'next/link';

export default function CustomersPage() {
  const [clients, setClients] = useState<Client[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'clients'), (snap) => {
      const data = snap.docs.map((d) => ({
        uid: d.id,
        name: d.data().name || '',
        email: d.data().email || '',
        phone: d.data().phone || '',
        createdAt: (d.data().createdAt as Timestamp)?.toDate() || new Date(),
        isBlocked: d.data().isBlocked || false,
        isDisabled: d.data().isDisabled || false,
      }));
      setClients(data);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const filtered = clients.filter((c) =>
    c.name.toLowerCase().includes(search.toLowerCase()) ||
    c.email.toLowerCase().includes(search.toLowerCase()) ||
    c.phone.includes(search)
  );

  const toggleBlock = async (uid: string, current: boolean) => {
    try {
      await updateDoc(doc(db, 'clients', uid), { isBlocked: !current });
    } catch (e) { console.error('Block error:', e); alert('فشل تحديث حالة الحظر'); }
  };

  const toggleDisable = async (uid: string, current: boolean) => {
    try {
      await updateDoc(doc(db, 'clients', uid), { isDisabled: !current });
    } catch (e) { console.error('Disable error:', e); alert('فشل تحديث حالة التعطيل'); }
  };

  const handleDelete = async (uid: string, name: string) => {
    if (confirm(`هل أنت متأكد من حذف العميل "${name}"؟`)) {
      try {
        await deleteDoc(doc(db, 'clients', uid));
      } catch (e) { console.error('Delete error:', e); alert('فشل حذف العميل'); }
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">إدارة العملاء</h1>
          <p className="text-gray-500 mt-1">{clients.length} عميل مسجل</p>
        </div>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <Input
          placeholder="بحث بالاسم أو الإيميل أو الهاتف..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pr-10"
        />
      </div>

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-right p-4 font-medium text-gray-600">الاسم</th>
                  <th className="text-right p-4 font-medium text-gray-600">البريد</th>
                  <th className="text-right p-4 font-medium text-gray-600">الهاتف</th>
                  <th className="text-right p-4 font-medium text-gray-600">تاريخ التسجيل</th>
                  <th className="text-right p-4 font-medium text-gray-600">الحالة</th>
                  <th className="text-right p-4 font-medium text-gray-600">إجراءات</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {loading ? (
                  <tr><td colSpan={6} className="text-center p-8 text-gray-400">جاري التحميل...</td></tr>
                ) : filtered.length === 0 ? (
                  <tr><td colSpan={6} className="text-center p-8 text-gray-400">لا توجد نتائج</td></tr>
                ) : (
                  filtered.map((client) => (
                    <tr key={client.uid} className="hover:bg-gray-50">
                      <td className="p-4 font-medium">{client.name}</td>
                      <td className="p-4 text-gray-600" dir="ltr">{client.email}</td>
                      <td className="p-4 text-gray-600" dir="ltr">{client.phone}</td>
                      <td className="p-4 text-gray-500 text-xs">{formatDate(client.createdAt)}</td>
                      <td className="p-4">
                        {client.isBlocked ? (
                          <Badge variant="destructive">محظور</Badge>
                        ) : client.isDisabled ? (
                          <Badge variant="warning">معطل</Badge>
                        ) : (
                          <Badge variant="success">نشط</Badge>
                        )}
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-1">
                          <Link href={`/customers/${client.uid}`}>
                            <Button variant="ghost" size="icon" title="عرض التفاصيل">
                              <Eye className="h-4 w-4" />
                            </Button>
                          </Link>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => toggleDisable(client.uid, client.isDisabled)}
                            title={client.isDisabled ? 'تفعيل' : 'تعطيل'}
                          >
                            {client.isDisabled ? <ShieldCheck className="h-4 w-4 text-green-600" /> : <ShieldOff className="h-4 w-4 text-yellow-600" />}
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => toggleBlock(client.uid, client.isBlocked)}
                            title={client.isBlocked ? 'رفع الحظر' : 'حظر'}
                          >
                            <Ban className={`h-4 w-4 ${client.isBlocked ? 'text-green-600' : 'text-red-600'}`} />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(client.uid, client.name)}
                            title="حذف"
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
