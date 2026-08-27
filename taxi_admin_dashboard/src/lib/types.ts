// Firestore Collection Types for Rahal Taxi Admin Dashboard

// ============== Client (Customer) ==============
export interface Client {
  uid: string;
  name: string;
  email: string;
  phone: string;
  createdAt: Date;
  isBlocked: boolean;
  isDisabled: boolean;
}

// ============== Driver ==============
export interface Driver {
  uid: string;
  name: string;
  email: string;
  phone: string;
  carModel: string;
  carPlate: string;
  pricePerKm: number;
  status: DriverStatus;
  location: GeoLocation | null;
  rating: number;
  isBlocked: boolean;
  isDisabled: boolean;
  approvalStatus: ApprovalStatus;
  createdAt?: Date;
  lastUpdated?: Date;
}

export type DriverStatus = 'offline' | 'online' | 'busy' | 'suspended';
export type ApprovalStatus = 'pending' | 'approved' | 'rejected';

// ============== Ride ==============
export interface Ride {
  rideId: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  driverId: string | null;
  driverName: string | null;
  driverPhone: string | null;
  driverCarModel: string | null;
  driverCarPlate: string | null;
  pickupLocation: GeoLocation;
  pickupAddress: string;
  destinationLocation: GeoLocation;
  destinationAddress: string;
  status: RideStatus;
  fare: number;
  distanceKm: number;
  createdAt: Date;
  acceptedAt: Date | null;
  completedAt: Date | null;
}

export type RideStatus = 'pending' | 'accepted' | 'driver_arrived' | 'started' | 'completed' | 'cancelled';

// ============== Admin ==============
export interface Admin {
  uid: string;
  email: string;
  name: string;
  createdAt: Date;
}

// ============== Settings ==============
export interface PricingSettings {
  defaultPricePerKm: number;
  minimumFare: number;
  commissionPercentage: number;
  baseFare: number;
  updatedAt: Date;
  updatedBy: string;
}

// ============== Notification ==============
export interface AdminNotification {
  id: string;
  title: string;
  body: string;
  target: NotificationTarget;
  targetId?: string; // for specific user/driver
  targetName?: string;
  sentAt: Date;
  sentBy: string;
}

export type NotificationTarget = 'all_users' | 'all_drivers' | 'specific_user' | 'specific_driver';

// ============== GeoLocation ==============
export interface GeoLocation {
  latitude: number;
  longitude: number;
}

// ============== Dashboard Stats ==============
export interface DashboardStats {
  totalCustomers: number;
  totalDrivers: number;
  onlineDrivers: number;
  activeRides: number;
  completedRides: number;
  cancelledRides: number;
  totalRevenue: number;
}

// ============== Status Maps ==============
export const RIDE_STATUS_LABELS: Record<RideStatus, string> = {
  pending: 'في الانتظار',
  accepted: 'مقبولة',
  driver_arrived: 'الكابتن وصل',
  started: 'جارية',
  completed: 'مكتملة',
  cancelled: 'ملغية',
};

export const DRIVER_STATUS_LABELS: Record<DriverStatus, string> = {
  offline: 'غير متصل',
  online: 'متصل',
  busy: 'في رحلة',
  suspended: 'موقوف',
};

export const APPROVAL_STATUS_LABELS: Record<ApprovalStatus, string> = {
  pending: 'بانتظار الموافقة',
  approved: 'مقبول',
  rejected: 'مرفوض',
};
