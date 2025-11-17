import '../models/product.dart';
import '../models/api/product_dto.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient.instance;

  // Fetch products from API
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/products');
      
      if (response.data != null) {
        return response.data!
            .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
            .map((dto) => dto.toDomain())
            .toList();
      }
      
      return [];
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockProducts();
    }
  }

  // Get categories from API
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/products/categories');
      
      if (response.data != null) {
        final categories = response.data!.cast<String>();
        categories.sort();
        return ['All', ...categories];
      }
      
      return ['All'];
    } catch (e) {
      // Fallback to mock categories
      return ['All', 'Electronics', 'Accessories', 'electronics', 'jewelery', 'men\'s clothing', 'women\'s clothing'];
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final endpoint = category.toLowerCase() == 'all' 
          ? '/products' 
          : '/products/category/$category';
      
      final response = await _apiClient.get<List<dynamic>>(endpoint);
      
      if (response.data != null) {
        return response.data!
            .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
            .map((dto) => dto.toDomain())
            .toList();
      }
      
      return [];
    } catch (e) {
      // Fallback to filtering mock data
      final products = _getMockProducts();
      if (category.toLowerCase() == 'all') {
        return products;
      }
      return products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/products/$id');
      
      if (response.data != null) {
        final dto = ProductDto.fromJson(response.data!);
        return dto.toDomain();
      }
      
      return null;
    } catch (e) {
      // Fallback to mock data
      try {
        return _getMockProducts().firstWhere((product) => product.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Since Fake Store API doesn't have search, we'll fetch all and filter
      final products = await fetchProducts();
      return products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase()) ||
               product.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Mock data fallback
  List<Product> _getMockProducts() {
    return const [
      Product(
        id: '1',
        title: 'Wireless Headphones',
        name: 'Wireless Headphones',
        image: 'https://picsum.photos/seed/headphones/400/400',
        imageUrl: 'https://picsum.photos/seed/headphones/400/400',
        price: 59.99,
        description: 'Comfortable wireless headphones with noise isolation.',
        category: 'Electronics',
        rating: Rating(rate: 4.5, count: 120),
      ),
      Product(
        id: '2',
        title: 'Smart Watch',
        name: 'Smart Watch',
        image: 'https://picsum.photos/seed/watch/400/400',
        imageUrl: 'https://picsum.photos/seed/watch/400/400',
        price: 129.99,
        description: 'Track fitness, notifications, and more with style.',
        category: 'Electronics',
        rating: Rating(rate: 4.8, count: 89),
      ),
      Product(
        id: '3',
        title: 'Bluetooth Speaker',
        name: 'Bluetooth Speaker',
        image: 'https://picsum.photos/seed/speaker/400/400',
        imageUrl: 'https://picsum.photos/seed/speaker/400/400',
        price: 39.99,
        description: 'Portable speaker with deep bass and long battery life.',
        category: 'Electronics',
        rating: Rating(rate: 4.2, count: 156),
      ),
      Product(
        id: '4',
        title: 'Gaming Mouse',
        name: 'Gaming Mouse',
        image: 'https://picsum.photos/seed/mouse/400/400',
        imageUrl: 'https://picsum.photos/seed/mouse/400/400',
        price: 24.99,
        description: 'Ergonomic mouse with customizable DPI settings.',
        category: 'Electronics',
        rating: Rating(rate: 4.0, count: 78),
      ),
      Product(
        id: '5',
        title: 'USB-C Charger',
        name: 'USB-C Charger',
        image: 'https://picsum.photos/seed/charger/400/400',
        imageUrl: 'https://picsum.photos/seed/charger/400/400',
        price: 19.99,
        description: 'Fast charging adapter compatible with most devices.',
        category: 'Accessories',
        rating: Rating(rate: 3.9, count: 45),
      ),
    ];
  }
}
