import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  AppUser? _toAppUser(supabase.User? user) {
    if (user == null || user.email == null) return null;
    return AppUser(id: user.id, email: user.email!);
  }

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map(
      (state) => _toAppUser(state.session?.user),
    );
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = _toAppUser(response.user);
      if (user == null) {
        throw const AuthException('تعذّر إنشاء الحساب، حاول تاني.');
      }
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthException(_mapMessage(e.message));
    }
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = _toAppUser(response.user);
      if (user == null) {
        throw const AuthException('البيانات غلط، حاول تاني.');
      }
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthException(_mapMessage(e.message));
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  String _mapMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'الإيميل أو الباسورد غلط.';
    }
    if (lower.contains('already registered')) {
      return 'الإيميل ده مسجّل قبل كده.';
    }
    if (lower.contains('password should be at least')) {
      return 'الباسورد لازم يكون 6 حروف على الأقل.';
    }
    return 'حصل خطأ، حاول تاني.';
  }
}
