import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'my_orders_screen.dart';
import 'security_settings_screen.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'admin_dashboard_screen.dart';
import 'address_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSection('Account Settings'),
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.password_outlined,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'My Address',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSection('Support & About'),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      
                      final userData = snapshot.data!.data() as Map<String, dynamic>?;
                      final isAdmin = userData?['isAdmin'] == true;

                      if (!isAdmin) return const SizedBox.shrink();

                      return _buildMenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin Dashboard',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                          );
                        },
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.storage_rounded,
                    title: 'Clear Cache',
                    onTap: () => _showClearCacheDialog(context),
                  ),
                  
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, size: 20, color: AppTheme.errorColor),
                      label: const Text('Log Out', style: TextStyle(color: AppTheme.errorColor)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  
                  Text(
                    'App Version ${AppConstants.appVersion}',
                    style: AppTheme.caption.copyWith(color: AppTheme.grey),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.accentColor.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String displayName = 'User';
                String email = FirebaseAuth.instance.currentUser?.email ?? '';
                
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  if (data.containsKey('name') && data['name'].toString().isNotEmpty) {
                    displayName = data['name'];
                  } else if (email.isNotEmpty) {
                    displayName = email.split('@')[0];
                  }
                } else if (email.isNotEmpty) {
                   displayName = email.split('@')[0];
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayName ',
                      style: AppTheme.headline3.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Premium Member',
                      style: AppTheme.caption.copyWith(color: AppTheme.accentColor),
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            onPressed: () => _showEditNameDialog(context),
            icon: const Icon(Icons.edit_outlined, color: AppTheme.accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTheme.caption.copyWith(color: AppTheme.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.accentColor, size: 22),
        title: Text(
          title,
          style: AppTheme.bodyText1.copyWith(color: AppTheme.white),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            Text('Ready to Logout?', style: AppTheme.headline4.copyWith(color: AppTheme.white)),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to log out of SwiftCart? You can log back in anytime.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Stay Logged In'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: AppTheme.white),
                    child: const Text('Yes, Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Clear Cache', style: TextStyle(color: AppTheme.white)),
        content: Text('Estimated size: 45.8 MB. This will free up storage space.', style: TextStyle(color: AppTheme.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!'), backgroundColor: AppTheme.successColor),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    // Get current name
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data();
        nameController.text = data?['name'] ?? '';
      }
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 32,
          right: 32,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Edit Your Name',
              style: AppTheme.headline4.copyWith(color: AppTheme.white),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.white.withOpacity(0.05),
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppTheme.accentColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.grey.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Name cannot be empty'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                        return;
                      }

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({'name': newName});

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name updated successfully!'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
