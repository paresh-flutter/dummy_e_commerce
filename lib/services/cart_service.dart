import '../models/cart_item.dart';
import '../models/api/cart_dto.dart';
import 'api_client.dart';
import 'product_service.dart';

class CartService {
  final ApiClient _apiClient = ApiClient.instance;
  final ProductService _productService = ProductService();

  // Get user's cart from API
  Future<Map<String, CartItem>> getUserCart(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/carts/user/$userId');
      
      if (response.data != null) {
        final cartDto = CartDto.fromJson(response.data!);
        return await _convertCartDtoToCartItems(cartDto);
      }
      
      return {};
    } catch (e) {
      // Return empty cart if API fails
      return {};
    }
  }

  // Add item to cart
  Future<Map<String, CartItem>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final request = AddToCartRequestDto(
        productId: productId,
        quantity: quantity,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/carts/$userId/items',
        data: request.toJson(),
      );

      if (response.data != null) {
        final cartDto = CartDto.fromJson(response.data!);
        return await _convertCartDtoToCartItems(cartDto);
      }
      
      return {};
    } catch (e) {
      // Fallback to local cart management
      return _handleLocalCartOperation(userId, productId, quantity, 'add');
    }
  }

  // Update cart item quantity
  Future<Map<String, CartItem>> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final request = UpdateCartItemRequestDto(
        productId: productId,
        quantity: quantity,
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/carts/$userId/items/$productId',
        data: request.toJson(),
      );

      if (response.data != null) {
        final cartDto = CartDto.fromJson(response.data!);
        return await _convertCartDtoToCartItems(cartDto);
      }
      
      return {};
    } catch (e) {
      // Fallback to local cart management
      return _handleLocalCartOperation(userId, productId, quantity, 'update');
    }
  }

  // Remove item from cart
  Future<Map<String, CartItem>> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/carts/$userId/items/$productId',
      );

      if (response.data != null) {
        final cartDto = CartDto.fromJson(response.data!);
        return await _convertCartDtoToCartItems(cartDto);
      }
      
      return {};
    } catch (e) {
      // Fallback to local cart management
      return _handleLocalCartOperation(userId, productId, 0, 'remove');
    }
  }

  // Clear entire cart
  Future<void> clearCart(String userId) async {
    try {
      await _apiClient.delete('/carts/$userId');
    } catch (e) {
      // Clear local cart if API fails
      _localCarts.remove(userId);
    }
  }

  // Sync local cart with server
  Future<Map<String, CartItem>> syncCart({
    required String userId,
    required Map<String, CartItem> localCart,
  }) async {
    try {
      final cartItems = localCart.values.map((item) => CartItemDto(
        productId: item.product.id,
        quantity: item.quantity,
        price: item.product.price,
      )).toList();

      final cartDto = CartDto(
        id: userId,
        userId: userId,
        items: cartItems,
        updatedAt: DateTime.now(),
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/carts/$userId',
        data: cartDto.toJson(),
      );

      if (response.data != null) {
        final updatedCartDto = CartDto.fromJson(response.data!);
        return await _convertCartDtoToCartItems(updatedCartDto);
      }
      
      return localCart;
    } catch (e) {
      // Return local cart if sync fails
      return localCart;
    }
  }

  // Convert CartDto to Map<String, CartItem>
  Future<Map<String, CartItem>> _convertCartDtoToCartItems(CartDto cartDto) async {
    final Map<String, CartItem> cartItems = {};
    
    for (final itemDto in cartDto.items) {
      final product = await _productService.getProductById(itemDto.productId);
      if (product != null) {
        cartItems[product.id] = itemDto.toDomain(product);
      }
    }
    
    return cartItems;
  }

  // Local cart storage for fallback
  static final Map<String, Map<String, CartItem>> _localCarts = {};

  // Handle local cart operations when API is unavailable
  Future<Map<String, CartItem>> _handleLocalCartOperation(
    String userId,
    String productId,
    int quantity,
    String operation,
  ) async {
    // Get or create local cart for user
    _localCarts[userId] ??= {};
    final userCart = _localCarts[userId]!;

    switch (operation) {
      case 'add':
      case 'update':
        final product = await _productService.getProductById(productId);
        if (product != null) {
          if (quantity > 0) {
            userCart[productId] = CartItem(product: product, quantity: quantity);
          } else {
            userCart.remove(productId);
          }
        }
        break;
      case 'remove':
        userCart.remove(productId);
        break;
    }

    return Map.from(userCart);
  }

  // Get local cart (fallback)
  Map<String, CartItem> getLocalCart(String userId) {
    return Map.from(_localCarts[userId] ?? {});
  }
}
