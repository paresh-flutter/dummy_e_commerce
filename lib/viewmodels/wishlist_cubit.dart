import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../services/firestore_wishlist_service.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final FirestoreWishlistService _wishlistService = FirestoreWishlistService();
  String? _currentUserId;

  WishlistCubit() : super(const WishlistState(items: {}));

  // Set current user ID and load wishlist
  void setUserId(String? userId) {
    print('WishlistCubit: setUserId called with: $userId');
    _currentUserId = userId;
    print('WishlistCubit: _currentUserId is now: $_currentUserId');
    if (userId != null) {
      print('WishlistCubit: Loading user wishlist for user: $userId');
      loadUserWishlist(userId);
    } else {
      print('WishlistCubit: User ID is null, clearing wishlist');
      emit(const WishlistState(items: {}));
    }
  }

  // Load user's wishlist from Firestore
  Future<void> loadUserWishlist(String userId) async {
    try {
      final wishlistProducts = await _wishlistService.getUserWishlist(userId);
      final wishlistMap = Map<String, Product>.fromEntries(
        wishlistProducts.map((product) => MapEntry(product.id, product))
      );
      emit(state.copyWith(items: wishlistMap));
    } catch (e) {
      print('Error loading wishlist: $e');
      emit(state.copyWith(items: {}));
    }
  }

  // Add product to wishlist
  Future<void> addToWishlist(Product product) async {
    print('WishlistCubit: addToWishlist() called for product: ${product.name}');
    print('WishlistCubit: _currentUserId is: $_currentUserId');
    if (_currentUserId != null) {
      try {
        await _wishlistService.addToWishlist(userId: _currentUserId!, productId: product.id);
        final updatedItems = Map<String, Product>.from(state.items);
        updatedItems[product.id] = product;
        emit(state.copyWith(items: updatedItems));
        print('Product ${product.name} added to wishlist');
      } catch (e) {
        print('Error adding to wishlist: $e');
        // Fallback to local state update
        final updatedItems = Map<String, Product>.from(state.items);
        updatedItems[product.id] = product;
        emit(state.copyWith(items: updatedItems));
      }
    } else {
      print('Error: No user logged in, cannot add to wishlist');
    }
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(Product product) async {
    if (_currentUserId != null) {
      try {
        await _wishlistService.removeFromWishlist(userId: _currentUserId!, productId: product.id);
        final updatedItems = Map<String, Product>.from(state.items);
        updatedItems.remove(product.id);
        emit(state.copyWith(items: updatedItems));
      } catch (e) {
        print('Error removing from wishlist: $e');
      }
    }
  }

  // Toggle product in wishlist
  Future<void> toggleWishlist(Product product) async {
    if (isInWishlist(product)) {
      await removeFromWishlist(product);
    } else {
      await addToWishlist(product);
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(Product product) {
    return state.items.containsKey(product.id);
  }

  // Get wishlist items as list
  List<Product> get wishlistItems => state.items.values.toList();

  // Get wishlist count
  int get itemCount => state.items.length;

  // Clear all wishlist items
  Future<void> clearWishlist() async {
    if (_currentUserId != null) {
      try {
        await _wishlistService.clearWishlist(_currentUserId!);
        emit(const WishlistState(items: {}));
      } catch (e) {
        print('Error clearing wishlist: $e');
      }
    }
  }
}
