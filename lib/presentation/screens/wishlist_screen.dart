import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_button.dart'; // Assuming we can use this or just standard buttons
import 'product_detail_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          final items = wishlist.wishlistItems;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppTheme.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: AppTheme.headline3.copyWith(color: AppTheme.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save items you love here!',
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65, // Adjusted for buttons
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Expanded(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: product.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : Image.asset(
                                      product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                wishlist.removeFromWishlist(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed from Wishlist'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Details Section
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${product.price.toStringAsFixed(0)}',
                            style: AppTheme.bodyText2.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<CartProvider>().addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to Cart!'),
                                    backgroundColor: AppTheme.accentColor,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
