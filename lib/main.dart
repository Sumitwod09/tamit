import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/env.dart';
import 'config/theme.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const ProviderScope(child: TamitApp()));
}

class TamitApp extends StatelessWidget {
  const TamitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamit',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((event) {
      if (mounted) {
        setState(() {
          // Update online status when auth state changes
          if (event.session != null) {
            _profileService.setOnlineStatus(true);
          } else {
            _profileService.setOnlineStatus(false);
          }
        });
      }
    });

    // Set initial online status
    if (_authService.isAuthenticated) {
      _profileService.setOnlineStatus(true);
    }
  }

  @override
  void dispose() {
    // Set offline when app is disposed
    if (_authService.isAuthenticated) {
      _profileService.setOnlineStatus(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthenticated = snapshot.data?.session != null;

        if (isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
