import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/booking.dart';

class BookingRepository {
  const BookingRepository(this._client);

  final SupabaseClient _client;

  Future<List<Booking>> fetchMyBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const <Booking>[];
    }

    final rows = await _client
        .from('bookings')
        .select()
        .eq('passenger_id', userId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Booking.fromSupabase(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Booking> createBooking({
    required String tripId,
    required String pickupStopId,
    required String dropoffStopId,
    required int seats,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Authentication required');
    }

    final result = await _client.rpc(
      'create_booking',
      params: {
        'p_trip_id': tripId,
        'p_passenger_id': userId,
        'p_pickup_latitude': null,
        'p_pickup_longitude': null,
        'p_pickup_address': '',
        'p_pickup_stop_id': pickupStopId,
        'p_dropoff_latitude': null,
        'p_dropoff_longitude': null,
        'p_dropoff_address': '',
        'p_dropoff_stop_id': dropoffStopId,
        'p_pickup_sequence': null,
        'p_dropoff_sequence': null,
        'p_seats': seats,
      },
    );

    if (result is! String) {
      throw StateError('Booking was not created');
    }

    final bookingId = result.toString();
    final booking = await _client
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .single();

    return Booking.fromSupabase(Map<String, dynamic>.from(booking));
  }
}
