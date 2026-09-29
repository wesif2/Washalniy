import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/route_repository.dart';
import '../../domain/route_model.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(Supabase.instance.client);
});

final activeRoutesProvider = FutureProvider<List<RouteModel>>((ref) {
  return ref.watch(routeRepositoryProvider).fetchActiveRoutes();
});
