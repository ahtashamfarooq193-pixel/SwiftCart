import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'forgot_password_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all password fields'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    if (newPassword.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be at least 6 characters long'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password and confirm password do not match'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw 'User not authenticated';
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Updated Successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Logout and navigate to login screen
        await Provider.of<AuthProvider>(context, listen: false).signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to update password';

      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        errorMessage = 'Wrong Current Password';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Session expired. Please log in again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Password Change'),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Current Password',
              controller: _currentPasswordController,
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'New Password',
              controller: _newPasswordController,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            
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
                  style: AppTheme.caption.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: AppTheme.grey.withOpacity(0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader('Advanced Security'),
            const SizedBox(height: 16),
            _buildToggleTile(
              title: 'Biometric Authentication',
              subtitle: 'Use FaceID/Fingerprint for quick login',
              value: _isBiometricEnabled,
              onChanged: (val) => setState(() => _isBiometricEnabled = val),
              icon: Icons.fingerprint,
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader('Account Management'),
            const SizedBox(height: 16),
            _buildDestructiveTile(
              title: 'Delete Account',
              subtitle: 'Permanently remove your account and all data',
              icon: Icons.delete_forever_outlined,
              onTap: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyText2.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppTheme.white, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            filled: true,
            fillColor: AppTheme.white.withOpacity(0.05),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5), fontSize: 14),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppTheme.accentColor,
              size: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.grey,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTheme.caption.copyWith(color: AppTheme.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
            activeTrackColor: AppTheme.accentColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDestructiveTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: AppTheme.errorColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.errorColor.withOpacity(0.1)),
      ),
      leading: Icon(icon, color: AppTheme.errorColor),
      title: Text(title, style: AppTheme.bodyText1.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTheme.caption.copyWith(color: AppTheme.grey)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.grey),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 48),
            const SizedBox(height: 16),
            Text('Delete Account?', style: AppTheme.headline4.copyWith(color: AppTheme.white)),
            const SizedBox(height: 12),
            Text(
              'This action is permanent and cannot be undone. Are you sure you want to delete your SwiftCart account?',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: AppTheme.white),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
