import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import 'order_tracking_screen.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import 'product_detail_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('My Orders'), backgroundColor: AppTheme.primaryColor),
        body: const Center(child: Text('Please login to view orders', style: TextStyle(color: Colors.white))),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('My Orders'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
            },
          ),
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: AppTheme.headline3.copyWith(color: AppTheme.white)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final orderId = docs[index].id;
              return _buildOrderCard(context, data, orderId);
            },
          );
        },
      ),
      ), // PopScope child
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> data, String orderId) {
    final status = data['status'] as String? ?? 'Pending';
    final total = (data['totalAmount'] as num? ?? 0).toDouble();
    final items = data['itemsList'] as List<dynamic>? ?? [];
    final firstItemName = items.isNotEmpty ? items[0]['name'] : 'Unknown Item';
    final remainingCount = items.length - 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: orderId, orderData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}', style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold)),
                 _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    remainingCount > 0 ? '$firstItemName + $remainingCount more' : firstItemName,
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Rs ${total.toStringAsFixed(0)}',
                  style: AppTheme.bodyText1.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (status == 'Delivered') ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _navigateToFirstProduct(context, items),
                  icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppTheme.accentColor),
                  label: const Text('Write a Review', style: TextStyle(color: AppTheme.accentColor)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToFirstProduct(BuildContext context, List<dynamic> items) async {
    if (items.isEmpty) return;
    final itemData = items.first as Map<String, dynamic>;
    final productId = itemData['productId'] ?? itemData['id'];
    if (productId == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
    );

    try {
      var doc = await FirebaseFirestore.instance.collection('products').doc(productId.toString()).get();
      
      // Fallback: If not found by ID, maybe the ID stored was actually the product name (legacy bug)
      if (!doc.exists) {
        final name = itemData['name'] ?? productId.toString();
        print('MyOrders: Product not found by ID. Searching by name: $name');
        final query = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }

      if (context.mounted) Navigator.pop(context); // Close loading

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        List<String> getList(String key) {
           if (data[key] is List) return List<String>.from(data[key]);
           return [];
        }

        final product = Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          originalPrice: (data['originalPrice'] ?? (data['price'] ?? 0)).toDouble(),
          imageUrl: data['image'] ?? data['imageUrl'] ?? '',
          images: getList('images'),
          categoryId: data['categoryId'] ?? '',
          categoryName: data['categoryName'] ?? '',
          brand: data['brand'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          reviewCount: (data['reviewCount'] ?? 0).toInt(),
          isInStock: data['isInStock'] ?? true,
          stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
          sizes: getList('sizes'),
          colors: getList('colors'),
          specifications: data['specifications'] ?? {},
          vendorId: data['vendorId'] ?? '',
          vendorName: data['vendorName'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );

        if (context.mounted) {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product detail not found'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loader if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Processing':
        color = AppTheme.warningColor; // Orange
        break;
      case 'Payment Verified':
        color = AppTheme.accentColor; // Violet/Blue
        break;
      case 'Delivered':
        color = AppTheme.successColor; // Green
        break;
      case 'Cancelled':
        color = AppTheme.errorColor; // Red
        break;
      default:
        color = AppTheme.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
