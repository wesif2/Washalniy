import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/trip.dart';

class TripRepository {
  const TripRepository(this._client);

  final SupabaseClient _client;

  Future<List<Trip>> fetchPublishedTrips() async {
    try {
      final response = await _client
          .from('trip_browse')
          .select()
          .order('departure_time');

      final rows = (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
      return parsePublicBrowseRows(rows);
    } catch (error, stackTrace) {
      developer.log(
        'Unable to fetch published trips from Supabase.',
        name: 'TripRepository',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Trip>> fetchMyTrips() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];

    final driver = await _client
        .from('drivers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (driver == null) return const [];

    final response = await _client
        .from('trips')
        .select(
          '*, route:routes(*, route_stops:route_stops(*)), vehicle:vehicles(*), driver:drivers(*, profile:profiles(*))',
        )
        .eq('driver_id', driver['id'])
        .order('departure_time');
    final rows = (response as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    return parseTrips(rows);
  }

  Future<String> createTrip({
    required String driverId,
    required String vehicleId,
    required String routeId,
    required String direction,
    required DateTime departureTime,
    required int seatCapacity,
    required double price,
    required String notes,
  }) async {
    final result = await _client.rpc(
      'create_trip',
      params: {
        'p_driver_id': driverId,
        'p_vehicle_id': vehicleId,
        'p_route_id': routeId,
        'p_direction': direction,
        'p_departure_time': departureTime.toUtc().toIso8601String(),
        'p_seat_capacity': seatCapacity,
        'p_price': price,
        'p_status': 'published',
        'p_notes': notes,
      },
    );
    if (result is! String) throw StateError('Trip was not created');
    return result;
  }

  static List<Trip> parseTrips(Iterable<Map<String, dynamic>> rows) {
    final trips = <Trip>[];
    for (final row in rows) {
      try {
        trips.add(Trip.fromSupabase(row));
      } catch (error, stackTrace) {
        developer.log(
          'Skipping malformed published trip ${row['id'] ?? '(unknown id)'}.',
          name: 'TripRepository',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return trips;
  }

  static List<Trip> parsePublicBrowseRows(Iterable<Map<String, dynamic>> rows) {
    return parseTrips(
      rows.map((row) {
        return {
          ...row,
          'route': {
            'id': row['route_id'],
            'name': row['route_name'],
            'route_stops': row['route_stops'],
          },
          'driver': {
            'verification_status': row['driver_verification_status'],
            'profile': {'full_name': row['driver_name']},
          },
          'vehicle': {
            'make': row['vehicle_make'],
            'model': row['vehicle_model'],
            'color': row['vehicle_color'],
            'seat_capacity': row['vehicle_seat_capacity'],
          },
        };
      }),
    );
  }
}
