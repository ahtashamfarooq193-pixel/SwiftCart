import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import '../../domain/entities/product.dart';

class FlashSaleSection extends StatefulWidget {
  const FlashSaleSection({super.key});

  @override
  State<FlashSaleSection> createState() => _FlashSaleSectionState();
}

class _FlashSaleSectionState extends State<FlashSaleSection> {
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
  }

  // Helper function to format duration (moved to CounterTimer)


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Timer Stream
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('flash_sale_timer').limit(1).snapshots(),
            builder: (context, snapshot) {
              DateTime? endTime;
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                if (data['endTime'] != null) {
                  endTime = (data['endTime'] as Timestamp).toDate();
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Flash Sale',
                        style: AppTheme.headline4.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (endTime != null)
                    _CountdownTimer(endTime: endTime)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '00:00:00',
                        style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Products Horizontal List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('flash_sale').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                );
              }

              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No Flash Sale products', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final data = products[index].data() as Map<String, dynamic>;
                    return _buildFlashSaleCard(context, data, products[index].id);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleCard(BuildContext context, Map<String, dynamic> data, String docId) {
    // Map Firestore data to Product object for consistent use in Detail Screen
    final product = Product(
      id: docId,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      price: (data['currentPrice'] ?? 0).toDouble(),
      originalPrice: (data['oldPrice'] ?? 0).toDouble(),
      imageUrl: data['image'] ?? 'assets/images/placeholder.png',
      images: data['images'] != null ? List<String>.from(data['images']) : [data['image'] ?? 'assets/images/placeholder.png'],
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      brand: data['brand'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isInStock: data['isInStock'] ?? true,
      stockQuantity: data['stockQuantity'] ?? 0,
      sizes: data['sizes'] != null ? List<String>.from(data['sizes']) : [],
      colors: data['colors'] != null ? List<String>.from(data['colors']) : [],
      specifications: data['specifications'] ?? {},
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Stack(
                children: [
                   Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        product.imageUrl.isNotEmpty ? product.imageUrl : 'assets/images/placeholder.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/placeholder.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Discount Badge
                  Positioned(
                    top: 10,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${data['discountPercentage'] ?? 0}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Rs ${product.originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppTheme.grey.withOpacity(0.6),
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dedicated widget for the countdown timer to isolate rebuilds
class _CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  const _CountdownTimer({required this.endTime});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late String _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = _calculateTimeLeft();
    _startTimer();
  }

  @override
  void didUpdateWidget(_CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _timer.cancel();
      _timeLeft = _calculateTimeLeft();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTimeLeft = _calculateTimeLeft();
      if (newTimeLeft != _timeLeft) {
        setState(() {
          _timeLeft = newTimeLeft;
        });
      }
      if (newTimeLeft == 'Sale Ended') {
        _timer.cancel();
      }
    });
  }

  String _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.endTime.difference(now);

    if (difference.isNegative) {
      return 'Sale Ended';
    } else {
      return _formatDuration(difference);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    // Support more than 24 hours if needed, but following HH:MM:SS
    int hours = duration.inHours;
    return "${twoDigits(hours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.amethystGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _timeLeft,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
