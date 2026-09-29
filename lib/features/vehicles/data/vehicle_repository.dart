import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/vehicle.dart';

class VehicleRepository {
  const VehicleRepository(this._client);

  final SupabaseClient _client;

  Future<List<Vehicle>> fetchMyVehicles() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const <Vehicle>[];
    }

    final driverId = await _driverIdForCurrentUser(required: false);
    if (driverId == null) return const <Vehicle>[];

    final rows = await _client
        .from('vehicles')
        .select()
        .eq('driver_id', driverId)
        .order('created_at');

    return (rows as List)
        .map((row) => Vehicle.fromSupabase(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Vehicle> addVehicle({
    required String make,
    required String model,
    String? color,
    required String plateNumber,
    required int seatCapacity,
  }) async {
    final driverId = await _driverIdForCurrentUser();

    final response = await _client
        .from('vehicles')
        .insert({
          'driver_id': driverId,
          'make': make,
          'model': model,
          'color': color,
          'plate_number': plateNumber,
          'seat_capacity': seatCapacity,
          'verification_status': 'pending',
        })
        .select()
        .single();

    return Vehicle.fromSupabase(response);
  }

  Future<String?> _driverIdForCurrentUser({bool required = true}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Authentication required');
    }

    final row = await _client
        .from('drivers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null || row['id'] == null) {
      if (!required) return null;
      throw StateError('Driver profile not found');
    }

    return row['id'].toString();
  }
}
