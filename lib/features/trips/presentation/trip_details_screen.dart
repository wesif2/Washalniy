import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/route_timeline.dart';
import '../domain/trip.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({
    super.key,
    required this.trip,
    this.pickupStop,
    this.dropoffStop,
  });

  final Trip trip;
  final String? pickupStop;
  final String? dropoffStop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stops = trip.displayedRouteStops;
    final pickupIndex = pickupStop == null ? 0 : stops.indexOf(pickupStop!);
    final dropoffIndex = dropoffStop == null
        ? stops.length - 1
        : stops.indexOf(dropoffStop!);
    final availableSeats = trip.availableSeatsForDisplayRange(
      pickupIndex,
      dropoffIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الرحلة'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.driverName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trip.driverVerificationStatus == 'verified'
                            ? 'Verified Driver'
                            : 'Driver verification: ${trip.driverVerificationStatus}',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vehicle: ${trip.carModel}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (trip.vehicleColor?.isNotEmpty ?? false)
                        Text('Color: ${trip.vehicleColor}'),
                      if (trip.vehicleSeatCapacity > 0)
                        Text(
                          'Vehicle capacity: ${trip.vehicleSeatCapacity} seats',
                        ),
                      Text('Seats offered: ${trip.seatCapacity}'),
                      Text('Available on this segment: $availableSeats seats'),
                      Text('Price: ${trip.price} EGP'),
                      const SizedBox(height: 8),
                      Text(
                        'Departure: ${_departureLabel(trip)}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ROUTE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (trip.routeName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    trip.routeName,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              RouteTimeline(stops: stops),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () =>
                    context.push('/passenger/booking', extra: trip),
                child: const Text('Choose pickup and drop-off'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _departureLabel(Trip trip) {
  final departure = trip.departureDateTime?.toLocal();
  if (departure == null) return trip.time;
  final date =
      '${departure.day.toString().padLeft(2, '0')}/${departure.month.toString().padLeft(2, '0')}/${departure.year}';
  return '$date · ${trip.time}';
}
