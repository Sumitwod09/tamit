import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ChatService {
  final _supabase = SupabaseService.instance;
  final _authService = AuthService();

  RealtimeChannel? _messageChannel;

  // Get messages between current user and another user
  Future<List<Message>> getMessages(String otherUserId) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('messages')
        .select(
            '*, sender:sender_id(id, username, avatar_url), receiver:receiver_id(id, username, avatar_url)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .or('sender_id.eq.$otherUserId,receiver_id.eq.$otherUserId')
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => Message.fromJson(json))
        .where((msg) =>
            (msg.senderId == userId && msg.receiverId == otherUserId) ||
            (msg.senderId == otherUserId && msg.receiverId == userId))
        .toList();
  }

  // Send a message
  Future<Message> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('messages')
        .insert({
          'sender_id': userId,
          'receiver_id': receiverId,
          'content': content,
        })
        .select()
        .single();

    return Message.fromJson(response);
  }

  // Mark messages as read
  Future<void> markAsRead(String senderId) async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  // Subscribe to new messages with a specific user
  Stream<Message> subscribeToMessages(String otherUserId) {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final controller = StreamController<Message>();

    _messageChannel = _supabase.channel('messages:$otherUserId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        callback: (payload) {
          final json = payload.newRecord;
          final message = Message.fromJson(json);

          // Only emit if message is between current user and other user
          if ((message.senderId == userId &&
                  message.receiverId == otherUserId) ||
              (message.senderId == otherUserId &&
                  message.receiverId == userId)) {
            controller.add(message);
          }
        },
      )
      ..subscribe();

    return controller.stream;
  }

  // Unsubscribe from messages
  void unsubscribeFromMessages() {
    _messageChannel?.unsubscribe();
    _messageChannel = null;
  }

  // Get recent conversations (last message with each user)
  Future<Map<String, Message>> getRecentConversations() async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('messages')
        .select(
            '*, sender:sender_id(id, username, avatar_url, is_online, last_seen), receiver:receiver_id(id, username, avatar_url, is_online, last_seen)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    final messages =
        (response as List).map((json) => Message.fromJson(json)).toList();

    // Group by the other user (not current user)
    final Map<String, Message> conversations = {};
    for (final message in messages) {
      final otherUserId =
          message.senderId == userId ? message.receiverId : message.senderId;

      if (!conversations.containsKey(otherUserId)) {
        conversations[otherUserId] = message;
      }
    }

    return conversations;
  }
}
