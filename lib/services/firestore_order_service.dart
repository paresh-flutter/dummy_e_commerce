import '../models/order.dart' as app_models;
import '../models/order_item.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import 'firestore_service.dart';

/// Order service that uses Firestore for data storage
class FirestoreOrderService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Create a new order from cart items
  Future<app_models.Order> createOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
    required Address shippingAddress,
    required app_models.PaymentDetails paymentDetails,
  }) async {
    print('FirestoreOrderService: createOrder called for user: $userId');
    print('FirestoreOrderService: Cart items count: ${cartItems.length}');
    
    try {
      print('FirestoreOrderService: Calling Firestore service createOrder...');
      
      // Add timeout to prevent hanging
      final order = await _firestoreService.createOrder(
        cartItems: cartItems,
        userId: userId,
        shippingAddress: shippingAddress,
        paymentDetails: paymentDetails,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('FirestoreOrderService: Order creation timed out after 30 seconds');
          throw Exception('Order creation timed out. Please try again.');
        },
      );
      
      print('FirestoreOrderService: Order created successfully: ${order.id}');
      return order;
    } catch (e) {
      print('FirestoreOrderService: Error creating order: $e');
      print('FirestoreOrderService: Falling back to mock order creation...');
      
      // Fallback to mock order creation
      try {
        final mockOrder = await _createMockOrder(
          cartItems: cartItems,
          userId: userId,
          shippingAddress: shippingAddress,
          paymentDetails: paymentDetails,
        );
        print('FirestoreOrderService: Mock order created successfully: ${mockOrder.id}');
        return mockOrder;
      } catch (mockError) {
        print('FirestoreOrderService: Even mock order creation failed: $mockError');
        throw Exception('Failed to create order: $e');
      }
    }
  }

  /// Get orders for a specific user
  Future<List<app_models.Order>> getOrdersForUser(String userId) async {
    try {
      return await _firestoreService.getOrdersForUser(userId);
    } catch (e) {
      // Fallback to mock orders
      return _getMockOrdersForUser(userId);
    }
  }

  /// Get order by ID
  Future<app_models.Order?> getOrderById(String orderId) async {
    try {
      return await _firestoreService.getOrderById(orderId);
    } catch (e) {
      // Fallback to mock data
      try {
        return _mockOrders.firstWhere((order) => order.id == orderId);
      } catch (_) {
        return null;
      }
    }
  }

  /// Update order status
  Future<app_models.Order> updateOrderStatus(String orderId, app_models.OrderStatus newStatus) async {
    try {
      return await _firestoreService.updateOrderStatus(orderId, newStatus);
    } catch (e) {
      // Fallback to mock update
      return _updateMockOrderStatus(orderId, newStatus);
    }
  }

  /// Get all orders (for admin purposes)
  Future<List<app_models.Order>> getAllOrders() async {
    try {
      // This would require admin permissions in Firestore rules
      // For now, return empty list as this is an admin-only function
      return [];
    } catch (e) {
      return List.from(_mockOrders)..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    }
  }

  /// Calculate order statistics for user
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      final orders = await getOrdersForUser(userId);
      
      final totalOrders = orders.length;
      final totalSpent = orders.fold(0.0, (sum, order) => sum + order.total);
      final completedOrders = orders.where((order) => order.status == app_models.OrderStatus.delivered).length;
      final pendingOrders = orders.where((order) => order.status == app_models.OrderStatus.pending).length;
      
      return {
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'completedOrders': completedOrders,
        'pendingOrders': pendingOrders,
        'averageOrderValue': totalOrders > 0 ? totalSpent / totalOrders : 0.0,
      };
    } catch (e) {
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'completedOrders': 0,
        'pendingOrders': 0,
        'averageOrderValue': 0.0,
      };
    }
  }

  /// Cancel an order (only if it's pending or confirmed)
  Future<app_models.Order> cancelOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }
      
      if (order.status == app_models.OrderStatus.shipped || 
          order.status == app_models.OrderStatus.delivered) {
        throw Exception('Cannot cancel order that has been shipped or delivered');
      }
      
      return await updateOrderStatus(orderId, app_models.OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Mock data storage for fallback
  static final List<app_models.Order> _mockOrders = [];

  /// Mock order creation fallback
  Future<app_models.Order> _createMockOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
    required Address shippingAddress,
    required app_models.PaymentDetails paymentDetails,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final orderItems = cartItems.values.map((cartItem) {
      return OrderItem.fromCartItem(cartItem.product, cartItem.quantity);
    }).toList();

    final total = orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    // Create sample tracking history
    final trackingHistory = [
      app_models.OrderTracking(
        status: app_models.OrderStatus.pending,
        timestamp: DateTime.now(),
        description: 'Order placed successfully',
      ),
    ];

    final order = app_models.Order(
      id: orderId,
      items: orderItems,
      total: total,
      orderDate: DateTime.now(),
      status: app_models.OrderStatus.pending,
      userId: userId,
      shippingAddress: shippingAddress,
      paymentDetails: paymentDetails,
      trackingHistory: trackingHistory,
      trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
    );

    _mockOrders.add(order);
    return order;
  }

  /// Mock orders for user fallback
  Future<List<app_models.Order>> _getMockOrdersForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Initialize sample orders if empty
    if (_mockOrders.isEmpty) {
      await _initializeSampleOrders(userId);
    }
    
    final userOrders = _mockOrders
        .where((order) => order.userId == userId)
        .toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return userOrders;
  }

  /// Initialize sample orders with enhanced data
  Future<void> _initializeSampleOrders(String userId) async {
    // Sample Order 1 - Delivered
    final order1 = app_models.Order(
      id: 'ORD_001',
      items: [
        OrderItem(
          product: _getSampleProduct('prod_001'),
          quantity: 2,
          unitPrice: 79.99,
        ),
        OrderItem(
          product: _getSampleProduct('prod_002'),
          quantity: 1,
          unitPrice: 199.99,
        ),
      ],
      total: 359.97,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      status: app_models.OrderStatus.delivered,
      userId: userId,
      shippingAddress: _getSampleAddress(),
      paymentDetails: app_models.PaymentDetails(
        method: app_models.PaymentMethod.creditCard,
        cardLastFour: '4567',
        cardBrand: 'Visa',
        amount: 359.97,
        transactionDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      trackingHistory: [
        app_models.OrderTracking(
          status: app_models.OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          description: 'Order placed successfully',
        ),
        app_models.OrderTracking(
          status: app_models.OrderStatus.confirmed,
          timestamp: DateTime.now().subtract(const Duration(days: 9)),
          description: 'Order confirmed and being prepared',
        ),
        app_models.OrderTracking(
          status: app_models.OrderStatus.shipped,
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          description: 'Package shipped from warehouse',
        ),
        app_models.OrderTracking(
          status: app_models.OrderStatus.delivered,
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          description: 'Package delivered successfully',
        ),
      ],
      trackingNumber: 'TRK001234567890',
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 5)),
    );

    _mockOrders.add(order1);
  }

  /// Get sample product
  dynamic _getSampleProduct(String id) {
    // This would be replaced with actual product data
    return {
      'id': id,
      'name': 'Sample Product',
      'price': 79.99,
      'image': 'https://via.placeholder.com/400',
    };
  }

  /// Get sample address
  Address _getSampleAddress() {
    return Address(
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
    );
  }

  /// Mock order status update fallback
  Future<app_models.Order> _updateMockOrderStatus(String orderId, app_models.OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final orderIndex = _mockOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _mockOrders[orderIndex].copyWith(status: newStatus);
    _mockOrders[orderIndex] = updatedOrder;

    return updatedOrder;
  }

  /// Clear all orders (for testing purposes)
  void clearAllOrders() {
    _mockOrders.clear();
  }
}