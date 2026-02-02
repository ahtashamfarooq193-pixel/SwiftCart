import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingDetailsScreen extends StatefulWidget {
  const ShippingDetailsScreen({super.key});

  @override
  State<ShippingDetailsScreen> createState() => _ShippingDetailsScreenState();
}

class _ShippingDetailsScreenState extends State<ShippingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoadingAddress = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final savedAddress = data?['savedAddress'] as Map<String, dynamic>?;

        if (savedAddress != null) {
          setState(() {
            _nameController.text = savedAddress['fullName'] ?? '';
            _phoneController.text = savedAddress['phoneNumber'] ?? '';
            _cityController.text = savedAddress['city'] ?? '';
            _addressController.text = savedAddress['addressLine1'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading saved address: $e');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _saveAddressToFirestore(Map<String, String> shippingData) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({
          'savedAddress': shippingData,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error saving address: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Shipping Details'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              Text(
                'Where should we send your order?',
                style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide accurate delivery information.',
                style: AppTheme.caption.copyWith(color: AppTheme.grey),
              ),
              const SizedBox(height: 32),
              
              _buildTextField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                label: 'City',
                controller: _cityController,
                icon: Icons.location_city_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please enter your city' : null,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                label: 'Complete Home Address',
                controller: _addressController,
                icon: Icons.home_outlined,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Please enter your address' : null,
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator or info message
              if (_isLoadingAddress)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(color: AppTheme.accentColor),
                  ),
                )
              else if (_nameController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your saved address has been loaded. You can edit if needed.',
                          style: AppTheme.caption.copyWith(color: AppTheme.white),
                        ),
                      ),
                    ],
                  ),
                ),
              
              CustomButton(
                text: 'Proceed to Payment',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final shippingData = {
                      'fullName': _nameController.text.trim(),
                      'phoneNumber': _phoneController.text.trim(),
                      'city': _cityController.text.trim(),
                      'addressLine1': _addressController.text.trim(),
                    };
                    
                    // Save address for future use
                    await _saveAddressToFirestore(shippingData);
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentScreen(shippingData: shippingData)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Cart', true, true),
        _buildConnector(true),
        _buildStep(2, 'Shipping', true, false),
        _buildConnector(false),
        _buildStep(3, 'Payment', false, false),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.accentColor : (isActive ? AppTheme.accentColor.withOpacity(0.2) : AppTheme.darkGrey),
            border: Border.all(color: isActive ? AppTheme.accentColor : AppTheme.grey, width: 2),
          ),
          child: Center(
            child: isCompleted 
              ? const Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
              : Text('$step', style: TextStyle(color: isActive ? AppTheme.white : AppTheme.grey, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption.copyWith(color: isActive ? AppTheme.white : AppTheme.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? AppTheme.accentColor : AppTheme.darkGrey,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.grey),
        prefixIcon: Icon(icon, color: AppTheme.accentColor, size: 20),
        filled: true,
        fillColor: AppTheme.primaryColor.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
      ),
    );
  }
}
