import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleNavigationShell extends StatelessWidget {
  const RoleNavigationShell({
    super.key,
    required this.role,
    required this.location,
    required this.child,
  });

  final String role;
  final String location;
  final Widget child;

  bool get _isDriver => role == 'driver';

  int get _selectedIndex {
    if (_isDriver) {
      if (location.startsWith('/driver/trips') ||
          location.startsWith('/driver/trip/')) {
        return 1;
      }
      if (location.startsWith('/driver/profile')) return 2;
      return 0;
    }
    if (location.startsWith('/passenger/bookings')) return 1;
    if (location.startsWith('/passenger/trips') ||
        location.startsWith('/passenger/trip/') ||
        location.startsWith('/passenger/booking/')) {
      return 2;
    }
    if (location.startsWith('/passenger/profile')) return 3;
    return 0;
  }

  List<NavigationDestination> get _destinations => _isDriver
      ? const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'My Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ]
      : const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.travel_explore_rounded),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ];

  List<String> get _locations => _isDriver
      ? const ['/driver/home', '/driver/trips', '/driver/profile']
      : const [
          '/passenger/home',
          '/passenger/bookings',
          '/passenger/trips',
          '/passenger/profile',
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (index) => context.go(_locations[index]),
      ),
    );
  }
}
