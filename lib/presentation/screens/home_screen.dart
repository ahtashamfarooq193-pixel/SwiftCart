import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/mock_data.dart';
import '../../domain/entities/product.dart';
import 'product_detail_screen.dart';
import '../widgets/header_slider_widget.dart';
import '../widgets/flash_sale_section.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String? _selectedCategoryName; // Changed from id to name for filtering
  bool _isNotificationOn = true;

  @override
  void initState() {
    super.initState();
    // Copy and shuffle products for a randomized look
    _filteredProducts = List.from(MockData.products)..shuffle();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(MockData.products)..shuffle();
      } else {
        _filteredProducts = MockData.searchProducts(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger a rebuild
            setState(() {});
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar with Search and Notifications
                _buildAppBar(),

                const SizedBox(height: 12),

                // Promotions Carousel
                if (_searchController.text.isEmpty) ...[
                  const HeaderSliderWidget(),
                  const SizedBox(height: 16),
                  _buildCategoriesSection(),
                  const SizedBox(height: 8),
                  const FlashSaleSection(),
                  const SizedBox(height: 16),
                ],

                // Products Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _searchController.text.isEmpty ? 'Trending Now' : 'Search Results (${_filteredProducts.length})',
                        style: AppTheme.headline4.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_searchController.text.isEmpty)
                        TextButton(
                          onPressed: () {
                            context.read<NavigationProvider>().setIndex(1);
                          },
                          child: Text(
                            'See All',
                            style: AppTheme.caption.copyWith(color: AppTheme.accentColor),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  )
                else
                  _buildTrendingProductsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String displayName = 'User';
                      String email = FirebaseAuth.instance.currentUser?.email ?? '';
                      
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        if (data.containsKey('name') && data['name'].toString().isNotEmpty) {
                          displayName = data['name'];
                        } else if (email.isNotEmpty) {
                          displayName = email.split('@')[0];
                        }
                      } else if (email.isNotEmpty) {
                        displayName = email.split('@')[0];
                      }

                      return Text(
                        '$displayName 👋',
                        style: AppTheme.headline3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.white.withOpacity(0.1)),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isNotificationOn = !_isNotificationOn;
                    });
                  },
                  icon: Icon(
                    _isNotificationOn ? Icons.notifications_active : Icons.notifications_off,
                    color: _isNotificationOn ? AppTheme.accentColor : AppTheme.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.white.withOpacity(0.1)),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WishlistScreen()),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, color: AppTheme.accentColor),
                  tooltip: 'Wishlist',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppTheme.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.white.withOpacity(0.05),
              hintText: 'Search premium products...',
              hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingProductsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedCategoryName == null 
          ? FirebaseFirestore.instance.collection('products').snapshots()
          : FirebaseFirestore.instance.collection('products').where('category', isEqualTo: _selectedCategoryName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No products available', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.58,
            ),
            itemCount: docs.length > 15 ? 15 : docs.length,
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

              // Safe mapping for sizes and colors
              List<String> sizesList = [];
              if (data['sizes'] is List) {
                sizesList = List<String>.from(data['sizes']);
              } else if (data['sizes'] is String) {
                sizesList = [data['sizes']];
              }

              List<String> colorsList = [];
              if (data['colors'] is List) {
                colorsList = List<String>.from(data['colors']);
              } else if (data['colors'] is String) {
                colorsList = [data['colors']];
              }

              // Map Firestore data to Product object using specific fields: name, price, image, category
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
                sizes: sizesList,
                colors: colorsList,
                specifications: data['specifications'] ?? {},
                vendorId: data['vendorId'] ?? '',
                vendorName: data['vendorName'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );

              return _buildProductCard(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: AppTheme.headline4.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NavigationProvider>().setIndex(1);
                },
                child: Text(
                  'See All',
                  style: AppTheme.bodyText2.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Categories Horizontal List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('No categories', style: TextStyle(color: Colors.white)));
              }

              return SizedBox(
                height: 90, // Fixed height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;
                    final name = data['catName'] ?? 'Unknown';
                    final imageUrl = data['catImage'] ?? 'assets/images/placeholder.png';

                    return _buildCategoryCard(id, name, imageUrl);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String id, String name, String imageUrl) {
    final isSelected = _selectedCategoryName == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategoryName == name) {
            _selectedCategoryName = null; // Deselect if already selected
          } else {
            _selectedCategoryName = name;
          }
        });
      },
      child: Container(
        width: 70, // Fixed width for horizontal layout
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 48, // Smaller icon
              height: 48, // Smaller icon
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: AppTheme.accentColor, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.grey.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: AppTheme.caption.copyWith(
                color: isSelected ? AppTheme.accentColor : AppTheme.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 10, // Smaller text
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Single line for compact design
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildProductCard(Product product) {
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
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.grey.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Square)
            SizedBox(
              width: double.infinity,
              height: 90, // Reduced height to prevent overflow in 3-column grid
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  children: [
                    Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                        ),

                    // Rating Small Badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 8, color: AppTheme.accentColor),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: AppTheme.caption.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Wishlist Heart Icon
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final isFavorite = wishlist.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () {
                              wishlist.toggleWishlist(context, product);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 14,
                                color: isFavorite ? AppTheme.accentColor : AppTheme.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTheme.bodyText2.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      product.brand,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.grey,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs ${product.price.round()}',
                                style: AppTheme.bodyText2.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added!', style: const TextStyle(fontSize: 12)),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppTheme.accentColor,
                              ),
                            );
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppTheme.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


