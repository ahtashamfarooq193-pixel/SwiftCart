import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../../data/models/mock_data.dart';
import '../widgets/custom_button.dart';
import '../providers/cart_provider.dart';

import '../../core/services/review_service.dart';
import '../widgets/custom_rating_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  
  bool _canReview = false;
  double _userRating = 5.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkReviewEligibility() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final canReview = await _reviewService.canUserReview(user.uid, widget.product.id);
      if (mounted) {
        setState(() {
          _canReview = canReview;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Validation is now handled in UI, but good to keep a check or just proceed
    if (_commentController.text.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
    }

    print('ProductDetail: Submitting review for ${widget.product.id} by user ${user.uid}...');
    
    // Just call the service. UI handling specifically is done in the bottom sheet.
    await _reviewService.addReview(
      productId: widget.product.id,
      userId: user.uid,
      userName: user.displayName ?? 'User',
      rating: _userRating,
      comment: _commentController.text.trim(),
    );

    print('ProductDetail: Review submitted successfully.');
  }

  @override
  Widget build(BuildContext context) {
    // Filter related products (same category, different id)
    final relatedProducts = MockData.products
        .where((p) => p.categoryId == widget.product.categoryId && p.id != widget.product.id)
        .take(6)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product.id}',
                child: Image.asset(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: AppTheme.headline2.copyWith(color: AppTheme.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.brand,
                              style: AppTheme.bodyText1.copyWith(color: AppTheme.accentColor),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.amethystGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Rs ${widget.product.price.toStringAsFixed(2)}',
                          style: AppTheme.headline3.copyWith(color: AppTheme.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Rating Summary
                  Row(
                    children: [
                     CustomRatingBar(
                       rating: widget.product.rating,
                       size: 20,
                       isReadOnly: true,
                     ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.product.rating} (${widget.product.reviewCount} Reviews)',
                        style: AppTheme.caption.copyWith(color: AppTheme.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text('Description', style: AppTheme.headline4.copyWith(color: AppTheme.white)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.lightGrey, height: 1.6),
                  ),

                  const SizedBox(height: 32),

                  // --- Ratings & Reviews Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Ratings & Reviews',
                          style: AppTheme.headline3.copyWith(color: AppTheme.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_canReview)
                        TextButton.icon(
                          onPressed: () => _showReviewBottomSheet(context),
                          icon: const Icon(Icons.rate_review, size: 18, color: AppTheme.accentColor),
                          label: const Text('Write a Review', style: TextStyle(color: AppTheme.accentColor)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Reviews List
                  StreamBuilder<QuerySnapshot>(
                    stream: _reviewService.getReviewsStream(widget.product.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Error loading reviews', style: TextStyle(color: AppTheme.errorColor));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      final reviews = snapshot.data?.docs ?? [];
                      if (reviews.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No reviews yet. Be the first!',
                            style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final data = reviews[index].data() as Map<String, dynamic>;
                          final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                          final comment = data['comment'] as String? ?? '';
                          final userName = data['userName'] as String? ?? 'User';
                          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      userName,
                                      style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                                    ),
                                    if (timestamp != null)
                                      Text(
                                        DateFormat.yMMMd().format(timestamp),
                                        style: AppTheme.caption.copyWith(color: AppTheme.grey),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                CustomRatingBar(rating: rating, size: 14, isReadOnly: true),
                                const SizedBox(height: 8),
                                Text(
                                  comment,
                                  style: AppTheme.bodyText2.copyWith(color: AppTheme.lightGrey),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Related Products Section
                  if (relatedProducts.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Related Products',
                            style: AppTheme.headline3.copyWith(color: AppTheme.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final related = relatedProducts[index];
                          return _buildRelatedCard(context, related);
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          border: Border(top: BorderSide(color: AppTheme.white.withOpacity(0.1))),
        ),
        child: CustomButton(
          text: 'Add to Cart',
          onPressed: () async {
            await context.read<CartProvider>().addToCart(widget.product);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.product.name} added to cart!'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showReviewBottomSheet(BuildContext context) {
    // Reset state for new review attempt
    setState(() {
      _userRating = 0.0;
      _commentController.clear();
      _isSubmitting = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            bool isValid = _userRating > 0 && _commentController.text.trim().isNotEmpty;

            return Container(
              width: double.infinity, // Explicitly constrain width
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(builderContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Write a Review',
                      style: AppTheme.headline3.copyWith(color: AppTheme.white),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: CustomRatingBar(
                        rating: _userRating,
                        size: 40,
                        isReadOnly: false,
                        onRatingUpdate: (rating) {
                          print('ProductDetailScreen: Updating rating to $rating');
                          setModalState(() => _userRating = rating);
                        },
                      ),
                    ),
                    if (_userRating == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(child: Text('Tap stars to rate', style: TextStyle(color: AppTheme.accentColor.withOpacity(0.7), fontSize: 12))),
                      ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _commentController,
                      style: const TextStyle(color: AppTheme.white),
                      maxLines: 4,
                      onChanged: (_) => setModalState(() {}), // Trigger rebuild for validation
                      decoration: InputDecoration(
                        hintText: 'Share your experience with this product...',
                        hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppTheme.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || !isValid)
                          ? null 
                          : () async {
                              print('ProductDetailScreen: Submit clicked. Rating: $_userRating');
                              setModalState(() => _isSubmitting = true);
                              try {
                                await _submitReview();
                                
                                if (builderContext.mounted) {
                                  Navigator.pop(builderContext); // Close sheet ONLY on success
                                  ScaffoldMessenger.of(builderContext).showSnackBar(
                                    const SnackBar(
                                      content: Text('Review submitted successfully!'),
                                      backgroundColor: AppTheme.accentColor,
                                    ),
                                  );
                                  // Update parent state to hide button
                                  setState(() {
                                    _canReview = false; 
                                  });
                                }
                              } catch (e) {
                                print('Submit Error in UI: $e');
                                if (builderContext.mounted) {
                                   ScaffoldMessenger.of(builderContext).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to submit: $e'),
                                      backgroundColor: AppTheme.errorColor,
                                    ),
                                  );
                                }
                              } finally {
                                if (builderContext.mounted) {
                                  setModalState(() => _isSubmitting = false);
                                }
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          disabledBackgroundColor: AppTheme.grey.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRelatedCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${product.price.toStringAsFixed(2)}',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
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
