import '../cart_item.dart';
import '../product.dart';

class CartDto {
  final String id;
  final String userId;
  final List<CartItemDto> items;
  final DateTime updatedAt;

  const CartDto({
    required this.id,
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      items: (json['items'] as List)
          .map((item) => CartItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CartItemDto {
  final String productId;
  final int quantity;
  final double price;

  const CartItemDto({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      productId: json['productId'].toString(),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  // Convert to domain model (requires product data)
  CartItem toDomain(Product product) {
    return CartItem(
      product: product,
      quantity: quantity,
    );
  }
}

class AddToCartRequestDto {
  final String productId;
  final int quantity;

  const AddToCartRequestDto({
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

class UpdateCartItemRequestDto {
  final String productId;
  final int quantity;

  const UpdateCartItemRequestDto({
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
