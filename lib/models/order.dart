import 'package:equatable/equatable.dart';
import 'order_item.dart';
import 'address.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

enum PaymentMethod { creditCard, paypal, applePay }

class OrderTracking {
  final OrderStatus status;
  final DateTime timestamp;
  final String? description;
  final String? location;

  const OrderTracking({
    required this.status,
    required this.timestamp,
    this.description,
    this.location,
  });
}

class PaymentDetails {
  final PaymentMethod method;
  final String? cardLastFour;
  final String? cardBrand;
  final double amount;
  final DateTime transactionDate;
  final String? stripePaymentIntentId;
  final String? stripePaymentStatus;

  const PaymentDetails({
    required this.method,
    this.cardLastFour,
    this.cardBrand,
    required this.amount,
    required this.transactionDate,
    this.stripePaymentIntentId,
    this.stripePaymentStatus,
  });

  String get methodName {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit/Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }
}

class Order extends Equatable {
  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime orderDate;
  final OrderStatus status;
  final String userId;
  final Address? shippingAddress;
  final PaymentDetails? paymentDetails;
  final List<OrderTracking> trackingHistory;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
    required this.userId,
    this.shippingAddress,
    this.paymentDetails,
    this.trackingHistory = const [],
    this.trackingNumber,
    this.estimatedDelivery,
  });

  // Calculate total from items (for validation)
  double get calculatedTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Get total item count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Get current tracking status
  OrderTracking? get currentTracking {
    if (trackingHistory.isEmpty) return null;
    return trackingHistory.last;
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Copy with method for updating order status
  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? total,
    DateTime? orderDate,
    OrderStatus? status,
    String? userId,
    Address? shippingAddress,
    PaymentDetails? paymentDetails,
    List<OrderTracking>? trackingHistory,
    String? trackingNumber,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      trackingHistory: trackingHistory ?? this.trackingHistory,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        total,
        orderDate,
        status,
        userId,
        shippingAddress,
        paymentDetails,
        trackingHistory,
        trackingNumber,
        estimatedDelivery,
      ];
}
