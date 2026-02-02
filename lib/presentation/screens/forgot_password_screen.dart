import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'reset_link_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Header Visual
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppTheme.amethystGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 60,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Heading
                            Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Sub-heading
                            Text(
                              'Enter your registered email to receive a password reset link.',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyText2.copyWith(
                                color: AppTheme.grey,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Email Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Email Address',
                                style: AppTheme.bodyText2.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: AppTheme.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                filled: true,
                                fillColor: AppTheme.white.withOpacity(0.05),
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.accentColor, size: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppTheme.accentColor),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            // Primary Button
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) {
                                return CustomButton(
                                  text: 'Send Reset Link',
                                  isLoading: auth.isLoading,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final email = _emailController.text.trim();
                                      final error = await auth.resetPassword(email);

                                      if (context.mounted) {
                                        if (error == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Reset link sent to your email'),
                                              backgroundColor: AppTheme.successColor,
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ResetLinkSentScreen(email: email),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(error),
                                              backgroundColor: AppTheme.errorColor,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Footer
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Back to Login',
                                style: AppTheme.bodyText2.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
