import 'user.dart';

enum OrderStatus {
  pending('Order Placed'),
  paymentVerification('Payment Verification'),
  confirmed('Confirmed'),
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled'),
  refunded('Refunded');

  const OrderStatus(this.displayName);
  final String displayName;
}

enum PaymentStatus {
  pending('Pending'),
  paid('Paid'),
  failed('Failed'),
  refunded('Refunded');

  const PaymentStatus(this.displayName);
  final String displayName;
}

enum PaymentMethod {
  creditCard('Credit Card'),
  debitCard('Debit Card'),
  paypal('PayPal'),
  applePay('Apple Pay'),
  googlePay('Google Pay'),
  cashOnDelivery('Cash on Delivery');

  const PaymentMethod(this.displayName);
  final String displayName;
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final Address shippingAddress;
  final Address? billingAddress;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String? promoCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? estimatedDeliveryDate;
  final String? trackingNumber;
  final List<OrderStatusUpdate> statusUpdates;
  final String? manualTid;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    this.billingAddress,
    this.promoCode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedDeliveryDate,
    this.trackingNumber,
    required this.statusUpdates,
    this.manualTid,
  });

  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    Address? shippingAddress,
    Address? billingAddress,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? total,
    String? promoCode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDeliveryDate,
    String? trackingNumber,
    List<OrderStatusUpdate>? statusUpdates,
    String? manualTid,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      manualTid: manualTid ?? this.manualTid,
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;
  final String selectedSize;
  final String selectedColor;
  final DateTime createdAt;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    required this.createdAt,
  });

  double get totalPrice => price * quantity;

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImageUrl,
    double? price,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderStatusUpdate {
  final OrderStatus status;
  final String description;
  final DateTime timestamp;
  final String? updatedBy;

  const OrderStatusUpdate({
    required this.status,
    required this.description,
    required this.timestamp,
    this.updatedBy,
  });
}
