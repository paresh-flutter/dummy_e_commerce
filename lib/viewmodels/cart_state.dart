part of 'cart_cubit.dart';

class CartState extends Equatable {
  final Map<String, CartItem> items; // key: productId
  const CartState({required this.items});

  CartState copyWith({Map<String, CartItem>? items}) => CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
