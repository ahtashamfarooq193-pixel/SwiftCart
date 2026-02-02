import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/fcm_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/admin_dashboard_screen.dart';
import 'presentation/widgets/auth_wrapper.dart';

import 'package:provider/provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/wishlist_provider.dart';
import 'presentation/screens/change_password_screen.dart';

// Global navigator key for FCM navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('--- Flutter Binding Initialized ---');

    await Firebase.initializeApp();
    debugPrint('--- Firebase Initialized ---');

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('--- Background Messaging Handler Set ---');

    // Initialize FCM Service (Don't let it block if it hangs)
    try {
      final fcmService = FCMService();
      await fcmService.initialize().timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('--- FCM Initialization Timed Out ---');
      });
      debugPrint('--- FCM Service Initialized ---');

      // Handle initial message if app was launched from notification
      final initialMessage = await fcmService.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(seconds: 2), () {
          if (initialMessage.data['type'] == 'new_order') {
            navigatorKey.currentState?.pushNamed('/admin-dashboard');
          }
        });
      }
    } catch (e) {
      debugPrint('--- FCM Initialization Error: $e ---');
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
    debugPrint('--- SharedPreferences Loaded (onboardingCompleted: $onboardingCompleted) ---');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: MyApp(onboardingCompleted: onboardingCompleted),
      ),
    );
    debugPrint('--- App Running ---');
  } catch (e, stack) {
    debugPrint('--- CRITICAL INITIALIZATION ERROR: $e ---');
    debugPrint(stack.toString());
    
    // Attempt to run app anyway so it doesn't stay on native splash
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Fatal Error during startup: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthWrapper(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}