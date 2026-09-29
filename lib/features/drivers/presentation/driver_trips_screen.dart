import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../trips/presentation/providers/trip_providers.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(publishedTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('رحلاتي'),
        backgroundColor: AppColors.background,
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('تعذر تحميل الرحلات')),
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text('لا توجد رحلات حتى الآن.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                child: ListTile(
                  title: Text(trip.routeSummary),
                  subtitle: Text('${trip.time} · ${trip.driverName}'),
                  trailing: FilledButton(
                    onPressed: () {},
                    child: const Text('الركاب'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
