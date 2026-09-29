import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/domain/trip.dart';
import '../../trips/presentation/providers/trip_providers.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(myTripsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Trips'),
          backgroundColor: AppColors.background,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: tripsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load your trips.'),
                TextButton(
                  onPressed: () => ref.invalidate(myTripsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (trips) => TabBarView(
            children: List.generate(4, (index) {
              final matchingTrips = trips.where((trip) => _matchesTab(trip, index)).toList();
              if (matchingTrips.isEmpty) {
                return Center(child: Text('No ${_tabName(index).toLowerCase()} trips.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: matchingTrips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, itemIndex) => _DriverTripCard(
                  trip: matchingTrips[itemIndex],
                  onTap: () => context.push(
                    '/driver/trip/${matchingTrips[itemIndex].id}',
                    extra: matchingTrips[itemIndex],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

bool _matchesTab(Trip trip, int index) {
  final status = trip.status.toLowerCase();
  switch (index) {
    case 0:
      return status == 'published' &&
          (trip.departureDateTime?.isAfter(DateTime.now()) ?? true);
    case 1:
      return status == 'boarding' || status == 'started';
    case 2:
      return status == 'completed';
    case 3:
      return status == 'cancelled';
    default:
      return false;
  }
}

String _tabName(int index) => const ['Upcoming', 'Active', 'Completed', 'Cancelled'][index];

class _DriverTripCard extends StatelessWidget {
  const _DriverTripCard({required this.trip, required this.onTap});

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final direction = trip.direction == 'reverse' ? 'Reverse' : 'Outbound';
    final departure = trip.departureDateTime?.toLocal();
    final date = departure == null
        ? 'Date unavailable'
        : '${departure.day}/${departure.month}/${departure.year}';
    return Card(
      child: ListTile(
        title: Text(trip.routeSummary),
        subtitle: Text(
          '$direction · $date · ${trip.time}\n${trip.carModel} · ${trip.status} · ${trip.price} EGP',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
