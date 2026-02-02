import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ResetLinkSentScreen extends StatelessWidget {
  final String email;
  const ResetLinkSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.luxuryGradient,
        ),
        child: Stack(
          children: [
            // Decorative Blurred Circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Visual Graphic
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        size: 70,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Message Heading
                    Text(
                      'Check Your Inbox',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Message Detail
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.grey,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'We have sent a password recovery link to\n'),
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: '.\nPlease check your inbox or spam folder.'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Smart Button: Open Email App
                    CustomButton(
                      text: 'Open Email App',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening your email app...'),
                            backgroundColor: AppTheme.accentColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Resend Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the email?",
                          style: TextStyle(color: AppTheme.grey.withOpacity(0.7)),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification email resent!'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          },
                          child: const Text(
                            'Resend',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Back to Login
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppTheme.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
