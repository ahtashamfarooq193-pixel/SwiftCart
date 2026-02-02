import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/order.dart';
import '../../data/models/mock_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/fcm_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['isAdmin'] == true) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }
    
    // Not admin or not logged in
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Admins Only'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/change-password'),
            tooltip: 'Change Password',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              int processing = 0;
              int verified = 0;
              int delivered = 0;
              int cancelled = 0;

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final status = doc['status'] as String? ?? 'Processing';
                  if (status == 'Processing') processing++;
                  else if (status == 'Payment Verified') verified++;
                  else if (status == 'Delivered') delivered++;
                  else if (status == 'Cancelled') cancelled++;
                }
              }

              return _buildStatsHeader(processing, verified, delivered, cancelled);
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No orders found', style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildOrderAdminCard(data, docs[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(int processing, int verified, int delivered, int cancelled) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Processing', processing.toString(), AppTheme.warningColor),
            const SizedBox(width: 20),
            _buildStatItem('Verified', verified.toString(), AppTheme.accentColor),
            const SizedBox(width: 20),
            _buildStatItem('Delivered', delivered.toString(), AppTheme.successColor),
            const SizedBox(width: 20),
            _buildStatItem('Cancelled', cancelled.toString(), AppTheme.errorColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTheme.headline2.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTheme.caption.copyWith(color: AppTheme.grey),
        ),
      ],
    );
  }

  Widget _buildOrderAdminCard(Map<String, dynamic> data, String docId) {
    final statusStr = data['status'] as String? ?? 'Pending';
    final paymentId = data['paymentId'] as String? ?? 'N/A';
    final paymentMethod = data['paymentMethod'] as String? ?? 'N/A';
    final total = (data['totalAmount'] as num? ?? 0).toDouble();
    final userId = data['userId'] as String? ?? '';
    final shippingMap = data['shippingAddress'] as Map<String, dynamic>? ?? {};
    final fullName = shippingMap['fullName'] as String? ?? data['userName'] as String? ?? 'Unknown';
    final phone = shippingMap['phoneNumber'] ?? 'N/A';
    final address = shippingMap['addressLine1'] ?? 'N/A';

    return GestureDetector(
      onTap: () => _showOrderDetailsBottomSheet(data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
                Text(
                  'Order #${docId.length >= 8 ? docId.substring(0, 8).toUpperCase() : docId.toUpperCase()}',
                  style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(statusStr),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User', fullName, Icons.person_outline),
            const SizedBox(height: 8),
            _buildInfoRow('Phone', phone, Icons.phone_outlined),
            const SizedBox(height: 8),
            _buildInfoRow('Address', address, Icons.location_on_outlined),
            const SizedBox(height: 8),
            _buildInfoRow('Amount', 'Rs ${total.toStringAsFixed(0)}', Icons.payments_outlined),
            const SizedBox(height: 8),
            _buildInfoRow('TID', paymentId, Icons.receipt_long_outlined),
            const SizedBox(height: 8),
            _buildInfoRow('Account', paymentMethod, Icons.account_balance_wallet_outlined),
            
            const SizedBox(height: 20),
            if (statusStr == 'Processing')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateOrderStatus(docId, userId, 'Cancelled', data),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(docId, userId, 'Payment Verified', data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Verify Payment'),
                    ),
                  ),
                ],
              )
            else if (statusStr == 'Payment Verified')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(docId, userId, 'Delivered', data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mark as Delivered', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            else if (statusStr == 'Delivered')
              const Center(
                child: Text(
                  'Order Completed',
                  style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String docId, String userId, String status, [Map<String, dynamic>? orderData]) async {
    try {
      final updateData = {'status': status};
      if (status == 'Payment Verified' || status == 'Verified') {
        updateData['paymentStatus'] = 'verified';
      }

      await FirebaseFirestore.instance.collection('orders').doc(docId).update(updateData);
      
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(docId)
            .update(updateData);
            
        // Extract product info for review prompt
        String? productName;
        String? productId;
        
        if (status == 'Delivered' && orderData != null) {
          final items = orderData['itemsList'] as List<dynamic>?;
          if (items != null && items.isNotEmpty) {
             final firstItem = items.first as Map<String, dynamic>;
             productName = firstItem['name'];
             productId = firstItem['productId'];
          }
        }

        // Send notification to user
        await FCMService().sendStatusUpdateNotification(
           userId: userId,
           orderId: docId.length >= 8 ? docId.substring(0, 8).toUpperCase() : docId.toUpperCase(),
           status: status,
           productName: productName,
           productId: productId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'Processing':
        color = AppTheme.warningColor;
        text = 'Processing';
        break;
      case 'Payment Verified':
        color = AppTheme.accentColor;
        text = 'Payment Verified';
        break;
      case 'Delivered':
        color = AppTheme.successColor;
        text = 'Delivered';
        break;
      case 'Cancelled':
        color = AppTheme.errorColor;
        text = 'Cancelled';
        break;
      default:
        color = AppTheme.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey),
        const SizedBox(width: 8),
        Text('$label:', style: AppTheme.caption.copyWith(color: AppTheme.grey)),
        const SizedBox(width: 4),
        Text(value, style: AppTheme.bodyText2.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showOrderDetailsBottomSheet(Map<String, dynamic> data) {
    final shippingMap = data['shippingAddress'] as Map<String, dynamic>? ?? {};
    final fullName = shippingMap['fullName'] ?? 'N/A';
    final address = shippingMap['addressLine1'] ?? 'N/A';
    final phone = shippingMap['phoneNumber'] ?? 'N/A';
    final paymentMethod = data['paymentMethod'] as String? ?? 'N/A';
    final paymentId = data['paymentId'] as String? ?? 'N/A';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Shipping Details', style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailField('Full Name', fullName),
            const SizedBox(height: 12),
            _buildDetailField('Store Address', address),
            const SizedBox(height: 12),
            _buildClickToCallField(phone),
            const SizedBox(height: 24),
            Text('Payment Information', style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailField('Payment Account', paymentMethod),
            const SizedBox(height: 12),
            _buildDetailField('Transaction ID', paymentId),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption.copyWith(color: AppTheme.grey)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.bodyText1.copyWith(color: AppTheme.white)),
      ],
    );
  }

  Widget _buildClickToCallField(String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: AppTheme.caption.copyWith(color: AppTheme.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(phone, style: AppTheme.bodyText1.copyWith(color: AppTheme.white)),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement url_launcher for tel:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling $phone...'), backgroundColor: AppTheme.accentColor),
                );
              },
              icon: const Icon(Icons.phone, size: 18, color: AppTheme.accentColor),
              label: Text('Call', style: TextStyle(color: AppTheme.accentColor)),
            ),
          ],
        ),
      ],
    );
  }
}
