import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/trip.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stops = trip.displayedRouteStops;

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
                        '${trip.driverName} · ${trip.carModel}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'حالة السائق: ${trip.driverVerificationStatus}',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'المركبة: ${trip.carModel}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (trip.vehicleColor?.isNotEmpty ?? false)
                        Text('اللون: ${trip.vehicleColor}'),
                      Text('السعة: ${trip.seatCapacity} مقاعد'),
                      Text('السعر: ${trip.price} ج'),
                      const SizedBox(height: 8),
                      Text(
                        'المغادرة: ${trip.time}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'المسار',
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
              ...List.generate(stops.length, (index) {
                final stop = stops[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        index == stops.length - 1
                            ? Icons.location_on
                            : Icons.trip_origin,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(stop)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => context.push('/booking', extra: trip),
                child: const Text('احجز الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
