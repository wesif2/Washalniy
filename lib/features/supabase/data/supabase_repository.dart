import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SupabaseRepository {
  SupabaseClient get client;
}
