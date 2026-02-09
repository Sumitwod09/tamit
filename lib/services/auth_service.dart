import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.instance;

  final _googleSignIn = GoogleSignIn();

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
    required String password, // Not used but kept for interface consistency
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: null, // For mobile, no redirect needed
    );
  }

  // Sign up
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

  // Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign In canceled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
