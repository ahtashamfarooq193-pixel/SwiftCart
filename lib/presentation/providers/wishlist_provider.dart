import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/product.dart';

class WishlistProvider with ChangeNotifier {
  Set<String> _wishlistIds = {};
  List<Product> _wishlistItems = [];
  StreamSubscription<QuerySnapshot>? _wishlistSubscription;

  Set<String> get wishlistIds => _wishlistIds;
  List<Product> get wishlistItems => _wishlistItems;

  WishlistProvider() {
    _initWishlistListener();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initWishlistListener();
      } else {
        _wishlistSubscription?.cancel();
        _wishlistIds = {};
        _wishlistItems = [];
        notifyListeners();
      }
    });
  }

  void _initWishlistListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _wishlistSubscription?.cancel();
    _wishlistSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .snapshots()
        .listen((snapshot) {
      _wishlistIds = snapshot.docs.map((doc) => doc.id).toSet();
      
      _wishlistItems = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          description: '', // Not stored in wishlist structure for now
          price: (data['price'] as num).toDouble(),
          imageUrl: data['image'] ?? '',
          // Default values for fields not stored in minimal wishlist doc
          vendorId: '',
          vendorName: '',
          images: [data['image'] ?? ''],
          sizes: [],
          colors: [],
          specifications: {},
          categoryId: '',
          categoryName: '',
          brand: '',
          isInStock: true,
          originalPrice: (data['price'] as num).toDouble(),
          rating: 0,
          reviewCount: 0,
          stockQuantity: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      notifyListeners();
    });
  }

  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to use wishlist')),
      );
      return;
    }

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    if (isInWishlist(product.id)) {
      // Remove
      await collection.doc(product.id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from Wishlist'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Add
      await collection.doc(product.id).set({
        'name': product.name,
        'price': product.price,
        'image': product.imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to Wishlist!'),
            backgroundColor: Color(0xFFA78BFA), // Purple acccent
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
