import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'providers/vehicle_providers.dart';

class VehicleManagementScreen extends ConsumerWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سياراتي'),
        backgroundColor: AppColors.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/add'),
        icon: const Icon(Icons.add),
        label: const Text('إضافة سيارة'),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذر تحميل السيارات'),
              TextButton(
                onPressed: () => ref.invalidate(myVehiclesProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(
              child: Text('لم يتم إضافة أي مركبات بعد.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car_rounded),
                  title: Text('${vehicle.make} ${vehicle.model}'),
                  subtitle: Text(
                    'لوحة: ${vehicle.plateNumber}\nالحالة: ${vehicle.verificationStatus}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
