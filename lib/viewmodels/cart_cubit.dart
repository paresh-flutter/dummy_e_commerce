import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/firestore_cart_service.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final FirestoreCartService _cartService = FirestoreCartService();
  String? _currentUserId;

  CartCubit() : super(const CartState(items: {}));

  // Set current user ID for API calls
  void setUserId(String? userId) {
    print('CartCubit: setUserId called with: $userId');
    _currentUserId = userId;
    print('CartCubit: _currentUserId is now: $_currentUserId');
    if (userId != null) {
      print('CartCubit: Loading user cart for user: $userId');
      loadUserCart(userId);
    } else {
      print('CartCubit: User ID is null, clearing cart');
    }
  }

  // Load user's cart from Firestore
  Future<void> loadUserCart(String userId) async {
    try {
      final cartItems = await _cartService.getUserCart(userId);
      emit(state.copyWith(items: cartItems));
    } catch (e) {
      print('Error loading cart: $e');
      emit(state.copyWith(items: {}));
    }
  }

  // Add product to cart
  Future<void> add(Product product) async {
    print('CartCubit: add() called for product: ${product.name}');
    print('CartCubit: _currentUserId is: $_currentUserId');
    if (_currentUserId != null) {
      try {
        final existing = state.items[product.id];
        print('CartCubit: Current quantity: ${existing?.quantity ?? 0}');
        
        // FIXED: Always add 1 to the cart service, let it handle the quantity logic
        final updatedCart = await _cartService.addProductToCart(
          userId: _currentUserId!,
          product: product,
          quantity: 1, // CRITICAL FIX: Always add 1, let cart service handle accumulation
        );
        
        // Update local state with the cart from Firestore
        emit(state.copyWith(items: updatedCart));
        print('CartCubit: Successfully added to cart, updated cart has ${updatedCart.length} items');
      } catch (e) {
        print('Error adding to cart: $e');
        // Fallback to local state update
        final updatedItems = Map<String, CartItem>.from(state.items);
        final existing = updatedItems[product.id];
        if (existing != null) {
          updatedItems[product.id] = existing.copyWith(quantity: existing.quantity + 1);
        } else {
          updatedItems[product.id] = CartItem(product: product, quantity: 1);
        }
        emit(state.copyWith(items: updatedItems));
        print('CartCubit: Fallback update completed');
      }
    } else {
      print('Error: No user logged in, cannot add to cart');
    }
  }

  // Remove product from cart
  Future<void> remove(Product product) async {
    if (_currentUserId != null) {
      try {
        await _cartService.removeFromCart(
          userId: _currentUserId!,
          productId: product.id,
        );
        
        // Update local state
        final updatedItems = Map<String, CartItem>.from(state.items);
        updatedItems.remove(product.id);
        emit(state.copyWith(items: updatedItems));
      } catch (e) {
        print('Error removing from cart: $e');
      }
    }
  }

  // Update product quantity in cart
  Future<void> updateQty(Product product, int qty) async {
    if (qty <= 0) {
      return remove(product);
    }

    if (_currentUserId != null) {
      try {
        await _cartService.updateCartItem(
          userId: _currentUserId!,
          productId: product.id,
          quantity: qty,
        );
        
        // Update local state
        final updatedItems = Map<String, CartItem>.from(state.items);
        updatedItems[product.id] = CartItem(product: product, quantity: qty);
        emit(state.copyWith(items: updatedItems));
      } catch (e) {
        print('Error updating cart: $e');
      }
    }
  }

  // Increment product quantity
  Future<void> increment(Product product) async {
    final currentQty = state.items[product.id]?.quantity ?? 0;
    await updateQty(product, currentQty + 1);
  }

  // Decrement product quantity
  Future<void> decrement(Product product) async {
    final currentQty = state.items[product.id]?.quantity ?? 0;
    await updateQty(product, currentQty - 1);
  }

  // Clear entire cart
  Future<void> clear() async {
    print('CartCubit: clear() called');
    print('CartCubit: _currentUserId is: $_currentUserId');
    if (_currentUserId != null) {
      try {
        print('CartCubit: Clearing cart from Firestore for user: $_currentUserId');
        await _cartService.clearCart(_currentUserId!);
        emit(const CartState(items: {}));
        print('CartCubit: Cart cleared successfully');
      } catch (e) {
        print('CartCubit: Error clearing cart: $e');
        // Still clear local state even if Firestore fails
        emit(const CartState(items: {}));
      }
    } else {
      print('CartCubit: No user logged in, clearing local cart only');
      emit(const CartState(items: {}));
    }
  }

  // Clear cart (for backward compatibility)
  Future<void> clearCart() async {
    await clear();
  }


  // Getters
  int get itemCount => state.items.values.fold(0, (sum, e) => sum + e.quantity);
  double get total => state.items.values.fold(0, (sum, e) => sum + e.totalPrice);
}
