import 'package:flutter/material.dart';
import 'dart:math' show sin, cos;
import 'dart:ui' show ImageFilter;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../../domain/entities/onboarding.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < OnboardingData.items.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompletedKey, true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Beautiful animated background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.accentColor.withOpacity(0.6),
                  AppTheme.secondaryColor?.withOpacity(0.4) ?? AppTheme.primaryColor.withOpacity(0.4),
                  AppTheme.white.withOpacity(0.9),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Animated floating shapes
          const Positioned(
            top: 100,
            left: 50,
            child: _FloatingShape(
              size: 80,
              color: Color(0xFFFF6B6B),
              duration: Duration(seconds: 8),
            ),
          ),
          const Positioned(
            top: 200,
            right: 30,
            child: _FloatingShape(
              size: 60,
              color: Color(0xFF4ECDC4),
              duration: Duration(seconds: 6),
              delay: Duration(seconds: 2),
            ),
          ),
          const Positioned(
            bottom: 300,
            left: 80,
            child: _FloatingShape(
              size: 100,
              color: Color(0xFF45B7D1),
              duration: Duration(seconds: 10),
              delay: Duration(seconds: 1),
            ),
          ),
          const Positioned(
            bottom: 150,
            right: 60,
            child: _FloatingShape(
              size: 70,
              color: Color(0xFFF9CA24),
              duration: Duration(seconds: 7),
              delay: Duration(seconds: 3),
            ),
          ),

          // Subtle pattern overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  AppTheme.white.withOpacity(0.1),
                  AppTheme.white.withOpacity(0.05),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button (minimal)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: AppTheme.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content with subtle glassmorphism effect
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: OnboardingData.items.length,
                      itemBuilder: (context, index) {
                        final item = OnboardingData.items[index];
                        return _OnboardingPageContent(item: item, index: index);
                      },
                    ),
                  ),
                ),

                // Bottom section with indicators and buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          OnboardingData.items.length,
                          (index) => AnimatedContainer(
                            duration: AppConstants.shortAnimationDuration,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.accentColor
                                  : AppTheme.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: AppConstants.mediumAnimationDuration,
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.primaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Previous',
                                  style: AppTheme.button.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPage > 0) const SizedBox(width: 16),

                          Expanded(
                            flex: 2,
                            child: CustomButton(
                              text: _currentPage == OnboardingData.items.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              onPressed: _nextPage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingShape extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Duration delay;

  const _FloatingShape({
    required this.size,
    required this.color,
    required this.duration,
    this.delay = Duration.zero,
  });

  @override
  State<_FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<_FloatingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            20 * sin(_animation.value),
            15 * cos(_animation.value),
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  final int index;

  const _OnboardingPageContent({
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image/Icon
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            )
                .animate()
                .scale(
                  delay: Duration(milliseconds: 200 + (index * 100)),
                  duration: AppConstants.mediumAnimationDuration,
                  curve: Curves.elasticOut,
                ),
  
            const SizedBox(height: 20),
  
            // Title
            Text(
              item.title,
              style: AppTheme.headline2.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 400 + (index * 100)),
                  duration: AppConstants.mediumAnimationDuration,
                )
                .slideY(begin: 0.3, end: 0),
  
            const SizedBox(height: 10),
  
            // Description
            Text(
              item.description,
              style: AppTheme.bodyText1.copyWith(
                color: Colors.black,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 600 + (index * 100)),
                  duration: AppConstants.mediumAnimationDuration,
                )
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
