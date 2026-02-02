import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String selectedSize;
  final String selectedColor;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;
  double get originalTotalPrice => product.originalPrice * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product.id == product.id &&
        other.selectedSize == selectedSize &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode =>
      product.id.hashCode ^ selectedSize.hashCode ^ selectedColor.hashCode;
}

class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String? promoCode;
  final DateTime updatedAt;

  const Cart({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    this.promoCode,
    required this.updatedAt,
  });

  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? total,
    String? promoCode,
    DateTime? updatedAt,
  }) {
    return Cart(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  CartItem? getItemByProductId(String productId) {
    return items.cast<CartItem?>().firstWhere(
          (item) => item?.product.id == productId,
          orElse: () => null,
        );
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }
}


