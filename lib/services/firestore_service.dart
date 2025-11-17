import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart' as app_order;
import '../models/order_item.dart';
import '../models/address.dart';
import '../models/user.dart' as app_models;

/// Base Firestore service that provides common database operations
/// for the e-commerce app including products, orders, cart, and user data
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');
  
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');
  
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');
  
  CollectionReference<Map<String, dynamic>> get _cartsCollection =>
      _firestore.collection('carts');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// USER OPERATIONS ///

  /// Create or update user profile in Firestore
  Future<void> createUserProfile(app_models.UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'dateOfBirth': user.dateOfBirth?.millisecondsSinceEpoch,
        'gender': user.gender,
        'wishlistProductIds': user.wishlistProductIds,
        'addresses': user.addresses.map((address) => address.toMap()).toList(),
        'preferences': user.preferences?.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<app_models.UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return app_models.UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(app_models.UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update({
        'name': user.name,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'dateOfBirth': user.dateOfBirth?.millisecondsSinceEpoch,
        'gender': user.gender,
        'wishlistProductIds': user.wishlistProductIds,
        'addresses': user.addresses.map((address) => address.toMap()).toList(),
        'preferences': user.preferences?.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// PRODUCT OPERATIONS ///

  /// Add a new product to Firestore
  Future<void> addProduct(Product product) async {
    try {
      await _productsCollection.doc(product.id).set({
        'id': product.id,
        'title': product.title,
        'name': product.name,
        'image': product.image,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'rating': product.rating != null ? {
          'rate': product.rating!.rate,
          'count': product.rating!.count,
        } : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Get all products from Firestore
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _productsCollection
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final ratingData = data['rating'] as Map<String, dynamic>?;
        
        return Product(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          rating: ratingData != null ? Rating(
            rate: (ratingData['rate'] ?? 0).toDouble(),
            count: ratingData['count'] ?? 0,
          ) : null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      Query<Map<String, dynamic>> query = _productsCollection;
      
      if (category.toLowerCase() != 'all') {
        query = query.where('category', isEqualTo: category);
      }
      
      final querySnapshot = await query
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final ratingData = data['rating'] as Map<String, dynamic>?;
        
        return Product(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          rating: ratingData != null ? Rating(
            rate: (ratingData['rate'] ?? 0).toDouble(),
            count: ratingData['count'] ?? 0,
          ) : null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final ratingData = data['rating'] as Map<String, dynamic>?;
        
        return Product(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          rating: ratingData != null ? Rating(
            rate: (ratingData['rate'] ?? 0).toDouble(),
            count: ratingData['count'] ?? 0,
          ) : null,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product by ID: $e');
    }
  }

  /// Get available categories
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _productsCollection.get();
      final categories = querySnapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null)
          .cast<String>()
          .toSet()
          .toList();
      
      categories.sort();
      return ['All', ...categories];
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Since Firestore doesn't have full-text search, we'll get all products 
      // and filter them locally. For production, consider using Algolia or similar
      final products = await getProducts();
      
      return products.where((product) {
        final searchQuery = query.toLowerCase();
        return product.name.toLowerCase().contains(searchQuery) ||
               product.title.toLowerCase().contains(searchQuery) ||
               product.description.toLowerCase().contains(searchQuery) ||
               product.category.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// CART OPERATIONS ///

  /// Get user's cart from Firestore
  Future<Map<String, CartItem>> getUserCart(String userId) async {
    print('FirestoreService: getUserCart called for userId: $userId');
    try {
      print('FirestoreService: Fetching cart document from Firestore...');
      final doc = await _cartsCollection.doc(userId).get();
      
      print('FirestoreService: Document exists: ${doc.exists}');
      if (!doc.exists || doc.data() == null) {
        print('FirestoreService: No cart document found, returning empty cart');
        return {};
      }

      final data = doc.data()!;
      print('FirestoreService: Cart document data keys: ${data.keys}');
      
      // Handle both legacy List format and new Map format
      final Map<String, CartItem> cartItems = {};
      
      if (data['items'] is Map) {
        // New Map format - preferred for multiple products
        print('FirestoreService: Processing Map format cart data');
        final items = data['items'] as Map<String, dynamic>? ?? {};
        print('FirestoreService: Found ${items.length} items in Map format');
        
        for (final entry in items.entries) {
          try {
            print('FirestoreService: Processing item: ${entry.key}');
            final itemData = entry.value as Map<String, dynamic>;
            final product = Product.fromMap(itemData['product'] as Map<String, dynamic>);
            final quantity = itemData['quantity'] as int;
            
            cartItems[entry.key] = CartItem(
              product: product,
              quantity: quantity,
            );
            print('FirestoreService: Successfully parsed: ${product.name} (qty: $quantity)');
          } catch (e) {
            print('FirestoreService: Error parsing cart item ${entry.key}: $e');
          }
        }
      } else if (data['items'] is List) {
        // Legacy List format - convert for backward compatibility
        print('FirestoreService: Processing legacy List format cart data');
        final items = data['items'] as List<dynamic>? ?? [];
        print('FirestoreService: Found ${items.length} items in List format');
        
        for (final itemData in items) {
          try {
            final productId = itemData['productId'] as String;
            final quantity = itemData['quantity'] as int;
            
            print('FirestoreService: Processing legacy item: $productId');
            final product = await getProductById(productId);
            if (product != null) {
              cartItems[productId] = CartItem(
                product: product,
                quantity: quantity,
              );
              print('FirestoreService: Successfully converted: ${product.name} (qty: $quantity)');
            }
          } catch (e) {
            print('FirestoreService: Error processing legacy item: $e');
          }
        }
      }

      print('FirestoreService: Returning cart with ${cartItems.length} items');
      cartItems.forEach((key, value) {
        print('FirestoreService: Final cart: ${value.product.name} (${key}) - qty: ${value.quantity}');
      });
      return cartItems;
    } catch (e) {
      print('FirestoreService: Error getting user cart: $e');
      return {};
    }
  }

  /// Update user's cart in Firestore
  Future<void> updateUserCart(String userId, Map<String, CartItem> cartItems) async {
    print('FirestoreService: updateUserCart called for userId: $userId');
    print('FirestoreService: Updating cart with ${cartItems.length} items');
    
    try {
      // Use Map-based structure to support multiple products
      final cartData = <String, Map<String, dynamic>>{};
      for (final entry in cartItems.entries) {
        print('FirestoreService: Preparing item: ${entry.value.product.name} (qty: ${entry.value.quantity})');
        cartData[entry.key] = {
          'product': entry.value.product.toMap(),
          'quantity': entry.value.quantity,
        };
      }
      
      print('FirestoreService: Saving cart document to Firestore with Map structure...');
      print('FirestoreService: Cart data keys: ${cartData.keys}');
      await _cartsCollection.doc(userId).set({
        'userId': userId,
        'items': cartData, // Save as Map, not List - THIS IS THE KEY FIX!
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('FirestoreService: Cart successfully saved to Firestore');
    } catch (e) {
      print('FirestoreService: Error updating cart: $e');
      throw Exception('Failed to update cart: $e');
    }
  }

  /// Clear user's cart
  Future<void> clearUserCart(String userId) async {
    try {
      await _cartsCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to clear user cart: $e');
    }
  }

  /// ORDER OPERATIONS ///

  /// Create a new order
  Future<app_order.Order> createOrder({
    required Map<String, CartItem> cartItems,
    required String userId,
    required Address shippingAddress,
    required app_order.PaymentDetails paymentDetails,
  }) async {
    print('FirestoreService: createOrder() started for user: $userId');
    print('FirestoreService: Cart items count: ${cartItems.length}');
    
    try {
      print('FirestoreService: Generating order ID...');
      final orderId = _ordersCollection.doc().id;
      print('FirestoreService: Order ID generated: $orderId');
      
      print('FirestoreService: Creating order items...');
      final orderItems = cartItems.values.map((cartItem) => {
        'productId': cartItem.product.id,
        'productName': cartItem.product.name,
        'productPrice': cartItem.product.price,
        'productImage': cartItem.product.imageUrl,
        'quantity': cartItem.quantity,
        'unitPrice': cartItem.product.price,
        'totalPrice': cartItem.totalPrice,
      }).toList();

      print('FirestoreService: Calculating total...');
      final total = cartItems.values
          .fold(0.0, (sum, item) => sum + item.totalPrice);
      print('FirestoreService: Total calculated: $total');

      final trackingNumber = 'TRK${DateTime.now().millisecondsSinceEpoch}';
      print('FirestoreService: Tracking number: $trackingNumber');
      
      print('FirestoreService: Creating order data structure...');
      final currentTime = DateTime.now();
      final orderData = {
        'id': orderId,
        'userId': userId,
        'items': orderItems,
        'total': total,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'shippingAddress': {
          'id': shippingAddress.id,
          'fullName': shippingAddress.fullName,
          'phoneNumber': shippingAddress.phoneNumber,
          'addressLine1': shippingAddress.addressLine1,
          'addressLine2': shippingAddress.addressLine2,
          'city': shippingAddress.city,
          'state': shippingAddress.state,
          'zipCode': shippingAddress.zipCode,
          'country': shippingAddress.country,
          'label': shippingAddress.label,
          'isDefault': shippingAddress.isDefault,
        },
        'paymentDetails': {
          'method': _paymentMethodToString(paymentDetails.method),
          'cardLastFour': paymentDetails.cardLastFour,
          'cardBrand': paymentDetails.cardBrand,
          'amount': paymentDetails.amount,
          'transactionDate': paymentDetails.transactionDate?.millisecondsSinceEpoch,
          'stripePaymentIntentId': paymentDetails.stripePaymentIntentId,
          'stripePaymentStatus': paymentDetails.stripePaymentStatus,
        },
        'trackingHistory': [
          {
            'status': 'pending',
            'timestamp': currentTime.millisecondsSinceEpoch,
            'description': 'Order placed successfully',
          }
        ],
        'trackingNumber': trackingNumber,
        'estimatedDelivery': DateTime.now().add(const Duration(days: 5)).millisecondsSinceEpoch,
      };

      print('FirestoreService: Saving order to Firestore...');
      await _ordersCollection.doc(orderId).set(orderData);
      print('FirestoreService: Order saved successfully');

      print('FirestoreService: Clearing user cart...');
      // Try to clear cart, but don't fail the order if it fails
      try {
        await clearUserCart(userId);
        print('FirestoreService: Cart cleared successfully');
      } catch (cartError) {
        print('FirestoreService: Warning - Failed to clear cart: $cartError');
        // Continue anyway, order is still valid
      }

      print('FirestoreService: Creating order object...');
      // Return the created order
      return app_order.Order(
        id: orderId,
        items: cartItems.values.map((cartItem) =>
          OrderItem.fromCartItem(cartItem.product, cartItem.quantity)
        ).toList(),
        total: total,
        orderDate: DateTime.now(),
        status: app_order.OrderStatus.pending,
        userId: userId,
        shippingAddress: shippingAddress,
        paymentDetails: paymentDetails,
        trackingHistory: [
          app_order.OrderTracking(
            status: app_order.OrderStatus.pending,
            timestamp: DateTime.now(),
            description: 'Order placed successfully',
          ),
        ],
        trackingNumber: trackingNumber,
        estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      );
    } catch (e) {
      print('FirestoreService: Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get orders for a user
  Future<List<app_order.Order>> getOrdersForUser(String userId) async {
    try {
      print('FirestoreService: Getting orders for user: $userId');
      
      // Query without orderBy to avoid composite index requirement
      final querySnapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      print('FirestoreService: Found ${querySnapshot.docs.length} order documents');

      final orders = <app_order.Order>[];
      for (final doc in querySnapshot.docs) {
        final order = await _buildOrderFromDoc(doc);
        if (order != null) {
          orders.add(order);
        }
      }
      
      // Sort orders by date in memory (newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      print('FirestoreService: Successfully built ${orders.length} orders');
      return orders;
    } catch (e) {
      print('FirestoreService: Error getting orders for user: $e');
      throw Exception('Failed to get orders for user: $e');
    }
  }

  /// Get order by ID
  Future<app_order.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        // Convert DocumentSnapshot to QueryDocumentSnapshot for compatibility
        final data = doc.data();
        if (data != null) {
          return await _buildOrderFromDocData(doc.id, data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order by ID: $e');
    }
  }

  /// Update order status
  Future<app_order.Order> updateOrderStatus(String orderId, app_order.OrderStatus newStatus) async {
    try {
      final statusString = _orderStatusToString(newStatus);
      final newTracking = {
        'status': statusString,
        'timestamp': FieldValue.serverTimestamp(),
        'description': _getStatusDescription(newStatus),
      };

      await _ordersCollection.doc(orderId).update({
        'status': statusString,
        'trackingHistory': FieldValue.arrayUnion([newTracking]),
      });

      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order not found after update');
      }
      
      return updatedOrder;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Helper method to build Order object from Firestore document
  Future<app_order.Order?> _buildOrderFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    return await _buildOrderFromDocData(doc.id, doc.data());
  }

  /// Helper method to build Order object from document data
  Future<app_order.Order?> _buildOrderFromDocData(String docId, Map<String, dynamic> data) async {
    try {
      
      // Build order items
      final itemsData = data['items'] as List<dynamic>? ?? [];
      final orderItems = <OrderItem>[];
      
      for (final itemData in itemsData) {
        final product = Product(
          id: itemData['productId'] ?? '',
          title: itemData['productName'] ?? '',
          name: itemData['productName'] ?? '',
          image: itemData['productImage'] ?? '',
          imageUrl: itemData['productImage'] ?? '',
          price: (itemData['productPrice'] ?? 0).toDouble(),
          description: '',
          category: '',
        );
        
        orderItems.add(OrderItem(
          product: product,
          quantity: itemData['quantity'] ?? 1,
          unitPrice: (itemData['unitPrice'] ?? 0).toDouble(),
        ));
      }
      
      // Build shipping address
      final addressData = data['shippingAddress'] as Map<String, dynamic>?;
      Address? shippingAddress;
      if (addressData != null) {
        shippingAddress = Address(
          id: addressData['id'] ?? '',
          fullName: addressData['fullName'] ?? '',
          phoneNumber: addressData['phoneNumber'] ?? '',
          addressLine1: addressData['addressLine1'] ?? '',
          addressLine2: addressData['addressLine2'] ?? '',
          city: addressData['city'] ?? '',
          state: addressData['state'] ?? '',
          zipCode: addressData['zipCode'] ?? '',
          country: addressData['country'] ?? '',
          label: addressData['label'] ?? '',
          isDefault: addressData['isDefault'] ?? false,
        );
      }
      
      // Build payment details
      final paymentData = data['paymentDetails'] as Map<String, dynamic>?;
      app_order.PaymentDetails? paymentDetails;
      if (paymentData != null) {
        paymentDetails = app_order.PaymentDetails(
          method: _stringToPaymentMethod(paymentData['method'] ?? 'creditCard'),
          cardLastFour: paymentData['cardLastFour'],
          cardBrand: paymentData['cardBrand'],
          amount: (paymentData['amount'] ?? 0).toDouble(),
          transactionDate: _parseTimestamp(paymentData['transactionDate']) ?? DateTime.now(),
          stripePaymentIntentId: paymentData['stripePaymentIntentId'],
          stripePaymentStatus: paymentData['stripePaymentStatus'],
        );
      }
      
      // Build tracking history
      final trackingData = data['trackingHistory'] as List<dynamic>? ?? [];
      final trackingHistory = trackingData.map((tracking) => app_order.OrderTracking(
        status: _stringToOrderStatus(tracking['status'] ?? 'pending'),
        timestamp: _parseTimestamp(tracking['timestamp']) ?? DateTime.now(),
        description: tracking['description'],
        location: tracking['location'],
      )).toList();
      
      return app_order.Order(
        id: data['id'] ?? docId,
        items: orderItems,
        total: (data['total'] ?? 0).toDouble(),
        orderDate: _parseTimestamp(data['orderDate']) ?? DateTime.now(),
        status: _stringToOrderStatus(data['status'] ?? 'pending'),
        userId: data['userId'] ?? '',
        shippingAddress: shippingAddress,
        paymentDetails: paymentDetails,
        trackingHistory: trackingHistory,
        trackingNumber: data['trackingNumber'],
        estimatedDelivery: _parseTimestamp(data['estimatedDelivery']),
      );
    } catch (e) {
      print('Error building order from doc: $e');
      return null;
    }
  }

  /// Helper method to parse timestamp from Firestore (handles both Timestamp and int formats)
  DateTime? _parseTimestamp(dynamic timestampValue) {
    if (timestampValue == null) {
      return null;
    }
    
    if (timestampValue is Timestamp) {
      // Handle Firebase Timestamp objects
      return timestampValue.toDate();
    } else if (timestampValue is int) {
      // Handle millisecond integers
      return DateTime.fromMillisecondsSinceEpoch(timestampValue);
    }
    
    // Fallback for unknown formats
    return null;
  }

  /// Helper methods for enum conversions
  String _paymentMethodToString(app_order.PaymentMethod method) {
    switch (method) {
      case app_order.PaymentMethod.creditCard:
        return 'creditCard';
      case app_order.PaymentMethod.paypal:
        return 'paypal';
      case app_order.PaymentMethod.applePay:
        return 'applePay';
    }
  }

  app_order.PaymentMethod _stringToPaymentMethod(String method) {
    switch (method) {
      case 'paypal':
        return app_order.PaymentMethod.paypal;
      case 'applePay':
        return app_order.PaymentMethod.applePay;
      default:
        return app_order.PaymentMethod.creditCard;
    }
  }

  String _orderStatusToString(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.pending:
        return 'pending';
      case app_order.OrderStatus.confirmed:
        return 'confirmed';
      case app_order.OrderStatus.shipped:
        return 'shipped';
      case app_order.OrderStatus.delivered:
        return 'delivered';
      case app_order.OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  app_order.OrderStatus _stringToOrderStatus(String status) {
    switch (status) {
      case 'confirmed':
        return app_order.OrderStatus.confirmed;
      case 'shipped':
        return app_order.OrderStatus.shipped;
      case 'delivered':
        return app_order.OrderStatus.delivered;
      case 'cancelled':
        return app_order.OrderStatus.cancelled;
      default:
        return app_order.OrderStatus.pending;
    }
  }

  String _getStatusDescription(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.pending:
        return 'Order placed successfully';
      case app_order.OrderStatus.confirmed:
        return 'Order confirmed and being prepared';
      case app_order.OrderStatus.shipped:
        return 'Package shipped from warehouse';
      case app_order.OrderStatus.delivered:
        return 'Package delivered successfully';
      case app_order.OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }

  /// Initialize sample data for testing (optional)
  Future<void> initializeSampleData() async {
    try {
      // Check if products already exist
      final existingProducts = await getProducts();
      if (existingProducts.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // Add sample products
      final sampleProducts = [
        Product(
          id: 'prod_001',
          title: 'Wireless Bluetooth Headphones',
          name: 'Wireless Bluetooth Headphones',
          image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
          imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
          description: 'High-quality wireless headphones with noise cancellation and long battery life. Perfect for music lovers and professionals.',
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
          description: 'Advanced fitness tracking with heart rate monitor, GPS, and waterproof design.',
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
          description: 'Organic single-origin coffee beans, medium roast. Sourced directly from sustainable farms.',
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
          description: 'Stainless steel insulated water bottle, 32oz. Keeps drinks cold for 24 hours or hot for 12 hours.',
          price: 29.99,
          category: 'Sports & Outdoors',
          rating: const Rating(rate: 4.6, count: 167),
        ),
        Product(
          id: 'prod_005',
          title: 'Wireless Phone Charger',
          name: 'Wireless Phone Charger',
          image: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
          imageUrl: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
          description: 'Fast wireless charging pad compatible with all Qi-enabled devices. Sleek design with LED indicator.',
          price: 34.99,
          category: 'Electronics',
          rating: const Rating(rate: 4.3, count: 94),
        ),
      ];

      for (final product in sampleProducts) {
        await addProduct(product);
      }

      print('Sample data initialized successfully');
    } catch (e) {
      print('Failed to initialize sample data: $e');
    }
  }
}