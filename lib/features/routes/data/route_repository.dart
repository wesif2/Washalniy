import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/route_model.dart';

class RouteRepository {
  const RouteRepository(this._client);

  final SupabaseClient _client;

  Future<List<RouteModel>> fetchActiveRoutes() async {
    final rows = await _client
        .from('routes')
        .select('*, route_stops:route_stops(*)')
        .eq('is_active', true)
        .order('name');

    final routes = <RouteModel>[];
    for (final item in rows as List) {
      final map = Map<String, dynamic>.from(item as Map);
      routes.add(RouteModel.fromSupabase(map));
    }

    return routes;
  }
}
