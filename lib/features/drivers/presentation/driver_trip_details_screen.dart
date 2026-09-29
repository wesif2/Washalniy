import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/route_timeline.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/presentation/providers/booking_providers.dart';
import '../../trips/domain/trip.dart';

class DriverTripDetailsScreen extends ConsumerWidget {
  const DriverTripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(tripBookingsProvider(trip.id));
    final stops = trip.displayedRouteStops;
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(tripBookingsProvider(trip.id)),
            child: const Text('Unable to load passengers. Retry'),
          ),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              trip.routeSummary,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('${trip.time} · ${trip.price} EGP · ${trip.status}'),
            const SizedBox(height: 20),
            const Text(
              'ROUTE AND SEGMENT OCCUPANCY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RouteTimeline(stops: stops),
            for (var index = 0; index < stops.length - 1; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '${stops[index]} → ${stops[index + 1]}: ${_seatsOnSegment(items, index)} passenger seat(s)',
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Passengers (${items.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('No bookings yet.'),
              ),
            for (final booking in items)
              Card(
                child: ListTile(
                  title: Text(booking.bookingCode),
                  subtitle: Text(
                    '${booking.pickupStopName ?? 'Pickup'} → ${booking.dropoffStopName ?? 'Drop-off'} · ${booking.seats} seat(s)',
                  ),
                  trailing: Text(booking.status),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _seatsOnSegment(List<Booking> bookings, int displayedSegmentIndex) {
    final startSequence = displayedSegmentIndex + 1;
    return bookings
        .where(
          (booking) =>
              booking.status == 'pending' ||
              booking.status == 'confirmed' ||
              booking.status == 'boarded' ||
              booking.status == 'completed',
        )
        .where(
          (booking) =>
              booking.pickupSequence != null &&
              booking.dropoffSequence != null &&
              booking.pickupSequence! <= startSequence &&
              booking.dropoffSequence! > startSequence,
        )
        .fold(0, (total, booking) => total + booking.seats);
  }
}
