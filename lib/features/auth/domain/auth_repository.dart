import 'app_user.dart';

/// Contract for authentication, independent of the backend used.
///
/// Today [SupabaseAuthRepository] implements this against Supabase.
/// Swapping to a custom server later only means writing a new
/// implementation of this interface — nothing above this layer changes.
abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
