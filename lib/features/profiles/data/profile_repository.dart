import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select(
          'id, full_name, phone, email, avatar_url, role, created_at, updated_at',
        )
        .eq('id', userId)
        .maybeSingle();

    return row == null ? null : Profile.fromSupabase(row);
  }

  Future<void> saveRole({required String userId, required String role}) async {
    if (role != 'passenger' && role != 'driver') {
      throw ArgumentError.value(role, 'role', 'Unsupported account role');
    }

    await _client
      .from('profiles')
      .upsert({'id': userId, 'role': role}, onConflict: 'id')
        .select('id')
      .single();
  }
}
