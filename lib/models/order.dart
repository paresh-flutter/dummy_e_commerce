import 'package:equatable/equatable.dart';
import 'order_item.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class Order extends Equatable {
  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime orderDate;
  final OrderStatus status;
  final String userId;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
    required this.userId,
  });

  // Calculate total from items (for validation)
  double get calculatedTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Get total item count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Copy with method for updating order status
  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? total,
    DateTime? orderDate,
    OrderStatus? status,
    String? userId,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, items, total, orderDate, status, userId];
}
