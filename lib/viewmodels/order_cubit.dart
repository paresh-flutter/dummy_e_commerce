import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_repository.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(OrderInitial());

  // Create a new order from cart items
  Future<void> createOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
  }) async {
    emit(OrderLoading());
    try {
      final order = await _repository.createOrder(
        cartItems: cartItems,
        userId: userId,
      );
      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError('Failed to create order: ${e.toString()}'));
    }
  }

  // Load orders for a specific user
  Future<void> loadUserOrders(String userId) async {
    emit(OrderLoading());
    try {
      final orders = await _repository.getOrdersForUser(userId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError('Failed to load orders: ${e.toString()}'));
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updatedOrder = await _repository.updateOrderStatus(orderId, newStatus);
      
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
      return await _repository.getOrderById(orderId);
    } catch (e) {
      emit(OrderError('Failed to get order: ${e.toString()}'));
      return null;
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
