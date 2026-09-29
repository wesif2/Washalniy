import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../data/supabase_auth_repository.dart';
import '../../domain/app_user.dart';
import '../../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(supabase.Supabase.instance.client);
});

/// Emits the current user whenever the auth state changes, starting
/// with whoever is already signed in.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Compatibility name for existing consumers. Both names refer to the same
/// auth-backed provider, so identity has one source of truth.
final authStateProvider = currentUserProvider;
