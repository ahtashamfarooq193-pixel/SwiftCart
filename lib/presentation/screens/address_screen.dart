import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final user = FirebaseAuth.instance.currentUser;

  void _showEditAddressDialog(BuildContext context, Map<String, dynamic> currentAddress) {
    final nameController = TextEditingController(text: currentAddress['fullName']);
    final phoneController = TextEditingController(text: currentAddress['phoneNumber']);
    final cityController = TextEditingController(text: currentAddress['city']);
    final addressController = TextEditingController(text: currentAddress['addressLine1']);
    final formKey = GlobalKey<FormState>();

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
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                  'Edit Delivery Address',
                  style: AppTheme.headline4.copyWith(color: AppTheme.white),
                ),
                const SizedBox(height: 24),
                _buildEditField('Full Name', nameController, Icons.person_outline),
                const SizedBox(height: 16),
                _buildEditField('Phone Number', phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildEditField('City', cityController, Icons.location_city_outlined),
                const SizedBox(height: 16),
                _buildEditField('Complete Address', addressController, Icons.home_outlined, maxLines: 3),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Save Address',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({
                          'savedAddress': {
                            'fullName': nameController.text.trim(),
                            'phoneNumber': phoneController.text.trim(),
                            'city': cityController.text.trim(),
                            'addressLine1': addressController.text.trim(),
                          }
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Address updated successfully!'),
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
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.grey),
        prefixIcon: Icon(icon, color: AppTheme.accentColor, size: 20),
        filled: true,
        fillColor: AppTheme.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('My Address')),
        body: const Center(child: Text('Please login to view address', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Address'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final savedAddress = userData?['savedAddress'] as Map<String, dynamic>?;

          if (savedAddress == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text('No saved address yet', style: AppTheme.headline3.copyWith(color: AppTheme.white)),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Add Address',
                    onPressed: () => _showEditAddressDialog(context, {}),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.accentColor, size: 28),
                              const SizedBox(width: 12),
                              Text('Saved Address', style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            onPressed: () => _showEditAddressDialog(context, savedAddress),
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Name', savedAddress['fullName'] ?? 'N/A', Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildInfoRow('Phone', savedAddress['phoneNumber'] ?? 'N/A', Icons.phone_outlined),
                      const SizedBox(height: 16),
                      _buildInfoRow('City', savedAddress['city'] ?? 'N/A', Icons.location_city_outlined),
                      const SizedBox(height: 16),
                      _buildInfoRow('Address', savedAddress['addressLine1'] ?? 'N/A', Icons.home_outlined),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.caption.copyWith(color: AppTheme.grey)),
              const SizedBox(height: 4),
              Text(value, style: AppTheme.bodyText1.copyWith(color: AppTheme.white)),
            ],
          ),
        ),
      ],
    );
  }
}

