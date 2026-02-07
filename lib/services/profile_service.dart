import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ProfileService {
  final _supabase = SupabaseService.instance;
  final _authService = AuthService();

  // Get current user's profile
  Future<Profile?> getCurrentProfile() async {
    final userId = _authService.currentUserId;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return Profile.fromJson(response);
  }

  // Get profile by ID
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get all profiles (for the 12 users)
  Future<List<Profile>> getAllProfiles() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .order('username');

    return (response as List)
        .map((json) => Profile.fromJson(json))
        .toList();
  }

  // Update profile
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Upload avatar
  Future<String> uploadAvatar(File file) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/avatar_$timestamp.jpg';

    await _supabase.storage
        .from('avatars')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _supabase.storage
        .from('avatars')
        .getPublicUrl(path);

    // Update profile with new avatar URL
    await updateProfile(avatarUrl: publicUrl);

    return publicUrl;
  }

  // Update online status
  Future<void> setOnlineStatus(bool isOnline) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _supabase.from('profiles').update({
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Update last seen
  Future<void> updateLastSeen() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _supabase.from('profiles').update({
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
