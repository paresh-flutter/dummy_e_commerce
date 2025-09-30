import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(const WishlistState(items: {}));

  // Add product to wishlist
  void addToWishlist(Product product) {
    final updatedItems = Map<String, Product>.from(state.items);
    updatedItems[product.id] = product;
    emit(state.copyWith(items: updatedItems));
  }

  // Remove product from wishlist
  void removeFromWishlist(Product product) {
    final updatedItems = Map<String, Product>.from(state.items);
    updatedItems.remove(product.id);
    emit(state.copyWith(items: updatedItems));
  }

  // Toggle product in wishlist
  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
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
  void clearWishlist() {
    emit(const WishlistState(items: {}));
  }
}
