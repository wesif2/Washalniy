import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../../drivers/presentation/providers/driver_providers.dart';
import '../../vehicles/presentation/providers/vehicle_providers.dart';
import 'providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.isDriver});

  final bool isDriver;

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final authUser = ref.watch(currentUserProvider).asData?.value;
    final driver = isDriver ? ref.watch(currentDriverProvider) : null;
    final vehicles = isDriver ? ref.watch(myVehiclesProvider) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(currentProfileProvider),
            child: const Text('Unable to load profile. Retry'),
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 34,
              child: Text(
                (value?.fullName?.isNotEmpty ?? false)
                    ? value!.fullName!.substring(0, 1).toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value?.fullName ?? 'Name not provided',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if ((value?.email ?? authUser?.email) != null)
              Text(value?.email ?? authUser!.email, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Account type'),
              subtitle: Text(value?.role ?? 'Role unavailable'),
            ),
            if (isDriver)
              driver!.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Verification status'),
                  subtitle: LinearProgressIndicator(),
                ),
                error: (error, stack) => const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Verification status unavailable'),
                ),
                data: (value) => ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Verification status'),
                  subtitle: Text(value?.verificationStatus ?? 'Not submitted'),
                ),
              ),
            if (isDriver)
              vehicles!.when(
                loading: () => const ListTile(
                  leading: Icon(Icons.directions_car_outlined),
                  title: Text('Vehicle'),
                  subtitle: LinearProgressIndicator(),
                ),
                error: (error, stack) => const ListTile(
                  leading: Icon(Icons.directions_car_outlined),
                  title: Text('Vehicle information unavailable'),
                ),
                data: (items) => ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: const Text('Vehicle'),
                  subtitle: Text(items.isEmpty
                      ? 'No vehicle added'
                      : '${items.first.make} ${items.first.model} · ${items.first.seatCapacity} seats'),
                ),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Personal Information'),
              subtitle: Text(value?.phone ?? 'Contact information not added'),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Personal Information'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${value?.fullName ?? 'Not provided'}'),
                      Text('Email: ${value?.email ?? 'Not provided'}'),
                      Text('Phone: ${value?.phone ?? 'Not provided'}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Notification preferences are not connected yet'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification preferences are not available yet.')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('Language'),
              onTap: () => context.push('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
