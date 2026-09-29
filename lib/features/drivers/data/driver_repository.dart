import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/driver.dart';

class DriverRepository {
  const DriverRepository(this._client);

  final SupabaseClient _client;

  Future<Driver?> getCurrentDriver() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await _client
        .from('drivers')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Driver.fromSupabase(response);
  }

  Future<Driver> upsertDriverProfile({required String nationalId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Authentication required');
    }

    final response = await _client
        .from('drivers')
        .upsert(
          {
            'user_id': userId,
            'national_id': nationalId,
            'verification_status': 'pending',
          },
          onConflict: 'user_id',
        )
        .select()
        .single();

    return Driver.fromSupabase(response);
  }
}
