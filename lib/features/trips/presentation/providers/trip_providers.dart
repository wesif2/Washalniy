import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/trip.dart';
import '../../data/trip_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(Supabase.instance.client);
});

final publishedTripsProvider = FutureProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).fetchPublishedTrips();
});

final myTripsProvider = FutureProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).fetchMyTrips();
});
