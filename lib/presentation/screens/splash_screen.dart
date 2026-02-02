import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/logo_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRedirect();
  }

  Future<void> _checkRedirect() async {
    try {
      debugPrint('SplashScreen: Starting redirect check...');
      await Future.delayed(const Duration(seconds: 2)); // Give it a bit more time
      
      if (!mounted) {
        debugPrint('SplashScreen: Not mounted, skipping redirect');
        return;
      }

      debugPrint('SplashScreen: Getting SharedPreferences...');
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('SplashScreen: SharedPreferences timeout!');
          throw 'SharedPreferences timeout';
        },
      );
      
      final onboardingCompleted = prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
      debugPrint('SplashScreen: onboardingCompleted = $onboardingCompleted');

      if (!onboardingCompleted) {
        debugPrint('SplashScreen: Navigating to /onboarding');
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        debugPrint('SplashScreen: Navigating to AuthWrapper (/)');
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      debugPrint('SplashScreen: Redirect Error: $e');
      // If everything fails, try to at least go to Login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        debugPrint('SplashScreen: Not mounted, cannot navigate to /login after error.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              const LogoWidget(size: 120)
                  .animate()
                  .scale(
                    duration: AppConstants.longAnimationDuration,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(
                    duration: const Duration(seconds: 1),
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),

              const SizedBox(height: 40),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  strokeWidth: 3,
                ),
              )
                  .animate(
                    delay: const Duration(milliseconds: 500),
                  )
                  .fadeIn()
                  .then()
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .rotate(
                    duration: const Duration(seconds: 2),
                  ),

              const SizedBox(height: 24),

              // Loading text
              Text(
                'Loading...',
                style: AppTheme.bodyText2.copyWith(
                  color: AppTheme.grey,
                ),
              )
                  .animate(
                    delay: const Duration(milliseconds: 800),
                  )
                  .fadeIn()
                  .slideY(begin: 0.5, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}


