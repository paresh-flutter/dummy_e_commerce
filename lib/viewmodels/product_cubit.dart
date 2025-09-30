import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../services/product_service.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService service;
  List<Product> _allProducts = [];
  String _currentCategory = 'All';
  String _searchQuery = '';

  ProductCubit(this.service) : super(ProductLoading());

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      _allProducts = await service.fetchProducts();
      _applyFilters();
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(String category) {
    _currentCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> filteredProducts = _allProducts;

    // Apply category filter
    if (_currentCategory != 'All') {
      filteredProducts = filteredProducts
          .where((product) => product.category.toLowerCase() == _currentCategory.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => 
              product.name.toLowerCase().contains(_searchQuery) ||
              product.description.toLowerCase().contains(_searchQuery) ||
              product.category.toLowerCase().contains(_searchQuery))
          .toList();
    }

    emit(ProductLoaded(
      products: filteredProducts,
      allProducts: _allProducts,
      currentCategory: _currentCategory,
      searchQuery: _searchQuery,
    ));
  }

  Product? findById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getCategories() {
    return service.getCategories();
  }

  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;
}
