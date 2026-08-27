'use client';

import { useEffect, useState, useCallback, useRef } from 'react';
import { collection, onSnapshot } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import type { DriverStatus } from '@/lib/types';
import { DRIVER_STATUS_LABELS } from '@/lib/types';

interface MapDriver {
  uid: string;
  name: string;
  status: DriverStatus;
  carModel: string;
  lat: number;
  lng: number;
}

const statusColors: Record<DriverStatus, string> = {
  online: '#22c55e',
  busy: '#eab308',
  offline: '#6b7280',
  suspended: '#ef4444',
};

const statusEmoji: Record<DriverStatus, string> = {
  online: '🟢',
  busy: '🟡',
  offline: '⚫',
  suspended: '🔴',
};

export default function MapPage() {
  const [drivers, setDrivers] = useState<MapDriver[]>([]);
  const [filter, setFilter] = useState<DriverStatus | 'all'>('all');
  const mapRef = useRef<HTMLDivElement>(null);
  const googleMapRef = useRef<google.maps.Map | null>(null);
  const markersRef = useRef<google.maps.marker.AdvancedMarkerElement[]>([]);

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'drivers'), (snap) => {
      const data: MapDriver[] = [];
      snap.forEach((d) => {
        const raw = d.data();
        if (raw.location) {
          data.push({
            uid: d.id,
            name: raw.name || 'سائق',
            status: (raw.status || 'offline') as DriverStatus,
            carModel: raw.carModel || '',
            lat: raw.location.latitude,
            lng: raw.location.longitude,
          });
        }
      });
      setDrivers(data);
    });
    return () => unsub();
  }, []);

  // Initialize Google Maps
  useEffect(() => {
    const initMap = async () => {
      if (!mapRef.current || googleMapRef.current) return;
      
      const script = document.createElement('script');
      script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=marker&v=weekly`;
      script.async = true;
      script.onload = () => {
        googleMapRef.current = new google.maps.Map(mapRef.current!, {
          center: { lat: 15.369445, lng: 44.191007 },
          zoom: 12,
          mapId: 'admin_map',
        });
      };
      document.head.appendChild(script);
    };
    initMap();
  }, []);

  // Update markers
  useEffect(() => {
    if (!googleMapRef.current) return;

    // Clear old markers
    markersRef.current.forEach((m) => (m.map = null));
    markersRef.current = [];

    const filtered = filter === 'all' ? drivers : drivers.filter((d) => d.status === filter);

    filtered.forEach((driver) => {
      const pin = document.createElement('div');
      pin.innerHTML = `<div style="background:${statusColors[driver.status]};color:white;padding:4px 8px;border-radius:12px;font-size:11px;font-weight:bold;white-space:nowrap;box-shadow:0 2px 6px rgba(0,0,0,0.3)">🚗 ${driver.name}</div>`;
      
      const marker = new google.maps.marker.AdvancedMarkerElement({
        map: googleMapRef.current!,
        position: { lat: driver.lat, lng: driver.lng },
        content: pin,
        title: `${driver.name} - ${DRIVER_STATUS_LABELS[driver.status]}`,
      });
      markersRef.current.push(marker);
    });
  }, [drivers, filter]);

  const counts = {
    all: drivers.length,
    online: drivers.filter((d) => d.status === 'online').length,
    busy: drivers.filter((d) => d.status === 'busy').length,
    offline: drivers.filter((d) => d.status === 'offline').length,
    suspended: drivers.filter((d) => d.status === 'suspended').length,
  };

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-3xl font-bold">خريطة السائقين</h1>
        <p className="text-gray-500 mt-1">مراقبة مواقع السائقين في الوقت الفعلي</p>
      </div>

      {/* Legend / Filters */}
      <div className="flex gap-2 flex-wrap">
        {(['all', 'online', 'busy', 'offline', 'suspended'] as const).map((key) => (
          <button key={key} onClick={() => setFilter(key)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors cursor-pointer ${
              filter === key ? 'bg-[#5C0A2A] text-white' : 'bg-white border border-gray-200 hover:bg-gray-50'
            }`}>
            {key === 'all' ? 'الكل' : `${statusEmoji[key]} ${DRIVER_STATUS_LABELS[key]}`} ({counts[key]})
          </button>
        ))}
      </div>

      {/* Map */}
      <Card>
        <CardContent className="p-0">
          <div ref={mapRef} className="w-full h-[600px] rounded-lg" />
        </CardContent>
      </Card>
    </div>
  );
}
