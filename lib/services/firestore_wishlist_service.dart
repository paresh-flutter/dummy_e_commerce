import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/user.dart';

/// Service to manage user wishlist data in Firestore
class FirestoreWishlistService {
  static final FirestoreWishlistService _instance = FirestoreWishlistService._internal();
  factory FirestoreWishlistService() => _instance;
  FirestoreWishlistService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');
  
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  /// Add a product to user's wishlist
  Future<void> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      // Verify product exists
      final productDoc = await _productsCollection.doc(productId).get();
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      await _usersCollection.doc(userId).update({
        'wishlistProductIds': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  /// Remove a product from user's wishlist
  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'wishlistProductIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  /// Get user's wishlist with full product details
  Future<List<Product>> getUserWishlist(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        return [];
      }

      final data = userDoc.data()!;
      final wishlistProductIds = List<String>.from(data['wishlistProductIds'] ?? []);

      if (wishlistProductIds.isEmpty) {
        return [];
      }

      // Get product details for each wishlist item
      final List<Product> wishlistProducts = [];
      for (final productId in wishlistProductIds) {
        final productDoc = await _productsCollection.doc(productId).get();
        if (productDoc.exists && productDoc.data() != null) {
          final productData = productDoc.data()!;
          final ratingData = productData['rating'] as Map<String, dynamic>?;
          
          final product = Product(
            id: productData['id'] ?? productId,
            title: productData['title'] ?? '',
            name: productData['name'] ?? '',
            image: productData['image'] ?? '',
            imageUrl: productData['imageUrl'] ?? '',
            price: (productData['price'] ?? 0).toDouble(),
            description: productData['description'] ?? '',
            category: productData['category'] ?? '',
            rating: ratingData != null ? Rating(
              rate: (ratingData['rate'] ?? 0).toDouble(),
              count: ratingData['count'] ?? 0,
            ) : null,
          );
          wishlistProducts.add(product);
        }
      }

      return wishlistProducts;
    } catch (e) {
      throw Exception('Failed to get user wishlist: $e');
    }
  }

  /// Check if a product is in user's wishlist
  Future<bool> isProductInWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        return false;
      }

      final data = userDoc.data()!;
      final wishlistProductIds = List<String>.from(data['wishlistProductIds'] ?? []);
      return wishlistProductIds.contains(productId);
    } catch (e) {
      throw Exception('Failed to check wishlist status: $e');
    }
  }

  /// Toggle product in wishlist (add if not present, remove if present)
  Future<bool> toggleWishlistProduct({
    required String userId,
    required String productId,
  }) async {
    try {
      final isInWishlist = await isProductInWishlist(userId: userId, productId: productId);
      
      if (isInWishlist) {
        await removeFromWishlist(userId: userId, productId: productId);
        return false; // Removed from wishlist
      } else {
        await addToWishlist(userId: userId, productId: productId);
        return true; // Added to wishlist
      }
    } catch (e) {
      throw Exception('Failed to toggle wishlist product: $e');
    }
  }

  /// Clear user's entire wishlist
  Future<void> clearWishlist(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'wishlistProductIds': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }

  /// Get wishlist count for a user
  Future<int> getWishlistCount(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        return 0;
      }

      final data = userDoc.data()!;
      final wishlistProductIds = List<String>.from(data['wishlistProductIds'] ?? []);
      return wishlistProductIds.length;
    } catch (e) {
      throw Exception('Failed to get wishlist count: $e');
    }
  }

  /// Stream for real-time wishlist updates
  Stream<List<Product>> getUserWishlistStream(String userId) {
    return _usersCollection.doc(userId).snapshots().asyncMap((userSnapshot) async {
      if (!userSnapshot.exists || userSnapshot.data() == null) {
        return <Product>[];
      }

      final data = userSnapshot.data()!;
      final wishlistProductIds = List<String>.from(data['wishlistProductIds'] ?? []);

      if (wishlistProductIds.isEmpty) {
        return <Product>[];
      }

      // Get product details for each wishlist item
      final List<Product> wishlistProducts = [];
      for (final productId in wishlistProductIds) {
        try {
          final productDoc = await _productsCollection.doc(productId).get();
          if (productDoc.exists && productDoc.data() != null) {
            final productData = productDoc.data()!;
            final ratingData = productData['rating'] as Map<String, dynamic>?;
            
            final product = Product(
              id: productData['id'] ?? productId,
              title: productData['title'] ?? '',
              name: productData['name'] ?? '',
              image: productData['image'] ?? '',
              imageUrl: productData['imageUrl'] ?? '',
              price: (productData['price'] ?? 0).toDouble(),
              description: productData['description'] ?? '',
              category: productData['category'] ?? '',
              rating: ratingData != null ? Rating(
                rate: (ratingData['rate'] ?? 0).toDouble(),
                count: ratingData['count'] ?? 0,
              ) : null,
            );
            wishlistProducts.add(product);
          }
        } catch (e) {
          // Skip products that fail to load
          continue;
        }
      }

      return wishlistProducts;
    });
  }
}