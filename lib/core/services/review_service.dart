import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a review to a product and update the product's average rating.
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final productRef = _firestore.collection('products').doc(productId);
    final reviewRef = productRef.collection('reviews').doc(userId); // Use userId as docId to prevent duplicates

    return _firestore.runTransaction((transaction) async {
      final productSnapshot = await transaction.get(productRef);
      
      print('ReviewService: Adding review to path: ${reviewRef.path}');
      print('ReviewService: Data - Rating: $rating, Comment: $comment');

      if (!productSnapshot.exists) {
        throw Exception("Product does not exist!");
      }

      final data = productSnapshot.data()!;
      final double currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final int currentReviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

      // Calculate new average
      // If user is updating review, we would need old rating, but assuming new review for simplicity or strict 1-review policy
      // To handle updates correctly, we'd need to read the old review first.
      // For this implementation, we'll assume it's a new review or simple overwrite logic might skew avg slightly without complex math.
      // To be robust:
      
      // Check if review exists (we can't read reviewRef inside transaction unless we do it first, 
      // but strictly we should structure this to handle potential overwrite)
      // For MVP: We will just recalculate based on simple moving average formula approximation or total sum storage.
      // Better approach for scaling: Store 'totalRatingSum' and 'reviewCount'. 
      // Since we only have 'rating' (avg), we approximate:
      
      double totalRatingScore = currentRating * currentReviewCount;
      double newRating = ((totalRatingScore + rating) / (currentReviewCount + 1));


      transaction.set(reviewRef, {
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(productRef, {
        'rating': double.parse(newRating.toStringAsFixed(1)), // Keep it to 1 decimal
        'reviewCount': currentReviewCount + 1,
      });
    });
  }

  /// Check if a user can review a product.
  /// Returns true if the user has a 'Delivered' order containing this product.
  Future<bool> canUserReview(String userId, String productId) async {
    try {
      // 1. Check if user already reviewed (Strict 1-review policy)
      final reviewDoc = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(userId)
          .get();
      
      if (reviewDoc.exists) {
        print('ReviewService: User already reviewed this product ($productId).');
        return false; 
      }

      // 2. Check orders for 'Delivered' status containing this product
      // We check the user's sub-collection first as it's more efficient
      print('ReviewService: Checking for Delivered orders for user $userId and product $productId...');
      
      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .where('status', isEqualTo: 'Delivered')
          .get();
      
      print('ReviewService: Found ${ordersSnapshot.docs.length} Delivered orders in user sub-collection.');

      // If not found in user sub-collection, try root orders (backward compatibility)
      var docs = ordersSnapshot.docs;
      if (docs.isEmpty) {
        final rootOrdersSnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'Delivered')
            .get();
        docs = rootOrdersSnapshot.docs;
        print('ReviewService: Found ${docs.length} Delivered orders in root collection.');
      }

      if (docs.isEmpty) {
        print('ReviewService: No Delivered orders found for user $userId.');
        return false;
      }

      // Fetch product name for name-based matching fallback
      String? targetProductName;
      try {
        final prodDoc = await _firestore.collection('products').doc(productId).get();
        if (prodDoc.exists) {
           targetProductName = (prodDoc.data() as Map<String, dynamic>?)?['name'];
        }
      } catch (e) {
        print('ReviewService: Could not fetch product name for fallback: $e');
      }

      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check both 'itemsList' and 'items'
        final items = (data['itemsList'] ?? data['items']) as List<dynamic>? ?? [];
        print('ReviewService: Inspecting Order ${doc.id} with ${items.length} items...');
        
        for (var item in items) {
          final itemMap = item as Map<String, dynamic>;
          final itemId = (itemMap['productId'] ?? itemMap['id'])?.toString();
          final itemName = itemMap['name']?.toString();
          
          print('ReviewService:   - Item Product ID: $itemId, Name: $itemName (Target: $productId / $targetProductName)');
          
          if (itemId == productId.toString() || 
              itemName == productId.toString() ||
              (targetProductName != null && itemName == targetProductName)) {
             print('ReviewService: MATCH FOUND! Valid Delivered order (${doc.id}).');
             return true;
          }
        }
      }
      
      print('ReviewService: Product $productId not found in any Delivered orders for user $userId.');
      return false;

    } catch (e) {
      print('Error checking review eligibility: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getReviewsStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
