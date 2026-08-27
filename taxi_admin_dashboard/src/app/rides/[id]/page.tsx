'use client';

import { useEffect, useState, useRef } from 'react';
import { doc, onSnapshot, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ArrowRight, User, Phone, Car, MapPin, Clock, DollarSign, Navigation } from 'lucide-react';
import { formatDate, formatCurrency, formatDistance } from '@/lib/utils';
import { RIDE_STATUS_LABELS, type RideStatus } from '@/lib/types';
import Link from 'next/link';
import { use } from 'react';

const statusVariant: Record<RideStatus, 'default' | 'info' | 'warning' | 'success' | 'destructive'> = {
  pending: 'warning', accepted: 'info', driver_arrived: 'info',
  started: 'default', completed: 'success', cancelled: 'destructive',
};

interface RideDetail {
  rideId: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  driverCarModel: string | null;
  driverCarPlate: string | null;
  pickupLat: number;
  pickupLng: number;
  pickupAddress: string;
  destLat: number;
  destLng: number;
  destinationAddress: string;
  status: RideStatus;
  fare: number;
  distanceKm: number;
  createdAt: Date;
  acceptedAt: Date | null;
  completedAt: Date | null;
}

export default function RideDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [ride, setRide] = useState<RideDetail | null>(null);
  const mapRef = useRef<HTMLDivElement>(null);
  const googleMapRef = useRef<google.maps.Map | null>(null);
  const markersRef = useRef<google.maps.marker.AdvancedMarkerElement[]>([]);
  const polylineRef = useRef<google.maps.Polyline | null>(null);
  const driverMarkerRef = useRef<google.maps.marker.AdvancedMarkerElement | null>(null);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'rides', id), (snap) => {
      if (!snap.exists()) return;
      const d = snap.data();
      const pickup = d.pickupLocation;
      const dest = d.destinationLocation;
      setRide({
        rideId: snap.id,
        customerId: d.customerId || '',
        customerName: d.customerName || 'عميل',
        customerPhone: d.customerPhone || '',
        driverId: d.driverId || null,
        driverName: d.driverName || null,
        driverPhone: d.driverPhone || null,
        driverCarModel: d.driverCarModel || null,
        driverCarPlate: d.driverCarPlate || null,
        pickupLat: pickup?.latitude || 0,
        pickupLng: pickup?.longitude || 0,
        pickupAddress: d.pickupAddress || '',
        destLat: dest?.latitude || 0,
        destLng: dest?.longitude || 0,
        destinationAddress: d.destinationAddress || '',
        status: d.status as RideStatus,
        fare: d.fare || 0,
        distanceKm: d.distanceKm || 0,
        createdAt: (d.createdAt as Timestamp)?.toDate() || new Date(),
        acceptedAt: (d.acceptedAt as Timestamp)?.toDate() || null,
        completedAt: (d.completedAt as Timestamp)?.toDate() || null,
      });
    });
    return () => unsub();
  }, [id]);

  // تهيئة الخريطة ورسم المسار
  useEffect(() => {
    if (!ride || !mapRef.current) return;
    if (ride.pickupLat === 0 && ride.pickupLng === 0) return;

    const initMap = () => {
      if (!mapRef.current) return;

      // إنشاء الخريطة
      if (!googleMapRef.current) {
        googleMapRef.current = new google.maps.Map(mapRef.current, {
          center: { lat: ride.pickupLat, lng: ride.pickupLng },
          zoom: 13,
          mapId: 'ride_detail_map',
        });
      }

      const map = googleMapRef.current;

      // مسح الماركرات القديمة
      markersRef.current.forEach((m) => (m.map = null));
      markersRef.current = [];
      polylineRef.current?.setMap(null);

      // ماركر نقطة البداية (أخضر)
      const pickupPin = document.createElement('div');
      pickupPin.innerHTML = `<div style="background:#22c55e;color:white;padding:6px 12px;border-radius:16px;font-size:12px;font-weight:bold;box-shadow:0 2px 8px rgba(0,0,0,0.3)">📍 نقطة البداية</div>`;
      const pickupMarker = new google.maps.marker.AdvancedMarkerElement({
        map, position: { lat: ride.pickupLat, lng: ride.pickupLng }, content: pickupPin,
      });
      markersRef.current.push(pickupMarker);

      // ماركر الوجهة (أحمر)
      const destPin = document.createElement('div');
      destPin.innerHTML = `<div style="background:#ef4444;color:white;padding:6px 12px;border-radius:16px;font-size:12px;font-weight:bold;box-shadow:0 2px 8px rgba(0,0,0,0.3)">🏁 الوجهة</div>`;
      const destMarker = new google.maps.marker.AdvancedMarkerElement({
        map, position: { lat: ride.destLat, lng: ride.destLng }, content: destPin,
      });
      markersRef.current.push(destMarker);

      // رسم المسار الحقيقي بين البداية والوجهة
      const directionsService = new google.maps.DirectionsService();
      const directionsRenderer = new google.maps.DirectionsRenderer({
        map,
        suppressMarkers: true,
        polylineOptions: {
          strokeColor: '#5C0A2A',
          strokeWeight: 5,
          strokeOpacity: 0.8,
        },
      });

      directionsService.route(
        {
          origin: { lat: ride.pickupLat, lng: ride.pickupLng },
          destination: { lat: ride.destLat, lng: ride.destLng },
          travelMode: google.maps.TravelMode.DRIVING,
        },
        (result, status) => {
          if (status === 'OK' && result) {
            directionsRenderer.setDirections(result);
          } else {
            // fallback: خط مستقيم
            const line = new google.maps.Polyline({
              path: [
                { lat: ride.pickupLat, lng: ride.pickupLng },
                { lat: ride.destLat, lng: ride.destLng },
              ],
              strokeColor: '#5C0A2A',
              strokeWeight: 4,
              map,
            });
            polylineRef.current = line;
          }
        }
      );

      // ضبط حدود الخريطة
      const bounds = new google.maps.LatLngBounds();
      bounds.extend({ lat: ride.pickupLat, lng: ride.pickupLng });
      bounds.extend({ lat: ride.destLat, lng: ride.destLng });
      map.fitBounds(bounds, 60);

      // للرحلات الجارية: تتبع موقع السائق
      if ((ride.status === 'started' || ride.status === 'accepted' || ride.status === 'driver_arrived') && ride.driverId) {
        // استمع لموقع السائق
        const driverUnsub = onSnapshot(doc(db, 'drivers', ride.driverId), (driverSnap) => {
          const driverData = driverSnap.data();
          if (driverData?.location) {
            const driverLat = driverData.location.latitude;
            const driverLng = driverData.location.longitude;

            // تحديث أو إنشاء ماركر السائق
            if (driverMarkerRef.current) {
              driverMarkerRef.current.position = { lat: driverLat, lng: driverLng };
            } else {
              const driverPin = document.createElement('div');
              driverPin.innerHTML = `<div style="background:#3b82f6;color:white;padding:6px 12px;border-radius:16px;font-size:12px;font-weight:bold;box-shadow:0 2px 8px rgba(0,0,0,0.3)">🚗 ${ride.driverName || 'السائق'}</div>`;
              driverMarkerRef.current = new google.maps.marker.AdvancedMarkerElement({
                map, position: { lat: driverLat, lng: driverLng }, content: driverPin,
              });
            }
          }
        });

        return () => driverUnsub();
      }
    };

    // تحميل Google Maps إذا لم يكن محملاً
    if (typeof google !== 'undefined' && google.maps) {
      initMap();
    } else {
      const script = document.createElement('script');
      script.src = `https://maps.googleapis.com/maps/api/js?key=${process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY}&libraries=marker&v=weekly`;
      script.async = true;
      script.onload = initMap;
      document.head.appendChild(script);
    }
  }, [ride]);

  if (!ride) return <div className="flex items-center justify-center h-64 text-gray-400">جاري التحميل...</div>;

  const isActive = ['accepted', 'driver_arrived', 'started'].includes(ride.status);

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Link href="/rides"><Button variant="ghost" size="icon"><ArrowRight className="h-5 w-5" /></Button></Link>
        <h1 className="text-3xl font-bold">تفاصيل الرحلة</h1>
        <Badge variant={statusVariant[ride.status]} className="text-base px-4 py-1">
          {RIDE_STATUS_LABELS[ride.status]}
        </Badge>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* الخريطة */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Navigation className="h-5 w-5 text-[#5C0A2A]" />
              {isActive ? 'التتبع المباشر' : 'مسار الرحلة'}
              {isActive && <span className="inline-block h-2 w-2 rounded-full bg-green-500 animate-pulse"></span>}
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <div ref={mapRef} className="w-full h-[450px] rounded-b-lg" />
          </CardContent>
        </Card>

        {/* التفاصيل الجانبية */}
        <div className="space-y-4">
          {/* معلومات العميل */}
          <Card>
            <CardHeader className="pb-3"><CardTitle className="text-base">👤 العميل</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center gap-2">
                <User className="h-4 w-4 text-gray-400" />
                <span className="font-medium">{ride.customerName}</span>
              </div>
              <div className="flex items-center gap-2">
                <Phone className="h-4 w-4 text-gray-400" />
                <span dir="ltr">{ride.customerPhone}</span>
              </div>
            </CardContent>
          </Card>

          {/* معلومات السائق */}
          {ride.driverId && (
            <Card>
              <CardHeader className="pb-3"><CardTitle className="text-base">🚗 السائق</CardTitle></CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center gap-2">
                  <User className="h-4 w-4 text-gray-400" />
                  <Link href={`/drivers/${ride.driverId}`} className="font-medium text-[#5C0A2A] hover:underline">
                    {ride.driverName}
                  </Link>
                </div>
                <div className="flex items-center gap-2">
                  <Phone className="h-4 w-4 text-gray-400" />
                  <span dir="ltr">{ride.driverPhone}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Car className="h-4 w-4 text-gray-400" />
                  <span>{ride.driverCarModel} — <span className="font-mono">{ride.driverCarPlate}</span></span>
                </div>
              </CardContent>
            </Card>
          )}

          {/* تفاصيل الرحلة */}
          <Card>
            <CardHeader className="pb-3"><CardTitle className="text-base">📋 تفاصيل</CardTitle></CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center gap-2">
                <div className="h-3 w-3 rounded-full bg-green-500"></div>
                <div>
                  <p className="text-xs text-gray-500">نقطة البداية</p>
                  <p className="text-sm font-medium">{ride.pickupAddress}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <div className="h-3 w-3 rounded-full bg-red-500"></div>
                <div>
                  <p className="text-xs text-gray-500">الوجهة</p>
                  <p className="text-sm font-medium">{ride.destinationAddress}</p>
                </div>
              </div>
              <div className="border-t pt-3 space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500 flex items-center gap-1"><MapPin className="h-3 w-3" /> المسافة</span>
                  <span className="font-medium">{formatDistance(ride.distanceKm)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500 flex items-center gap-1"><DollarSign className="h-3 w-3" /> السعر</span>
                  <span className="font-bold text-[#5C0A2A]">{formatCurrency(ride.fare)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500 flex items-center gap-1"><Clock className="h-3 w-3" /> وقت الطلب</span>
                  <span>{formatDate(ride.createdAt)}</span>
                </div>
                {ride.acceptedAt && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">وقت القبول</span>
                    <span>{formatDate(ride.acceptedAt)}</span>
                  </div>
                )}
                {ride.completedAt && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-500">وقت الإكمال</span>
                    <span>{formatDate(ride.completedAt)}</span>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
