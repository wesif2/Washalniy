import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/vehicle_repository.dart';
import '../../domain/vehicle.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(Supabase.instance.client);
});

final myVehiclesProvider = FutureProvider<List<Vehicle>>((ref) {
  return ref.watch(vehicleRepositoryProvider).fetchMyVehicles();
});
