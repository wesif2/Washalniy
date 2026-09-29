import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/driver_repository.dart';
import '../../domain/driver.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(Supabase.instance.client);
});

final currentDriverProvider = FutureProvider<Driver?>((ref) {
  return ref.watch(driverRepositoryProvider).getCurrentDriver();
});
