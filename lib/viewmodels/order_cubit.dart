import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../services/firestore_order_service.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final FirestoreOrderService _orderService = FirestoreOrderService();
  String? _currentUserId;

  OrderCubit() : super(OrderInitial());

  // Set current user ID
  void setUserId(String? userId) {
    print('OrderCubit: setUserId called with: $userId');
    _currentUserId = userId;
    print('OrderCubit: _currentUserId is now: $_currentUserId');
    if (userId != null) {
      print('OrderCubit: Loading user orders for user: $userId');
      loadUserOrders(userId);
    } else {
      print('OrderCubit: User ID is null, setting to initial state');
      emit(OrderInitial());
    }
  }

  // Create a new order from cart items
  Future<void> createOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
    required Address shippingAddress,
    required PaymentDetails paymentDetails,
  }) async {
    print('OrderCubit: createOrder called for user: $userId');
    print('OrderCubit: Cart items count: ${cartItems.length}');
    print('OrderCubit: _currentUserId is: $_currentUserId');
    
    // Validate inputs before starting
    if (cartItems.isEmpty) {
      print('OrderCubit: Error - Cart is empty');
      emit(OrderError('Cannot create order with empty cart'));
      return;
    }
    
    if (userId.isEmpty) {
      print('OrderCubit: Error - User ID is empty');
      emit(OrderError('User authentication required'));
      return;
    }
    
    emit(OrderLoading());
    print('OrderCubit: Order loading state emitted, starting order creation...');
    
    try {
      print('OrderCubit: Calling order service to create order...');
      
      // Add timeout to prevent infinite hanging
      final order = await _orderService.createOrder(
        cartItems: cartItems,
        userId: userId,
        shippingAddress: shippingAddress,
        paymentDetails: paymentDetails,
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          print('OrderCubit: Order creation timed out after 45 seconds');
          throw Exception('Order creation timed out. Please check your connection and try again.');
        },
      );
      
      print('OrderCubit: Order created successfully: ${order.id}');
      print('OrderCubit: Emitting OrderCreated state...');
      emit(OrderCreated(order));
    } catch (e) {
      print('OrderCubit: Error creating order: $e');
      print('OrderCubit: Error type: ${e.runtimeType}');
      
      String errorMessage;
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        errorMessage = 'Order creation timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('permission') || e.toString().contains('auth')) {
        errorMessage = 'Authentication error. Please log in again and try.';
      } else {
        errorMessage = 'Failed to create order. Please try again or contact support if the problem persists.';
      }
      
      print('OrderCubit: Emitting OrderError state with message: $errorMessage');
      emit(OrderError(errorMessage));
    }
  }

  // Load orders for a specific user
  Future<void> loadUserOrders(String userId) async {
    emit(OrderLoading());
    try {
      final orders = await _orderService.getOrdersForUser(userId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError('Failed to load orders: ${e.toString()}'));
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);
      
      // Update the current state if we have orders loaded
      final currentState = state;
      if (currentState is OrdersLoaded) {
        final updatedOrders = currentState.orders.map((order) {
          return order.id == orderId ? updatedOrder : order;
        }).toList();
        emit(OrdersLoaded(updatedOrders));
      }
    } catch (e) {
      emit(OrderError('Failed to update order: ${e.toString()}'));
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      return await _orderService.getOrderById(orderId);
    } catch (e) {
      emit(OrderError('Failed to get order: ${e.toString()}'));
      return null;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final updatedOrder = await _orderService.cancelOrder(orderId);
      
      // Update the current state if we have orders loaded
      final currentState = state;
      if (currentState is OrdersLoaded) {
        final updatedOrders = currentState.orders.map((order) {
          return order.id == orderId ? updatedOrder : order;
        }).toList();
        emit(OrdersLoaded(updatedOrders));
      }
    } catch (e) {
      emit(OrderError('Failed to cancel order: ${e.toString()}'));
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      return await _orderService.getOrderStatistics(userId);
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

  // Clear error state
  void clearError() {
    if (state is OrderError) {
      emit(OrderInitial());
    }
  }

  // Reset to initial state
  void reset() {
    emit(OrderInitial());
  }
}
