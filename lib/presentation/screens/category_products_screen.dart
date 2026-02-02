import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No products found in this category',
                    style: AppTheme.bodyText1.copyWith(color: AppTheme.grey),
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
              childAspectRatio: 0.7,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Safe mapping for images list (handling single string error)
              List<String> imagesList = [];
              if (data['image'] is String) {
                imagesList = [data['image']];
              } else if (data['images'] is List) {
                imagesList = List<String>.from(data['images']);
              } else if (data['images'] is String) {
                imagesList = [data['images']];
              }

              final product = Product(
                id: docs[index].id,
                name: data['name'] ?? 'Unknown',
                description: data['description'] ?? '',
                price: (data['price'] ?? 0).toDouble(),
                originalPrice: (data['originalPrice'] ?? (data['price'] ?? 0)).toDouble(),
                imageUrl: data['image'] ?? 'assets/images/placeholder.png',
                images: imagesList,
                categoryId: '',
                categoryName: data['category'] ?? '', // Consistently using 'category' field
                brand: data['brand'] ?? '',
                rating: (data['rating'] ?? 0).toDouble(),
                reviewCount: data['reviewCount'] ?? 0,
                isInStock: data['isInStock'] ?? true,
                stockQuantity: data['stockQuantity'] ?? 0,
                sizes: List<String>.from(data['sizes'] ?? []),
                colors: List<String>.from(data['colors'] ?? []),
                specifications: data['specifications'] ?? {},
                vendorId: data['vendorId'] ?? '',
                vendorName: data['vendorName'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );

              return _buildProductCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs ${product.price.toStringAsFixed(2)}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.add_circle, color: AppTheme.accentColor, size: 20),
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
