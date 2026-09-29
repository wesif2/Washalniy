import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/bookings/domain/booking.dart';
import '../../features/bookings/presentation/booking_confirmation_screen.dart';
import '../../features/bookings/presentation/booking_screen.dart';
import '../../features/bookings/presentation/my_bookings_screen.dart';
import '../../features/drivers/presentation/driver_dashboard_screen.dart';
import '../../features/drivers/presentation/driver_onboarding_screen.dart';
import '../../features/drivers/presentation/driver_trips_screen.dart';
import '../../features/role_select/presentation/role_select_screen.dart';
import '../../features/trips/domain/trip.dart';
import '../../features/trips/presentation/create_trip_screen.dart';
import '../../features/trips/presentation/trip_details_screen.dart';
import '../../features/trips/presentation/trips_screen.dart';
import '../../features/vehicles/presentation/add_vehicle_screen.dart';
import '../../features/vehicles/presentation/vehicle_management_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RoleSelectScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/trips', builder: (context, state) => const TripsScreen()),
      GoRoute(
        path: '/driver-dashboard',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: '/driver-onboarding',
        builder: (context, state) => const DriverOnboardingScreen(),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => const VehicleManagementScreen(),
      ),
      GoRoute(
        path: '/vehicles/add',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/trips/create',
        builder: (context, state) => const CreateTripScreen(),
      ),
      GoRoute(
        path: '/trip-details',
        builder: (context, state) {
          final trip = state.extra;
          if (trip is! Trip) {
            return const Scaffold(
              body: Center(child: Text('لا توجد بيانات رحلة.')),
            );
          }
          return TripDetailsScreen(trip: trip);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final trip = state.extra;
          if (trip is! Trip) {
            return const Scaffold(
              body: Center(child: Text('لا توجد بيانات رحلة.')),
            );
          }
          return BookingScreen(trip: trip);
        },
      ),
      GoRoute(
        path: '/booking-confirmation',
        builder: (context, state) {
          final booking = state.extra;
          if (booking == null) {
            return const Scaffold(
              body: Center(child: Text('لا توجد بيانات حجز.')),
            );
          }
          return BookingConfirmationScreen(booking: booking as Booking);
        },
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/driver-trips',
        builder: (context, state) => const DriverTripsScreen(),
      ),
    ],
  );
});
