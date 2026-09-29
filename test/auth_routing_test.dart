import 'package:flutter_test/flutter_test.dart';
import 'package:rides_app/core/router/app_router.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('waits on splash until Supabase resolves the session', () {
      expect(
        resolveAuthRedirect(
          location: '/',
          authLoading: true,
          authError: false,
          hasUser: false,
          profileLoading: true,
          profileError: false,
          role: null,
        ),
        '/splash',
      );
    });

    test('sends a signed-out user to Login and allows Sign Up', () {
      expect(_redirect(location: '/passenger/home', hasUser: false), '/login');
      expect(_redirect(location: '/login', hasUser: false), isNull);
      expect(_redirect(location: '/signup', hasUser: false), isNull);
    });

    test('waits for the current user profile before routing', () {
      expect(
        _redirect(location: '/login', profileLoading: true),
        '/splash',
      );
    });

    test('requires role selection when the authenticated profile has no role', () {
      expect(_redirect(location: '/passenger/home'), '/role-selection');
      expect(_redirect(location: '/role-selection'), isNull);
    });

    test('routes each saved role to its home and blocks the other role area', () {
      expect(_redirect(location: '/login', role: 'passenger'), '/passenger/home');
      expect(_redirect(location: '/driver/trips', role: 'passenger'), '/passenger/home');
      expect(_redirect(location: '/login', role: 'driver'), '/driver/home');
      expect(_redirect(location: '/passenger/bookings', role: 'driver'), '/driver/home');
      expect(_redirect(location: '/driver/trips', role: 'driver'), isNull);
      expect(_redirect(location: '/passenger/bookings', role: 'passenger'), isNull);
    });
  });
}

String? _redirect({
  required String location,
  bool hasUser = true,
  String? role,
  bool profileLoading = false,
}) => resolveAuthRedirect(
  location: location,
  authLoading: false,
  authError: false,
  hasUser: hasUser,
  profileLoading: profileLoading,
  profileError: false,
  role: role,
);
