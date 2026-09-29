import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/trip.dart';
import 'providers/trip_providers.dart';
import 'widgets/day_filter_chips.dart';
import 'widgets/trip_card.dart';
import 'widgets/trip_search_field.dart';
import 'widgets/trips_header.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key, this.routeId, this.from, this.to, this.date});

  final String? routeId;
  final String? from;
  final String? to;
  final String? date;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TripSearchField(
                onTap: () => context.go('/passenger/home'),
              ),
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
                  final matchingTrips = trips.where(_matchesSearch).toList();
                  if (matchingTrips.isEmpty) {
                    return const Center(child: Text('No trips available.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: matchingTrips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      final trip = matchingTrips[i];
                      return GestureDetector(
                        onTap: () => context.push(
                          Uri(
                            path: '/passenger/trip/${trip.id}',
                            queryParameters: {
                              if (widget.from != null) 'from': widget.from!,
                              if (widget.to != null) 'to': widget.to!,
                            },
                          ).toString(),
                          extra: trip,
                        ),
                        child: TripCard(
                          trip: trip,
                          routeLabel: widget.from != null && widget.to != null
                              ? '${widget.from} → ${widget.to}'
                              : null,
                          pickupStop: widget.from,
                          dropoffStop: widget.to,
                          onBook: () => context.push(
                            Uri(
                              path: '/passenger/trip/${trip.id}',
                              queryParameters: {
                                if (widget.from != null) 'from': widget.from!,
                                if (widget.to != null) 'to': widget.to!,
                              },
                            ).toString(),
                            extra: trip,
                          ),
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

  bool _matchesSearch(Trip trip) {
    if (widget.routeId != null && trip.routeId != widget.routeId) return false;
    if (widget.date != null) {
      final requestedDate = DateTime.tryParse(widget.date!);
      final departure = trip.departureDateTime?.toLocal();
      if (requestedDate == null || departure == null) return false;
      if (departure.year != requestedDate.year ||
          departure.month != requestedDate.month ||
          departure.day != requestedDate.day) {
        return false;
      }
    }
    final from = widget.from;
    final to = widget.to;
    if (from == null || to == null) return true;
    final stops = trip.displayedRouteStops;
    final pickupIndex = stops.indexOf(from);
    final dropoffIndex = stops.indexOf(to);
    return pickupIndex >= 0 && dropoffIndex > pickupIndex;
  }
}
