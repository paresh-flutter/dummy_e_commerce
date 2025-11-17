import '../models/product.dart';
import 'firestore_service.dart';

/// Product service that uses Firestore for data storage
class FirestoreProductService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Fetch all products from Firestore
  Future<List<Product>> fetchProducts() async {
    try {
      return await _firestoreService.getProducts();
    } catch (e) {
      // Fallback to mock data if Firestore fails
      return _getMockProducts();
    }
  }

  /// Get available categories from Firestore
  Future<List<String>> getCategories() async {
    try {
      return await _firestoreService.getCategories();
    } catch (e) {
      // Fallback to mock categories
      return ['All', 'Electronics', 'Food & Beverages', 'Sports & Outdoors'];
    }
  }

  /// Get products by category from Firestore
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await _firestoreService.getProductsByCategory(category);
    } catch (e) {
      // Fallback to filtering mock data
      final products = _getMockProducts();
      if (category.toLowerCase() == 'all') {
        return products;
      }
      return products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
  }

  /// Get product by ID from Firestore
  Future<Product?> getProductById(String id) async {
    try {
      return await _firestoreService.getProductById(id);
    } catch (e) {
      // Fallback to mock data
      try {
        return _getMockProducts().firstWhere((product) => product.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Search products in Firestore
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _firestoreService.searchProducts(query);
    } catch (e) {
      // Fallback to local search
      final products = _getMockProducts();
      return products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase()) ||
               product.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  /// Add a new product to Firestore (admin function)
  Future<void> addProduct(Product product) async {
    try {
      await _firestoreService.addProduct(product);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Initialize sample data in Firestore
  Future<void> initializeSampleData() async {
    try {
      await _firestoreService.initializeSampleData();
    } catch (e) {
      throw Exception('Failed to initialize sample data: $e');
    }
  }

  /// Mock data fallback (same as original)
  List<Product> _getMockProducts() {
    return const [
      Product(
        id: 'prod_001',
        title: 'Wireless Bluetooth Headphones',
        name: 'Wireless Bluetooth Headphones',
        image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        price: 79.99,
        description: 'High-quality wireless headphones with noise cancellation and long battery life.',
        category: 'Electronics',
        rating: Rating(rate: 4.5, count: 128),
      ),
      Product(
        id: 'prod_002',
        title: 'Smart Fitness Watch',
        name: 'Smart Fitness Watch',
        image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        price: 199.99,
        description: 'Advanced fitness tracking with heart rate monitor, GPS, and waterproof design.',
        category: 'Electronics',
        rating: Rating(rate: 4.7, count: 89),
      ),
      Product(
        id: 'prod_003',
        title: 'Premium Coffee Beans',
        name: 'Premium Coffee Beans',
        image: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        price: 24.99,
        description: 'Organic single-origin coffee beans, medium roast. Sourced directly from sustainable farms.',
        category: 'Food & Beverages',
        rating: Rating(rate: 4.8, count: 256),
      ),
      Product(
        id: 'prod_004',
        title: 'Eco-Friendly Water Bottle',
        name: 'Eco-Friendly Water Bottle',
        image: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
        price: 29.99,
        description: 'Stainless steel insulated water bottle, 32oz. Keeps drinks cold for 24 hours.',
        category: 'Sports & Outdoors',
        rating: Rating(rate: 4.6, count: 167),
      ),
      Product(
        id: 'prod_005',
        title: 'Wireless Phone Charger',
        name: 'Wireless Phone Charger',
        image: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
        imageUrl: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
        price: 34.99,
        description: 'Fast wireless charging pad compatible with all Qi-enabled devices.',
        category: 'Electronics',
        rating: Rating(rate: 4.3, count: 94),
      ),
    ];
  }
}