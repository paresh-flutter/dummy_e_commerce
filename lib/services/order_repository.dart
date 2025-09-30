import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/api/order_dto.dart';
import 'api_client.dart';
import 'product_service.dart';

class OrderRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final ProductService _productService = ProductService();
  
  // Mock local storage fallback
  static final List<Order> _orders = [];

  // Create a new order from cart items
  Future<Order> createOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
  }) async {
    try {
      // Convert cart items to order request
      final orderItems = cartItems.values.map((cartItem) {
        return CreateOrderItemDto(
          productId: cartItem.product.id,
          quantity: cartItem.quantity,
        );
      }).toList();

      final request = CreateOrderRequestDto(items: orderItems);

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/orders',
        data: request.toJson(),
      );

      if (response.data != null) {
        final orderDto = OrderDto.fromJson(response.data!);
        
        // Get product data for order items
        final products = <String, Product>{};
        for (final item in cartItems.values) {
          products[item.product.id] = item.product;
        }
        
        return orderDto.toDomain(products);
      }

      throw Exception('Failed to create order');
    } catch (e) {
      // Fallback to mock order creation
      return _createMockOrder(cartItems: cartItems, userId: userId);
    }
  }

  // Get orders for a specific user
  Future<List<Order>> getOrdersForUser(String userId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/orders/user/$userId');

      if (response.data != null) {
        final orders = <Order>[];
        
        for (final orderJson in response.data!) {
          final orderDto = OrderDto.fromJson(orderJson as Map<String, dynamic>);
          
          // Get product data for each order
          final products = <String, Product>{};
          for (final itemDto in orderDto.items) {
            final product = await _productService.getProductById(itemDto.productId);
            if (product != null) {
              products[itemDto.productId] = product;
            }
          }
          
          orders.add(orderDto.toDomain(products));
        }
        
        return orders..sort((a, b) => b.orderDate.compareTo(a.orderDate));
      }

      return [];
    } catch (e) {
      // Fallback to mock orders
      return _getMockOrdersForUser(userId);
    }
  }

  // Get all orders (for admin purposes)
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/orders');

      if (response.data != null) {
        final orders = <Order>[];
        
        for (final orderJson in response.data!) {
          final orderDto = OrderDto.fromJson(orderJson as Map<String, dynamic>);
          
          // Get product data for each order
          final products = <String, Product>{};
          for (final itemDto in orderDto.items) {
            final product = await _productService.getProductById(itemDto.productId);
            if (product != null) {
              products[itemDto.productId] = product;
            }
          }
          
          orders.add(orderDto.toDomain(products));
        }
        
        return orders..sort((a, b) => b.orderDate.compareTo(a.orderDate));
      }

      return [];
    } catch (e) {
      // Fallback to mock orders
      return List.from(_orders)..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    }
  }

  // Update order status
  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final request = UpdateOrderStatusRequestDto(
        status: _orderStatusToString(newStatus),
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/orders/$orderId/status',
        data: request.toJson(),
      );

      if (response.data != null) {
        final orderDto = OrderDto.fromJson(response.data!);
        
        // Get product data for order items
        final products = <String, Product>{};
        for (final itemDto in orderDto.items) {
          final product = await _productService.getProductById(itemDto.productId);
          if (product != null) {
            products[itemDto.productId] = product;
          }
        }
        
        return orderDto.toDomain(products);
      }

      throw Exception('Failed to update order status');
    } catch (e) {
      // Fallback to mock update
      return _updateMockOrderStatus(orderId, newStatus);
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/orders/$orderId');

      if (response.data != null) {
        final orderDto = OrderDto.fromJson(response.data!);
        
        // Get product data for order items
        final products = <String, Product>{};
        for (final itemDto in orderDto.items) {
          final product = await _productService.getProductById(itemDto.productId);
          if (product != null) {
            products[itemDto.productId] = product;
          }
        }
        
        return orderDto.toDomain(products);
      }

      return null;
    } catch (e) {
      // Fallback to mock data
      try {
        return _orders.firstWhere((order) => order.id == orderId);
      } catch (_) {
        return null;
      }
    }
  }

  // Mock order creation fallback
  Future<Order> _createMockOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final orderItems = cartItems.values.map((cartItem) {
      return OrderItem.fromCartItem(cartItem.product, cartItem.quantity);
    }).toList();

    final total = orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    final order = Order(
      id: orderId,
      items: orderItems,
      total: total,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      userId: userId,
    );

    _orders.add(order);
    return order;
  }

  // Mock orders for user fallback
  Future<List<Order>> _getMockOrdersForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final userOrders = _orders
        .where((order) => order.userId == userId)
        .toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return userOrders;
  }

  // Mock order status update fallback
  Future<Order> _updateMockOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _orders[orderIndex].copyWith(status: newStatus);
    _orders[orderIndex] = updatedOrder;

    return updatedOrder;
  }

  // Convert OrderStatus enum to string
  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  // Clear all orders (for testing purposes)
  void clearAllOrders() {
    _orders.clear();
  }
}
