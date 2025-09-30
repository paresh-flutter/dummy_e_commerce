import 'package:equatable/equatable.dart';
import 'product.dart';

class OrderItem extends Equatable {
  final Product product;
  final int quantity;
  final double unitPrice; // Price at time of order (for historical accuracy)

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  // Calculate total price for this item
  double get totalPrice => unitPrice * quantity;

  // Create from CartItem
  factory OrderItem.fromCartItem(Product product, int quantity) {
    return OrderItem(
      product: product,
      quantity: quantity,
      unitPrice: product.price, // Capture current price
    );
  }

  @override
  List<Object?> get props => [product, quantity, unitPrice];
}
