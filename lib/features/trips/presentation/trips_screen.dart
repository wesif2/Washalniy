import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/trip_providers.dart';
import 'widgets/day_filter_chips.dart';
import 'widgets/trip_card.dart';
import 'widgets/trip_search_field.dart';
import 'widgets/trips_header.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  static const _dayLabels = ['النهارده', 'بكرة', 'الأسبوع ده'];

  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final asyncTrips = ref.watch(publishedTripsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: TripsHeader(city: 'منية النصر'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: TripSearchField(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: DayFilterChips(
                labels: _dayLabels,
                selectedIndex: _selectedDay,
                onSelected: (i) => setState(() => _selectedDay = i),
              ),
            ),
            Expanded(
              child: asyncTrips.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load trips.'),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () =>
                              ref.invalidate(publishedTripsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (trips) {
                  if (trips.isEmpty) {
                    return const Center(child: Text('No trips available.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: trips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final trip = trips[i];
                      return GestureDetector(
                        onTap: () => context.push('/trip-details', extra: trip),
                        child: TripCard(
                          trip: trip,
                          onBook: () => context.push('/booking', extra: trip),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
