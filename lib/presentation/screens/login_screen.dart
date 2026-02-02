import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import '../../core/theme/app_theme.dart';
import 'forgot_password_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final formData = _formKey.currentState!.value;

      final error = await authProvider.signIn(
        email: formData['email'],
        password: formData['password'],
      );

      if (mounted) {
        if (error == null) {
          // Success SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Successful!'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Role-Based Navigation
          if (authProvider.isAdmin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.of(context).pushReplacementNamed('/main');
          }
        } else {
          // Error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signInWithGoogle();

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Login Successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        if (authProvider.isAdmin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else if (error != 'Sign in cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
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
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'SwiftCart',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Luxury Shopping Experience',
                          style: AppTheme.bodyText2.copyWith(
                            color: AppTheme.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Login Form
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      Text(
                        'Email Address',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormBuilderTextField(
                        name: 'email',
                        style: const TextStyle(color: AppTheme.white, fontSize: 14),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.accentColor,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Email is required',
                          ),
                          FormBuilderValidators.email(
                            errorText: 'Please enter a valid email',
                          ),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      Text(
                        'Password',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormBuilderTextField(
                        name: 'password',
                        style: const TextStyle(color: AppTheme.white, fontSize: 14),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.accentColor,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.grey,
                              size: 18,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Password is required',
                          ),
                          FormBuilderValidators.minLength(
                            8,
                            errorText: 'Password must be at least 8 characters',
                          ),
                        ]),
                      ),

                      const SizedBox(height: 10),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.bodyText2.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return CustomButton(
                            text: 'Sign In',
                            onPressed: _handleLogin,
                            isLoading: auth.isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.grey.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.darkGrey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.grey.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height:15),

                      // Social Login Buttons
                      SocialLoginButton(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: _handleGoogleLogin,
                      ),

                      const SizedBox(height: 12),

                      SocialLoginButton(
                        text: 'Continue with Apple',
                        icon: Icons.apple,
                        onPressed: () {
                          // TODO: Implement Apple login
                        },
                      ),

                      const SizedBox(height: 32),

                      // Sign Up Link
                      const SizedBox(height: 15),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: AppTheme.bodyText2.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToRegister,
                            child: Text(
                              'Sign Up',
                              style: AppTheme.bodyText2.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ), // SignUp Link Row
                    ], // FormBuilder Column children
                  ), // FormBuilder Column
                ), // FormBuilder
              ], // SVC Column children
            ), // SVC Column
          ), // SVC
        ), // Center
      ), // SafeArea
    ], // Stack children
  ), // Stack
), // Body Container
    );
  }
}
