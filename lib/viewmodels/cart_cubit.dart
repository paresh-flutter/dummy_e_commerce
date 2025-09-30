import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartService _cartService = CartService();
  String? _currentUserId;

  CartCubit() : super(const CartState(items: {}));

  // Set current user ID for API calls
  void setUserId(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      loadUserCart(userId);
    }
  }

  // Load user's cart from API
  Future<void> loadUserCart(String userId) async {
    try {
      final cartItems = await _cartService.getUserCart(userId);
      emit(state.copyWith(items: cartItems));
    } catch (e) {
      // Use local cart if API fails
      final localCart = _cartService.getLocalCart(userId);
      emit(state.copyWith(items: localCart));
    }
  }

  // Add product to cart
  Future<void> add(Product product) async {
    if (_currentUserId != null) {
      try {
        final existing = state.items[product.id];
        final newQuantity = (existing?.quantity ?? 0) + 1;
        
        final updatedCart = await _cartService.addToCart(
          userId: _currentUserId!,
          productId: product.id,
          quantity: newQuantity,
        );
        
        emit(state.copyWith(items: updatedCart));
      } catch (e) {
        // Fallback to local cart update
        _updateLocalCart(product, (state.items[product.id]?.quantity ?? 0) + 1);
      }
    } else {
      // Local cart only
      _updateLocalCart(product, (state.items[product.id]?.quantity ?? 0) + 1);
    }
  }

  // Remove product from cart
  Future<void> remove(Product product) async {
    if (_currentUserId != null) {
      try {
        final updatedCart = await _cartService.removeFromCart(
          userId: _currentUserId!,
          productId: product.id,
        );
        
        emit(state.copyWith(items: updatedCart));
      } catch (e) {
        // Fallback to local cart update
        _removeFromLocalCart(product);
      }
    } else {
      // Local cart only
      _removeFromLocalCart(product);
    }
  }

  // Update product quantity in cart
  Future<void> updateQty(Product product, int qty) async {
    if (qty <= 0) {
      return remove(product);
    }

    if (_currentUserId != null) {
      try {
        final updatedCart = await _cartService.updateCartItem(
          userId: _currentUserId!,
          productId: product.id,
          quantity: qty,
        );
        
        emit(state.copyWith(items: updatedCart));
      } catch (e) {
        // Fallback to local cart update
        _updateLocalCart(product, qty);
      }
    } else {
      // Local cart only
      _updateLocalCart(product, qty);
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
    if (_currentUserId != null) {
      try {
        await _cartService.clearCart(_currentUserId!);
      } catch (e) {
        // Continue with local clear even if API fails
      }
    }
    emit(const CartState(items: {}));
  }

  // Sync local cart with server
  Future<void> syncCart() async {
    if (_currentUserId != null && state.items.isNotEmpty) {
      try {
        final syncedCart = await _cartService.syncCart(
          userId: _currentUserId!,
          localCart: state.items,
        );
        emit(state.copyWith(items: syncedCart));
      } catch (e) {
        // Keep local cart if sync fails
      }
    }
  }

  // Local cart operations (fallback)
  void _updateLocalCart(Product product, int quantity) {
    final map = Map<String, CartItem>.from(state.items);
    map[product.id] = CartItem(product: product, quantity: quantity);
    emit(state.copyWith(items: map));
  }

  void _removeFromLocalCart(Product product) {
    final map = Map<String, CartItem>.from(state.items);
    map.remove(product.id);
    emit(state.copyWith(items: map));
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      // Try to clear from API if user is authenticated
      await _cartService.clearCart("user_id"); // Simplified for now
      emit(state.copyWith(items: {}));
    } catch (e) {
      // Fallback to local clear
      emit(state.copyWith(items: {}));
    }
  }

  // Getters
  int get itemCount => state.items.values.fold(0, (sum, e) => sum + e.quantity);
  double get total => state.items.values.fold(0, (sum, e) => sum + e.totalPrice);
}
