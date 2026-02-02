class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final int stockQuantity;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, dynamic> specifications;
  final String vendorId;
  final String vendorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFlashSale;
  final DateTime? flashSaleEndDate;
  final double? discountPercentage;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.brand,
    required this.rating,
    required this.reviewCount,
    required this.isInStock,
    required this.stockQuantity,
    required this.sizes,
    required this.colors,
    required this.specifications,
    required this.vendorId,
    required this.vendorName,
    required this.createdAt,
    required this.updatedAt,
    this.isFlashSale = false,
    this.flashSaleEndDate,
    this.discountPercentage,
  });

  bool get isOnSale => originalPrice > price;
  double get discount => isOnSale ? ((originalPrice - price) / originalPrice) * 100 : 0;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    String? brand,
    double? rating,
    int? reviewCount,
    bool? isInStock,
    int? stockQuantity,
    List<String>? sizes,
    List<String>? colors,
    Map<String, dynamic>? specifications,
    String? vendorId,
    String? vendorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFlashSale,
    DateTime? flashSaleEndDate,
    double? discountPercentage,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isInStock: isInStock ?? this.isInStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      specifications: specifications ?? this.specifications,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      flashSaleEndDate: flashSaleEndDate ?? this.flashSaleEndDate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


