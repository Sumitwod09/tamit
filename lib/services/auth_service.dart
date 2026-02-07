import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.instance;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current user ID
  String? get currentUserId => currentUser?.id;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with magic link
  Future<void> signInWithMagicLink({
    required String email,
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: null, // For mobile, no redirect needed
    );
  }

  // Sign up (for initial user creation, should be done by admin)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
      },
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
