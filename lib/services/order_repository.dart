import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/address.dart';
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

    // Create sample shipping address
    final shippingAddress = Address(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'John Doe',
      phoneNumber: '+1 (555) 123-4567',
      addressLine1: '123 Main Street',
      addressLine2: 'Apt 4B',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      country: 'United States',
      label: 'Home',
      isDefault: true,
    );

    // Create sample payment details
    final paymentDetails = PaymentDetails(
      method: PaymentMethod.creditCard,
      cardLastFour: '4567',
      cardBrand: 'Visa',
      amount: total,
      transactionDate: DateTime.now(),
    );

    // Create sample tracking history
    final trackingHistory = [
      OrderTracking(
        status: OrderStatus.pending,
        timestamp: DateTime.now(),
        description: 'Order placed successfully',
      ),
    ];

    final order = Order(
      id: orderId,
      items: orderItems,
      total: total,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      userId: userId,
      shippingAddress: shippingAddress,
      paymentDetails: paymentDetails,
      trackingHistory: trackingHistory,
      trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
    );

    _orders.add(order);
    return order;
  }

  // Mock orders for user fallback
  Future<List<Order>> _getMockOrdersForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Initialize sample orders if empty
    if (_orders.isEmpty) {
      await _initializeSampleOrders(userId);
    }
    
    final userOrders = _orders
        .where((order) => order.userId == userId)
        .toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return userOrders;
  }

  // Initialize sample orders with enhanced data
  Future<void> _initializeSampleOrders(String userId) async {
    final sampleProducts = await _getSampleProducts();
    
    // Sample Order 1 - Delivered
    final order1 = Order(
      id: 'ORD_001',
      items: [
        OrderItem(
          product: sampleProducts[0],
          quantity: 2,
          unitPrice: sampleProducts[0].price,
        ),
        OrderItem(
          product: sampleProducts[1],
          quantity: 1,
          unitPrice: sampleProducts[1].price,
        ),
      ],
      total: 149.97,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      status: OrderStatus.delivered,
      userId: userId,
      shippingAddress: Address(
        id: 'addr_001',
        fullName: 'John Doe',
        phoneNumber: '+1 (555) 123-4567',
        addressLine1: '123 Main Street',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'United States',
        label: 'Home',
        isDefault: true,
      ),
      paymentDetails: PaymentDetails(
        method: PaymentMethod.creditCard,
        cardLastFour: '4567',
        cardBrand: 'Visa',
        amount: 149.97,
        transactionDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      trackingHistory: [
        OrderTracking(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          description: 'Order placed successfully',
        ),
        OrderTracking(
          status: OrderStatus.confirmed,
          timestamp: DateTime.now().subtract(const Duration(days: 9)),
          description: 'Order confirmed and being prepared',
        ),
        OrderTracking(
          status: OrderStatus.shipped,
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          description: 'Package shipped from warehouse',
        ),
        OrderTracking(
          status: OrderStatus.delivered,
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          description: 'Package delivered successfully',
        ),
      ],
      trackingNumber: 'TRK001234567890',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 5)),
    );

    // Sample Order 2 - Shipped
    final order2 = Order(
      id: 'ORD_002',
      items: [
        OrderItem(
          product: sampleProducts[2],
          quantity: 1,
          unitPrice: sampleProducts[2].price,
        ),
      ],
      total: 79.99,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      userId: userId,
      shippingAddress: Address(
        id: 'addr_002',
        fullName: 'Jane Smith',
        phoneNumber: '+1 (555) 987-6543',
        addressLine1: '456 Oak Avenue',
        addressLine2: '',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90210',
        country: 'United States',
        label: 'Work',
        isDefault: false,
      ),
      paymentDetails: PaymentDetails(
        method: PaymentMethod.paypal,
        cardLastFour: null,
        cardBrand: null,
        amount: 79.99,
        transactionDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      trackingHistory: [
        OrderTracking(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          description: 'Order placed successfully',
        ),
        OrderTracking(
          status: OrderStatus.confirmed,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          description: 'Order confirmed and being prepared',
        ),
        OrderTracking(
          status: OrderStatus.shipped,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          description: 'Package shipped from warehouse',
        ),
      ],
      trackingNumber: 'TRK002345678901',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    );

    // Sample Order 3 - Pending
    final order3 = Order(
      id: 'ORD_003',
      items: [
        OrderItem(
          product: sampleProducts[3],
          quantity: 3,
          unitPrice: sampleProducts[3].price,
        ),
      ],
      total: 89.97,
      orderDate: DateTime.now().subtract(const Duration(hours: 6)),
      status: OrderStatus.pending,
      userId: userId,
      shippingAddress: Address(
        id: 'addr_003',
        fullName: 'Mike Johnson',
        phoneNumber: '+1 (555) 456-7890',
        addressLine1: '789 Pine Street',
        addressLine2: 'Suite 200',
        city: 'Chicago',
        state: 'IL',
        zipCode: '60601',
        country: 'United States',
        label: 'Other',
        isDefault: false,
      ),
      paymentDetails: PaymentDetails(
        method: PaymentMethod.applePay,
        cardLastFour: '8901',
        cardBrand: 'Mastercard',
        amount: 89.97,
        transactionDate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      trackingHistory: [
        OrderTracking(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          description: 'Order placed successfully',
        ),
      ],
      trackingNumber: 'TRK003456789012',
      estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
    );

    _orders.addAll([order1, order2, order3]);
  }

  // Get sample products for mock orders
  Future<List<Product>> _getSampleProducts() async {
    return [
      Product(
        id: 'prod_001',
        title: 'Wireless Bluetooth Headphones',
        name: 'Wireless Bluetooth Headphones',
        image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        description: 'High-quality wireless headphones with noise cancellation',
        price: 79.99,
        category: 'Electronics',
        rating: const Rating(rate: 4.5, count: 128),
      ),
      Product(
        id: 'prod_002',
        title: 'Smart Fitness Watch',
        name: 'Smart Fitness Watch',
        image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        description: 'Advanced fitness tracking with heart rate monitor',
        price: 199.99,
        category: 'Electronics',
        rating: const Rating(rate: 4.7, count: 89),
      ),
      Product(
        id: 'prod_003',
        title: 'Premium Coffee Beans',
        name: 'Premium Coffee Beans',
        image: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        description: 'Organic single-origin coffee beans, medium roast',
        price: 24.99,
        category: 'Food & Beverages',
        rating: const Rating(rate: 4.8, count: 256),
      ),
      Product(
        id: 'prod_004',
        title: 'Eco-Friendly Water Bottle',
        name: 'Eco-Friendly Water Bottle',
        image: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
        description: 'Stainless steel insulated water bottle, 32oz',
        price: 29.99,
        category: 'Sports & Outdoors',
        rating: const Rating(rate: 4.6, count: 167),
      ),
    ];
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
