import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feed/feed_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [FeedScreen(), ChatListScreen()];

  @override
  Widget build(BuildContext context) {
    // Get current user profile for avatar
    final authService = AuthService();
    final currentUserId = authService.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamit'),
        actions: [
          // Avatar button to access profile
          if (currentUserId != null)
            FutureBuilder(
              future: ProfileService().getProfileById(currentUserId),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return IconButton(
                  icon: UserAvatar(avatarUrl: profile?.avatarUrl, size: 32),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
