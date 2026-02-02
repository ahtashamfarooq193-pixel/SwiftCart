import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/circular_order_tracker.dart';
import 'package:intl/intl.dart';
import '../../core/services/review_service.dart';
import '../../domain/entities/product.dart';
import 'product_detail_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? orderData; // Optional initial data

  const OrderTrackingScreen({super.key, required this.orderId, this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
           if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
           }
           
           // Use initial data while waiting if available, or show loader
           if (snapshot.connectionState == ConnectionState.waiting) {
              if (orderData != null) {
                return _buildBody(context, orderData!);
              }
              return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
           }

           if (!snapshot.hasData || !snapshot.data!.exists) {
             return const Center(child: Text('Order not found', style: TextStyle(color: Colors.white)));
           }

           final data = snapshot.data!.data() as Map<String, dynamic>;
           return _buildBody(context, data);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, dynamic> data) {
    return SingleChildScrollView(
        child: Column(
          children: [
            // Header Info
            _buildOrderHeader(data),
            
            // Timeline
            _buildTrackingTimeline(data),
            
            // Order Details
            _buildOrderDetails(context, data),
            
            const SizedBox(height: 30),
          ],
        ),
      );
  }

  Widget _buildOrderHeader(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'Processing';
    final estDateTimestamp = data['estimatedDeliveryDate'] as Timestamp?;
    // If estDate is not in DB, assume 5 days from created
    final createdTimestamp = data['timestamp'] as Timestamp? ?? Timestamp.now();
    final estDate = estDateTimestamp?.toDate() ?? createdTimestamp.toDate().add(const Duration(days: 5));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
                  ),
                  Text(
                    '#${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                    style: AppTheme.headline4.copyWith(color: AppTheme.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentColor.withOpacity(0.5)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppTheme.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimated Delivery:',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
              ),
              const Spacer(),
              Text(
                DateFormat('EEE, d MMM').format(estDate),
                style: AppTheme.bodyText2.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'Processing';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: CircularOrderTracker(status: status),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Processing':
        return 'Your order is being processed and prepared for shipment.';
      case 'Payment Verified':
        return 'We have successfully verified your payment.';
      case 'Delivered':
        return 'Order has been delivered successfully.';
      default:
        return '';
    }
  }

  Widget _buildOrderDetails(BuildContext context, Map<String, dynamic> data) {
    final shipping = data['shippingAddress'] as Map<String, dynamic>? ?? {};
    final address = shipping['addressLine1'] ?? '';
    final phone = shipping['phoneNumber'] ?? '';
    final paymentId = data['paymentId'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: AppTheme.headline4.copyWith(color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Payment ID', paymentId, Icons.receipt_long_outlined),
          const SizedBox(height: 12),
          _buildDetailRow('Shipping Address', address, Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildDetailRow('Contact Info', phone, Icons.phone_outlined),
          
          if (data['status'] == 'Delivered') ...[
             const SizedBox(height: 24),
             const Divider(color: Colors.white12),
             const SizedBox(height: 16),
             Text(
               'Order Items',
               style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 12),
             ...((data['itemsList'] ?? data['items']) as List<dynamic>? ?? []).map((item) {
                final itemMap = item as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          itemMap['image'] ?? '',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppTheme.grey, width: 40, height: 40),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(itemMap['name'] ?? 'Product', style: AppTheme.bodyText2.copyWith(color: AppTheme.white)),
                            Text('Qty: ${itemMap['quantity']}', style: AppTheme.caption.copyWith(color: AppTheme.grey)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToProduct(context, itemMap),
                        child: const Text('Review', style: TextStyle(color: AppTheme.accentColor)),
                      ),
                    ],
                  ),
                );
             }),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.caption.copyWith(color: AppTheme.grey)),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.bodyText2.copyWith(color: AppTheme.white)),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToProduct(BuildContext context, Map<String, dynamic> itemData) async {
    final productId = itemData['productId'] ?? itemData['id'];
    if (productId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
    );

    // Fetch full product data to open detail screen
    try {
      var doc = await FirebaseFirestore.instance.collection('products').doc(productId.toString()).get();
      
      // Fallback: If not found by ID, maybe the ID stored was actually the product name (legacy bug)
      if (!doc.exists) {
        final name = itemData['name'] ?? productId.toString();
        print('OrderTracking: Product not found by ID. Searching by name: $name');
        final query = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }

      if (context.mounted) Navigator.pop(context); // Close loading dialog

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
            const SnackBar(content: Text('Product details not found'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }
}
