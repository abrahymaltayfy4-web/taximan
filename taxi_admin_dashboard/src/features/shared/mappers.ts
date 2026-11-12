import { Timestamp, GeoPoint } from 'firebase/firestore';
import type { Ride, Driver, Client, AdminNotification, PricingSettings, GeoLocation, RideStatus, DriverStatus, ApprovalStatus } from '@/lib/types';

// ═══════════════════════════════════════════
// Timestamp Mapper
// ═══════════════════════════════════════════
export function toDate(value: unknown): Date {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  return new Date();
}

export function toDateOrNull(value: unknown): Date | null {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  return null;
}

// ═══════════════════════════════════════════
// GeoPoint → GeoLocation Mapper
// ═══════════════════════════════════════════
export function toGeoLocation(value: unknown): GeoLocation {
  if (value && typeof value === 'object' && 'latitude' in value && 'longitude' in value) {
    const v = value as { latitude: number; longitude: number };
    return { latitude: v.latitude, longitude: v.longitude };
  }
  return { latitude: 0, longitude: 0 };
}

export function toGeoLocationOrNull(value: unknown): GeoLocation | null {
  if (value && typeof value === 'object' && 'latitude' in value) {
    return toGeoLocation(value);
  }
  return null;
}

// ═══════════════════════════════════════════
// Entity Mappers
// ═══════════════════════════════════════════
export function mapRide(id: string, raw: Record<string, unknown>): Ride {
  return {
    rideId: id,
    customerId: (raw.customerId as string) || '',
    customerName: (raw.customerName as string) || '',
    customerPhone: (raw.customerPhone as string) || '',
    driverId: (raw.driverId as string) || null,
    driverName: (raw.driverName as string) || null,
    driverPhone: (raw.driverPhone as string) || null,
    driverCarModel: (raw.driverCarModel as string) || null,
    driverCarPlate: (raw.driverCarPlate as string) || null,
    pickupLocation: toGeoLocation(raw.pickupLocation),
    pickupAddress: (raw.pickupAddress as string) || '',
    destinationLocation: toGeoLocation(raw.destinationLocation),
    destinationAddress: (raw.destinationAddress as string) || '',
    status: ((raw.status as string) || 'pending') as RideStatus,
    fare: (raw.fare as number) || 0,
    distanceKm: (raw.distanceKm as number) || 0,
    createdAt: toDate(raw.createdAt),
    acceptedAt: toDateOrNull(raw.acceptedAt),
    completedAt: toDateOrNull(raw.completedAt),
  };
}

export function mapDriver(id: string, raw: Record<string, unknown>): Driver {
  return {
    uid: id,
    name: (raw.name as string) || '',
    email: (raw.email as string) || '',
    phone: (raw.phone as string) || '',
    carModel: (raw.carModel as string) || '',
    carPlate: (raw.carPlate as string) || '',
    pricePerKm: (raw.pricePerKm as number) || 0,
    status: ((raw.status as string) || 'offline') as DriverStatus,
    location: toGeoLocationOrNull(raw.location),
    rating: (raw.rating as number) || 5.0,
    isBlocked: (raw.isBlocked as boolean) || false,
    isDisabled: (raw.isDisabled as boolean) || false,
    approvalStatus: ((raw.approvalStatus as string) || 'approved') as ApprovalStatus,
    totalCommissionOwed: (raw.totalCommissionOwed as number) || 0,
    totalPaid: (raw.totalPaid as number) || 0,
    createdAt: toDateOrNull(raw.createdAt) ?? undefined,
    lastUpdated: toDateOrNull(raw.lastUpdated) ?? undefined,
  };
}

export function mapClient(id: string, raw: Record<string, unknown>): Client {
  return {
    uid: id,
    name: (raw.name as string) || '',
    email: (raw.email as string) || '',
    phone: (raw.phone as string) || '',
    createdAt: toDate(raw.createdAt),
    isBlocked: (raw.isBlocked as boolean) || false,
    isDisabled: (raw.isDisabled as boolean) || false,
  };
}

export function mapNotification(id: string, raw: Record<string, unknown>): AdminNotification {
  return {
    id,
    title: (raw.title as string) || '',
    body: (raw.body as string) || '',
    target: (raw.target as AdminNotification['target']) || 'all_users',
    targetId: raw.targetId as string | undefined,
    targetName: raw.targetName as string | undefined,
    sentAt: toDate(raw.sentAt),
    sentBy: (raw.sentBy as string) || '',
  };
}

export function mapPricingSettings(raw: Record<string, unknown>): PricingSettings {
  return {
    defaultPricePerKm: (raw.defaultPricePerKm as number) ?? (raw.pricePerKm as number) ?? 500,
    minimumFare: (raw.minimumFare as number) ?? 500,
    commissionPercentage: (raw.commissionPercentage as number) ?? 10,
    baseFare: (raw.baseFare as number) ?? 0,
    updatedAt: toDate(raw.updatedAt),
    updatedBy: (raw.updatedBy as string) || '',
  };
}

export interface Transaction {
  id: string;
  type: 'commission' | 'payment';
  amount: number;
  rideFare: number;
  note: string;
  createdAt: Date;
}

export function mapTransaction(id: string, raw: Record<string, unknown>): Transaction {
  return {
    id,
    type: ((raw.type as string) || 'commission') as 'commission' | 'payment',
    amount: (raw.amount as number) || 0,
    rideFare: (raw.rideFare as number) || 0,
    note: (raw.note as string) || '',
    createdAt: toDate(raw.createdAt),
  };
}
