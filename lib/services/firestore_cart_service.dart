import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'firestore_service.dart';

/// Cart service that uses Firestore for data storage
class FirestoreCartService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Get user's cart from Firestore
  Future<Map<String, CartItem>> getUserCart(String userId) async {
    print('FirestoreCartService: getUserCart called for userId: $userId');
    try {
      final cart = await _firestoreService.getUserCart(userId);
      print('FirestoreCartService: Retrieved cart with ${cart.length} items');
      cart.forEach((key, value) {
        print('FirestoreCartService: Cart item: ${value.product.name} (qty: ${value.quantity})');
      });
      return cart;
    } catch (e) {
      print('FirestoreCartService: Error getting user cart: $e');
      // Return empty cart if Firestore fails
      return {};
    }
  }

  /// Add item to cart with product data - More reliable approach
  Future<Map<String, CartItem>> addProductToCart({
    required String userId,
    required Product product,
    required int quantity,
  }) async {
    print('FirestoreCartService: addProductToCart called');
    print('FirestoreCartService: userId: $userId');
    print('FirestoreCartService: product: ${product.name} (${product.id})');
    print('FirestoreCartService: quantity to add: $quantity');
    
    try {
      // Get current cart from Firestore
      print('FirestoreCartService: Getting current cart from Firestore...');
      final currentCart = await getUserCart(userId);
      print('FirestoreCartService: Current cart has ${currentCart.length} items');
      
      // Add or update item in cart
      if (currentCart.containsKey(product.id)) {
        // Update existing item quantity
        final existingItem = currentCart[product.id]!;
        final oldQuantity = existingItem.quantity;
        final newQuantity = oldQuantity + quantity;
        
        print('FirestoreCartService: Product exists - updating quantity from $oldQuantity to $newQuantity');
        currentCart[product.id] = existingItem.copyWith(
          quantity: newQuantity,
        );
      } else {
        // Add new item to cart
        print('FirestoreCartService: New product - adding with quantity $quantity');
        currentCart[product.id] = CartItem(
          product: product,
          quantity: quantity,
        );
      }

      print('FirestoreCartService: Cart now has ${currentCart.length} unique items');
      currentCart.forEach((key, value) {
        print('FirestoreCartService: - ${value.product.name}: ${value.quantity}');
      });

      // Update cart in Firestore with complete product data
      print('FirestoreCartService: Updating cart in Firestore...');
      await _updateCartInFirestore(userId, currentCart);
      print('FirestoreCartService: Cart successfully updated in Firestore');
      
      return currentCart;
    } catch (e) {
      print('FirestoreCartService: Error adding product to cart: $e');
      return {};
    }
  }

  /// Legacy method for backward compatibility - converts to product-based call
  Future<Map<String, CartItem>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      // Try to get product from Firestore first
      final product = await _firestoreService.getProductById(productId);
      if (product != null) {
        return await addProductToCart(
          userId: userId,
          product: product,
          quantity: quantity,
        );
      } else {
        // Fallback with placeholder product
        final placeholderProduct = Product(
          id: productId,
          title: 'Product $productId',
          name: 'Product $productId',
          image: 'https://via.placeholder.com/400',
          imageUrl: 'https://via.placeholder.com/400',
          price: 99.99,
          description: 'Product description',
          category: 'General',
          rating: null,
        );
        return await addProductToCart(
          userId: userId,
          product: placeholderProduct,
          quantity: quantity,
        );
      }
    } catch (e) {
      print('Error in legacy addToCart: $e');
      return {};
    }
  }

  /// Update cart in Firestore with complete product data
  Future<void> _updateCartInFirestore(String userId, Map<String, CartItem> cartItems) async {
    try {
      // Use the existing updateUserCart method from FirestoreService
      await _firestoreService.updateUserCart(userId, cartItems);
    } catch (e) {
      throw Exception('Failed to update cart in Firestore: $e');
    }
  }

  /// Update cart item quantity in Firestore
  Future<Map<String, CartItem>> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      // Get current cart
      final currentCart = await getUserCart(userId);
      
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        currentCart.remove(productId);
      } else {
        // Update item quantity
        if (currentCart.containsKey(productId)) {
          final existingItem = currentCart[productId]!;
          currentCart[productId] = existingItem.copyWith(quantity: quantity);
        } else {
          // Item doesn't exist, treat as add
          return await addToCart(
            userId: userId,
            productId: productId,
            quantity: quantity,
          );
        }
      }

      // Update cart in Firestore
      await _firestoreService.updateUserCart(userId, currentCart);
      
      return currentCart;
    } catch (e) {
      // Fallback to local cart management
      return _handleLocalCartOperation(userId, productId, quantity, 'update');
    }
  }

  /// Remove item from cart in Firestore
  Future<Map<String, CartItem>> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      // Get current cart
      final currentCart = await getUserCart(userId);
      
      // Remove item from cart
      currentCart.remove(productId);

      // Update cart in Firestore
      await _firestoreService.updateUserCart(userId, currentCart);
      
      return currentCart;
    } catch (e) {
      // Fallback to local cart management
      return _handleLocalCartOperation(userId, productId, 0, 'remove');
    }
  }

  /// Clear entire cart in Firestore
  Future<void> clearCart(String userId) async {
    try {
      await _firestoreService.clearUserCart(userId);
    } catch (e) {
      // Clear local cart if Firestore fails
      _localCarts.remove(userId);
    }
  }

  /// Sync local cart with Firestore
  Future<Map<String, CartItem>> syncCart({
    required String userId,
    required Map<String, CartItem> localCart,
  }) async {
    try {
      // Update Firestore with local cart data
      await _firestoreService.updateUserCart(userId, localCart);
      
      // Return the synced cart
      return localCart;
    } catch (e) {
      // Return local cart if sync fails
      return localCart;
    }
  }

  /// Get cart total value
  double getCartTotal(Map<String, CartItem> cart) {
    return cart.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Get total item count in cart
  int getCartItemCount(Map<String, CartItem> cart) {
    return cart.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if product is in cart
  bool isProductInCart(Map<String, CartItem> cart, String productId) {
    return cart.containsKey(productId);
  }

  /// Get quantity of specific product in cart
  int getProductQuantityInCart(Map<String, CartItem> cart, String productId) {
    return cart[productId]?.quantity ?? 0;
  }

  // Local cart storage for fallback
  static final Map<String, Map<String, CartItem>> _localCarts = {};

  /// Handle local cart operations when Firestore is unavailable
  Future<Map<String, CartItem>> _handleLocalCartOperation(
    String userId,
    String productId,
    int quantity,
    String operation,
  ) async {
    // Get or create local cart for user
    _localCarts[userId] ??= {};
    final userCart = _localCarts[userId]!;

    switch (operation) {
      case 'add':
        final product = await _firestoreService.getProductById(productId);
        if (product != null) {
          if (userCart.containsKey(productId)) {
            final existingItem = userCart[productId]!;
            userCart[productId] = existingItem.copyWith(
              quantity: existingItem.quantity + quantity,
            );
          } else {
            userCart[productId] = CartItem(product: product, quantity: quantity);
          }
        }
        break;
      case 'update':
        final product = await _firestoreService.getProductById(productId);
        if (product != null) {
          if (quantity > 0) {
            userCart[productId] = CartItem(product: product, quantity: quantity);
          } else {
            userCart.remove(productId);
          }
        }
        break;
      case 'remove':
        userCart.remove(productId);
        break;
    }

    return Map.from(userCart);
  }

  /// Get local cart (fallback)
  Map<String, CartItem> getLocalCart(String userId) {
    return Map.from(_localCarts[userId] ?? {});
  }

  /// Clear local cart
  void clearLocalCart(String userId) {
    _localCarts.remove(userId);
  }

  /// Validate cart items (check if products still exist and prices are current)
  Future<Map<String, CartItem>> validateCart(String userId) async {
    try {
      final cart = await getUserCart(userId);
      final validatedCart = <String, CartItem>{};
      
      for (final item in cart.values) {
        // Check if product still exists
        final currentProduct = await _firestoreService.getProductById(item.product.id);
        if (currentProduct != null) {
          // Update cart item with current product data (in case price changed)
          validatedCart[currentProduct.id] = CartItem(
            product: currentProduct,
            quantity: item.quantity,
          );
        }
        // If product doesn't exist, it's automatically removed from cart
      }
      
      // Update cart in Firestore if changes were made
      if (validatedCart.length != cart.length) {
        await _firestoreService.updateUserCart(userId, validatedCart);
      }
      
      return validatedCart;
    } catch (e) {
      // Return current cart if validation fails
      return await getUserCart(userId);
    }
  }
}