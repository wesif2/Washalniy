import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/bookings/domain/booking.dart';
import '../../features/bookings/presentation/booking_details_screen.dart';
import '../../features/bookings/presentation/booking_confirmation_screen.dart';
import '../../features/bookings/presentation/booking_screen.dart';
import '../../features/bookings/presentation/my_bookings_screen.dart';
import '../../features/drivers/presentation/driver_dashboard_screen.dart';
import '../../features/drivers/presentation/driver_onboarding_screen.dart';
import '../../features/drivers/presentation/driver_trips_screen.dart';
import '../../features/drivers/presentation/driver_trip_details_screen.dart';
import '../../features/role_select/presentation/role_select_screen.dart';
import '../../features/profiles/presentation/providers/profile_providers.dart';
import '../../features/profiles/presentation/profile_screen.dart';
import '../../features/profiles/presentation/settings_screen.dart';
import '../../features/trips/domain/trip.dart';
import '../../features/trips/presentation/create_trip_screen.dart';
import '../../features/trips/presentation/trip_details_screen.dart';
import '../../features/trips/presentation/trips_screen.dart';
import '../../features/trips/presentation/passenger_home_screen.dart';
import '../widgets/role_navigation_shell.dart';
import '../../features/vehicles/presentation/add_vehicle_screen.dart';
import '../../features/vehicles/presentation/vehicle_management_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authStateProvider, (previous, next) => refresh.notify());
  ref.listen(currentProfileProvider, (previous, next) => refresh.notify());
  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(currentProfileProvider);
      return resolveAuthRedirect(
        location: location,
        authLoading: authState.isLoading,
        authError: authState.hasError,
        hasUser: authState.asData?.value != null,
        profileLoading: profileState.isLoading,
        profileError: profileState.hasError,
        role: profileState.asData?.value?.role,
      );
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => RoleNavigationShell(
          role: 'passenger',
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/passenger/home',
            builder: (context, state) => const PassengerHomeScreen(),
          ),
          GoRoute(
            path: '/passenger/trips',
            builder: (context, state) => TripsScreen(
              routeId: state.uri.queryParameters['routeId'],
              from: state.uri.queryParameters['from'],
              to: state.uri.queryParameters['to'],
              date: state.uri.queryParameters['date'],
            ),
          ),
          GoRoute(
            path: '/passenger/trip/:id',
            builder: (context, state) => _tripDetails(
              state.extra,
              pickupStop: state.uri.queryParameters['from'],
              dropoffStop: state.uri.queryParameters['to'],
            ),
          ),
          GoRoute(
            path: '/passenger/bookings',
            builder: (context, state) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/passenger/booking',
            builder: (context, state) => _bookingScreen(state.extra),
          ),
          GoRoute(
            path: '/passenger/booking/:id',
            builder: (context, state) => _bookingDetails(state.extra),
          ),
          GoRoute(
            path: '/passenger/booking-confirmation',
            builder: (context, state) => _bookingConfirmation(state.extra),
          ),
          GoRoute(
            path: '/passenger/profile',
            builder: (context, state) => const ProfileScreen(isDriver: false),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => RoleNavigationShell(
          role: 'driver',
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/driver/home',
            builder: (context, state) => const DriverDashboardScreen(),
          ),
          GoRoute(
            path: '/driver/trips',
            builder: (context, state) => const DriverTripsScreen(),
          ),
          GoRoute(
            path: '/driver/trip/:id',
            builder: (context, state) => _driverTripDetails(state.extra),
          ),
          GoRoute(
            path: '/driver/create-trip',
            builder: (context, state) => const CreateTripScreen(),
          ),
          GoRoute(
            path: '/driver/profile',
            builder: (context, state) => const ProfileScreen(isDriver: true),
          ),
        ],
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/account-error',
        builder: (context, state) => const _ProfileLoadErrorScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

String? resolveAuthRedirect({
  required String location,
  required bool authLoading,
  required bool authError,
  required bool hasUser,
  required bool profileLoading,
  required bool profileError,
  required String? role,
}) {
  const entryLocations = {'/', '/splash', '/login', '/signup'};
  if (authLoading) return location == '/splash' ? null : '/splash';
  if (authError) return location == '/login' ? null : '/login';
  if (!hasUser) {
    return location == '/login' || location == '/signup' ? null : '/login';
  }
  if (profileLoading) return location == '/splash' ? null : '/splash';
  if (profileError) {
    return location == '/account-error' ? null : '/account-error';
  }
  if (role != 'passenger' && role != 'driver') {
    return location == '/role-selection' ? null : '/role-selection';
  }

  final home = role == 'driver' ? '/driver/home' : '/passenger/home';
  if (entryLocations.contains(location) ||
      location == '/role-selection' ||
      location == '/account-error') {
    return home;
  }
  if (role == 'driver' && _isPassengerLocation(location)) return home;
  if (role == 'passenger' && _isDriverLocation(location)) return home;
  return null;
}

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

Widget _tripDetails(Object? extra, {String? pickupStop, String? dropoffStop}) {
  if (extra is Trip) {
    return TripDetailsScreen(
      trip: extra,
      pickupStop: pickupStop,
      dropoffStop: dropoffStop,
    );
  }
  return const Scaffold(body: Center(child: Text('Trip details unavailable.')));
}

Widget _bookingScreen(Object? extra) {
  if (extra is Trip) return BookingScreen(trip: extra);
  return const Scaffold(body: Center(child: Text('Trip details unavailable.')));
}

Widget _bookingConfirmation(Object? extra) {
  if (extra is Booking) return BookingConfirmationScreen(booking: extra);
  return const Scaffold(
    body: Center(child: Text('Booking details unavailable.')),
  );
}

Widget _bookingDetails(Object? extra) {
  if (extra is Booking) return BookingDetailsScreen(booking: extra);
  return const Scaffold(
    body: Center(child: Text('Booking details unavailable.')),
  );
}

Widget _driverTripDetails(Object? extra) {
  if (extra is Trip) return DriverTripDetailsScreen(trip: extra);
  return const Scaffold(body: Center(child: Text('Trip details unavailable.')));
}

bool _isPassengerLocation(String location) =>
    location.startsWith('/passenger') ||
    const {
      '/trips',
      '/trip-details',
      '/booking',
      '/booking-confirmation',
      '/bookings',
    }.contains(location);

bool _isDriverLocation(String location) =>
    location.startsWith('/driver') ||
    const {
      '/driver-dashboard',
      '/driver-trips',
      '/driver-onboarding',
      '/trips/create',
      '/vehicles',
      '/vehicles/add',
    }.contains(location);

class _ProfileLoadErrorScreen extends ConsumerWidget {
  const _ProfileLoadErrorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load your profile.'),
            TextButton(
              onPressed: () => ref.invalidate(currentProfileProvider),
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

