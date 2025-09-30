part of 'wishlist_cubit.dart';

class WishlistState extends Equatable {
  final Map<String, Product> items; // key: productId, value: Product

  const WishlistState({required this.items});

  WishlistState copyWith({Map<String, Product>? items}) {
    return WishlistState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
