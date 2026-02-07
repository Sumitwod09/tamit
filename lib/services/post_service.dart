import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class PostService {
  final _supabase = SupabaseService.instance;
  final _authService = AuthService();

  // Get all posts with author info
  Future<List<Post>> getPosts() async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }

  // Create a post
  Future<Post> createPost({
    required String content,
    File? image,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    String? imageUrl;
    if (image != null) {
      imageUrl = await uploadPostImage(image);
    }

    final response = await _supabase
        .from('posts')
        .insert({
          'user_id': userId,
          'content': content,
          if (imageUrl != null) 'image_url': imageUrl,
        })
        .select('*, profiles(*)')
        .single();

    return Post.fromJson(response);
  }

  // Upload post image
  Future<String> uploadPostImage(File file) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/post_$timestamp.jpg';

    await _supabase.storage
        .from('posts')
        .upload(path, file);

    return _supabase.storage
        .from('posts')
        .getPublicUrl(path);
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('posts')
        .delete()
        .eq('id', postId)
        .eq('user_id', userId);
  }

  // Like a post
  Future<void> likePost(String postId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  // Check if user liked a post
  Future<bool> hasLikedPost(String postId) async {
    final userId = _authService.currentUserId;
    if (userId == null) return false;

    final response = await _supabase
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId);

    return (response as List).isNotEmpty;
  }

  // Get comments for a post
  Future<List<Comment>> getComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => Comment.fromJson(json))
        .toList();
  }

  // Add a comment
  Future<Comment> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'content': content,
        })
        .select('*, profiles(*)')
        .single();

    return Comment.fromJson(response);
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', userId);
  }
}
