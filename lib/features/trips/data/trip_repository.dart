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
