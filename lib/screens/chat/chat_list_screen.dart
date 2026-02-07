import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import 'chat_screen.dart';

// Provider to get the 'other' user for 1-to-1 chat
final otherUserProvider = FutureProvider<Profile?>((ref) async {
  final authService = AuthService();
  final currentUserId = authService.currentUserId;
  if (currentUserId == null) return null;

  final profiles = await ProfileService().getAllProfiles();
  try {
    // Find the first user that matches the ID that ISN't the current user
    return profiles.firstWhere((p) => p.id != currentUserId);
  } catch (e) {
    return null; // No other user found
  }
});

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(otherUserProvider);

    return Scaffold(
      body: otherUserAsync.when(
        data: (otherUser) {
          if (otherUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Waiting for the other user to join...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // Direct 1-to-1 chat
          return ChatScreen(otherUser: otherUser);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
