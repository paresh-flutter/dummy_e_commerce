import '../order.dart';
import '../order_item.dart';
import '../product.dart';

class OrderDto {
  final String id;
  final String userId;
  final List<OrderItemDto> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderDto({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      items: (json['items'] as List)
          .map((item) => OrderItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert to domain model (requires product data)
  Order toDomain(Map<String, Product> products) {
    final orderItems = items.map((itemDto) {
      final product = products[itemDto.productId];
      if (product == null) {
        throw Exception('Product not found for order item: ${itemDto.productId}');
      }
      return itemDto.toDomain(product);
    }).toList();

    return Order(
      id: id,
      items: orderItems,
      total: total,
      orderDate: createdAt,
      status: _parseOrderStatus(status),
      userId: userId,
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemDto {
  final String productId;
  final int quantity;
  final double unitPrice;
  final String productName;
  final String productImage;

  const OrderItemDto({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.productName,
    required this.productImage,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      productId: json['productId'].toString(),
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'productName': productName,
      'productImage': productImage,
    };
  }

  // Convert to domain model
  OrderItem toDomain(Product product) {
    return OrderItem(
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}

class CreateOrderRequestDto {
  final List<CreateOrderItemDto> items;

  const CreateOrderRequestDto({
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItemDto {
  final String productId;
  final int quantity;

  const CreateOrderItemDto({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class UpdateOrderStatusRequestDto {
  final String status;

  const UpdateOrderStatusRequestDto({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
