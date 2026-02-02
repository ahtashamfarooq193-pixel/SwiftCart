import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/splash_screen.dart';
import '../../core/theme/app_theme.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<AuthProvider>().fetchUserData(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        debugPrint('AuthWrapper: Building (isLoading: ${auth.isLoading}, isAdmin: ${auth.isAdmin})');
        
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            ),
          );
        }

        final user = FirebaseAuth.instance.currentUser;
        debugPrint('AuthWrapper: Current User: ${user?.uid}');

        if (user == null) {
          debugPrint('AuthWrapper: Redirecting to LoginScreen');
          return const LoginScreen();
        }

        if (auth.isAdmin) {
          debugPrint('AuthWrapper: Redirecting to AdminDashboardScreen');
          return const AdminDashboardScreen();
        } else {
          debugPrint('AuthWrapper: Redirecting to MainScreen');
          return const MainScreen();
        }
      },
    );
  }
}
