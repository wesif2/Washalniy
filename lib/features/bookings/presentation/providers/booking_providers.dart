import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/booking_repository.dart';
import '../../domain/booking.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).fetchMyBookings();
});
