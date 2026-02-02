import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/fcm_service.dart';
import '../widgets/custom_button.dart';
import 'order_success_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> shippingData;
  
  const PaymentScreen({super.key, required this.shippingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'JazzCash';
  final _tidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            
            _buildInstructionsCard(),
            
            const SizedBox(height: 32),
            Text(
              'Select Transfer Method',
              style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMethodSelector(),
            
            const SizedBox(height: 32),
            Text(
              'Verify Your Payment',
              style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 11-12 digit Transaction ID (TID) received in SMS.',
              style: AppTheme.caption.copyWith(color: AppTheme.grey),
            ),
            const SizedBox(height: 16),
            _buildTidField(),
            
            const SizedBox(height: 48),
            CustomButton(
              text: 'Place Order',
              onPressed: () async {
                if (_tidController.text.length < 5) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Please enter a valid Transaction ID'), backgroundColor: AppTheme.errorColor),
                   );
                   return;
                }

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final cartProvider = context.read<CartProvider>();
                if (cartProvider.cart.items.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Your cart is empty'), backgroundColor: AppTheme.errorColor),
                   );
                   return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                );

                try {
                  final orderId = const Uuid().v4();
                  final orderData = {
                    'orderId': orderId,
                    'userId': user.uid,
                    'userName': user.displayName ?? 'Unknown',
                    'paymentId': _tidController.text.trim(),
                    'totalAmount': cartProvider.cart.total,
                    'itemsList': cartProvider.cart.items.map((item) => {
                      'productId': item.product.id,
                      'name': item.product.name,
                      'price': item.product.price,
                      'quantity': item.quantity,
                      'image': item.product.imageUrl,
                      'selectedSize': item.selectedSize,
                      'selectedColor': item.selectedColor,
                    }).toList(),
                    'status': 'Processing',
                    'timestamp': FieldValue.serverTimestamp(),
                    'shippingAddress': widget.shippingData,
                    'paymentMethod': _selectedMethod,
                  };

                  await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);
                  
                  // Also save a reference in user's sub-collection for easy access
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('orders')
                      .doc(orderId)
                      .set(orderData);

                  // Send notification to admins
                  await FCMService().sendOrderNotificationToAdmins(
                    userName: user.displayName ?? 'Customer',
                    orderId: orderId,
                    totalAmount: cartProvider.cart.total,
                  );

                  cartProvider.clearCart();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to place order: $e'), backgroundColor: AppTheme.errorColor),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Cart', true, true),
        _buildConnector(true),
        _buildStep(2, 'Shipping', true, true),
        _buildConnector(true),
        _buildStep(3, 'Payment', true, false),
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

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.amethystGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Manual Payment Instructions',
                  style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Please send the total amount to the following account to confirm your order:',
            style: AppTheme.caption.copyWith(color: AppTheme.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 12),
          _buildAccountInfo('Account Number', '03279145041'),
          const SizedBox(height: 8),
          _buildAccountInfo('Account Title', 'Muhammad Ahtsham Farooq'),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption.copyWith(color: AppTheme.white.withOpacity(0.7))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelector() {
    return Row(
      children: [
        _buildMethodCard('JazzCash', 'assets/images/jazzcash_logo.png'), // Placeholder or color-based
        const SizedBox(width: 16),
        _buildMethodCard('EasyPaisa', 'assets/images/easypaisa_logo.png'),
      ],
    );
  }

  Widget _buildMethodCard(String method, String asset) {
    bool isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.accentColor : AppTheme.white.withOpacity(0.05),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                method == 'JazzCash' ? Icons.account_balance_wallet_outlined : Icons.payments_outlined,
                color: isSelected ? AppTheme.accentColor : AppTheme.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                method,
                style: AppTheme.bodyText2.copyWith(
                  color: isSelected ? AppTheme.white : AppTheme.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTidField() {
    return TextField(
      controller: _tidController,
      style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
      decoration: InputDecoration(
        hintText: 'e.g. 01234567890',
        hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.3), letterSpacing: 0),
        prefixIcon: const Icon(Icons.receipt_long_outlined, color: AppTheme.accentColor),
        filled: true,
        fillColor: AppTheme.primaryColor.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
        ),
      ),
    );
  }
}
