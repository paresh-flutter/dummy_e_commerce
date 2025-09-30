part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> allProducts;
  final String currentCategory;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    required this.allProducts,
    required this.currentCategory,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [products, allProducts, currentCategory, searchQuery];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
