import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  Cart _cart = Cart(
    items: [],
    subtotal: 0,
    tax: 0,
    shipping: 150,
    discount: 0,
    total: 0,
    updatedAt: DateTime.now(),
  );

  StreamSubscription<QuerySnapshot>? _cartSubscription;

  Cart get cart => _cart;

  CartProvider() {
    _initCartListener();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initCartListener();
      } else {
        _cartSubscription?.cancel();
        _updateCart([]); // Clear local cart on logout
      }
    });
  }

  void _initCartListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _cartSubscription?.cancel();
    _cartSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      final List<CartItem> items = snapshot.docs.map((doc) {
        final data = doc.data();
        return CartItem(
          id: doc.id,
          addedAt: DateTime.now(), // Fallback as we map from Firestore
          product: Product(
            id: data['productId'] ?? doc.id,
            name: data['name'] ?? '',
            description: '',
            price: (data['price'] as num).toDouble(),
            imageUrl: data['image'] ?? '',
            // Provide default values for required fields not in cart
            vendorId: 'admin', 
            vendorName: 'SwiftCart',
            images: [data['image'] ?? ''], // Add images list
            sizes: [], // Not needed for cart display context
            colors: [],
            specifications: {},
            categoryId: 'general',
            categoryName: 'General',
            brand: 'Generic',
            isInStock: true,
            originalPrice: (data['price'] as num).toDouble(),
            rating: 5.0,
            reviewCount: 0,
            stockQuantity: 100,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          quantity: data['quantity'] ?? 1,
          selectedSize: data['selectedSize'] ?? 'M',
          selectedColor: data['selectedColor'] ?? 'Black',
        );
      }).toList();
      _updateCart(items);
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  Future<void> addToCart(Product product, {String selectedSize = 'M', String selectedColor = 'Black'}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle unauthenticated user if necessary, or just return
      return; 
    }

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final docRef = cartCollection.doc(product.id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Item exists, increment quantity
      await docRef.update({
        'quantity': FieldValue.increment(1),
        'timestamp': FieldValue.serverTimestamp(), // Update timestamp on modification
      });
    } else {
      // Item does not exist, set new document
      await docRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.imageUrl,
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
        'selectedSize': selectedSize, // Saving these as good practice even if not explicitly asked for all fields
        'selectedColor': selectedColor,
      });
    }
    
    // Note: We are not updating the local _cart state here efficiently because 
    // the requirement focuses on the Firestore logic. In a full implementation, 
    // we would likely listen to the Firestore stream to update the local UI.
    // For now, we leave the local state update for immediate UI feedback if desired,
    // or we could rely on a separate stream listener.
  }

  Future<void> removeFromCart(String cartItemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    // Optimistic update (optional, but good for UI responsiveness)
    // For now we rely on stream, but we must update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': newQuantity});
  }

  void _updateCart(List<CartItem> items) {
    double subtotal = items.fold(0, (sum, item) => sum + item.totalPrice);
    double tax = 0; // Tax removed for simpler summary
    double shipping = subtotal > 0 ? 150.0 : 0.0;
    double total = subtotal + shipping - _cart.discount;

    _cart = _cart.copyWith(
      items: items,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _updateCart([]);
      return;
    }

    // Clear Firestore cart
    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');
    
    final snapshot = await cartCollection.get();
    final batch = FirebaseFirestore.instance.batch();
    
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    // Local state should auto-update via listener, but we can optionally force clear
    _updateCart([]); // Optional immediate feedback
  }
}
