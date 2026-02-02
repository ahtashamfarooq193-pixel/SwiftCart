import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final formData = _formKey.currentState!.value;

      final error = await authProvider.signUp(
        name: '${formData['firstName']} ${formData['lastName']}',
        email: formData['email'],
        phone: formData['phone'],
        password: formData['password'],
        gender: formData['gender'] ?? 'Not Specified',
      );

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup Successful! Welcome to SwiftCart.'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Navigate to main screen
          Navigator.of(context).pushReplacementNamed('/main');
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
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signInWithGoogle();

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Signup Successful! Welcome.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/main');
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

  void _navigateToLogin() {
    Navigator.of(context).pop();
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
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: _navigateToLogin,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppTheme.amethystGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_outlined,
                          color: AppTheme.primaryColor,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join our elite community',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Registration Form
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Fields
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    'First Name',
                                    style: AppTheme.bodyText2.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FormBuilderTextField(
                                    name: 'firstName',
                                    style: const TextStyle(color: AppTheme.white, fontSize: 13),
                                    textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        filled: true,
                                        fillColor: AppTheme.white.withOpacity(0.05),
                                        hintText: 'First name',
                                        hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
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
                                        errorText: 'First name is required',
                                      ),
                                      FormBuilderValidators.minLength(
                                        2,
                                        errorText: 'First name must be at least 2 characters',
                                      ),
                                    ]),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    'Last Name',
                                    style: AppTheme.bodyText2.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FormBuilderTextField(
                                    name: 'lastName',
                                    style: const TextStyle(color: AppTheme.white, fontSize: 13),
                                    textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        filled: true,
                                        fillColor: AppTheme.white.withOpacity(0.05),
                                        hintText: 'Last name',
                                        hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
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
                                        errorText: 'Last name is required',
                                      ),
                                      FormBuilderValidators.minLength(
                                        2,
                                        errorText: 'Last name must be at least 2 characters',
                                      ),
                                    ]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Gender Selection
                      Text(
                        'Gender',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormBuilderRadioGroup(
                        name: 'gender',
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        ),
                        options: [
                          FormBuilderFieldOption(
                            value: 'Male',
                            child: Text(
                              'Male',
                              style: AppTheme.bodyText2.copyWith(color: AppTheme.white),
                            ),
                          ),
                          FormBuilderFieldOption(
                            value: 'Female',
                            child: Text(
                              'Female',
                              style: AppTheme.bodyText2.copyWith(color: AppTheme.white),
                            ),
                          ),
                        ],
                        validator: FormBuilderValidators.required(
                          errorText: 'Please select your gender',
                        ),
                      ),

                      const SizedBox(height: 16),

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
                        style: const TextStyle(color: AppTheme.white, fontSize: 13),
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

                      // Phone Field
                      Text(
                        'Phone Number',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormBuilderTextField(
                        name: 'phone',
                        style: const TextStyle(color: AppTheme.white, fontSize: 13),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          hintText: 'Enter your phone number',
                          hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
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
                            errorText: 'Phone number is required',
                          ),
                          FormBuilderValidators.minLength(
                            10,
                            errorText: 'Phone number must be at least 10 digits',
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
                        style: const TextStyle(color: AppTheme.white, fontSize: 13),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          hintText: 'Create a password',
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

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      Text(
                        'Confirm Password',
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormBuilderTextField(
                        name: 'confirmPassword',
                        style: const TextStyle(color: AppTheme.white, fontSize: 13),
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: AppTheme.white.withOpacity(0.05),
                          hintText: 'Confirm your password',
                          hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 13),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.accentColor,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.grey,
                              size: 18,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
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
                            errorText: 'Please confirm your password',
                          ),
                          (value) {
                            final password = _formKey.currentState?.fields['password']?.value;
                            if (value != password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.accentColor,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTheme.bodyText2.copyWith(
                                  color: AppTheme.grey,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  const TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  const TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Register Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return CustomButton(
                            text: 'Create Account',
                            onPressed: _handleRegister,
                            isLoading: auth.isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 24),

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
                          // TODO: Implement Apple registration
                        },
                      ),

                      const SizedBox(height: 15),
                      // Sign In Link
                      const SizedBox(height: 15),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: AppTheme.bodyText2.copyWith(
                              color: AppTheme.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToLogin,
                            child: Text(
                              'Sign In',
                              style: AppTheme.bodyText2.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ), // SignIn Link Row
                    ], // FormBuilder Column children
                  ), // FormBuilder Column
                ), // FormBuilder
              ], // Column children
            ), // Column
          ), // SingleChildScrollView
        ), // SafeArea
      ], // Stack children
    ), // Stack
  ), // Body Container
    );
  }
}
