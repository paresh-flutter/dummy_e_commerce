import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../viewmodels/product_cubit.dart';
import '../../widgets/amazon_style_product_card.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/enhanced_loading_states.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;

  const HomeScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1.sp,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
        title: Text(
          'Modern Store',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface, size: 24.sp),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
          const CartIconButton(),
          SizedBox(width: 8.w),
        ],
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Search Bar
            Container(
              color: theme.colorScheme.surface,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for products, brands and more',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20.sp,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 18.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ProductCubit>().searchProducts('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (value) {
                  context.read<ProductCubit>().searchProducts(value);
                  setState(() {}); // Update to show/hide clear button
                },
              ),
            ),

            // Modern Category Filters
            Container(
              color: theme.colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  final currentCategory = state is ProductLoaded ? state.currentCategory : 'All';

                  return FutureBuilder<List<String>>(
                    future: context.read<ProductCubit>().getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                          height: 40.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: EnhancedLoadingStates.skeleton(
                                  width: 80,
                                  height: 32,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      final categories = snapshot.data!;
                      return SizedBox(
                        height: 40.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == currentCategory;

                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: AnimatedButton(
                                text: category,
                                onPressed: () {
                                  context.read<ProductCubit>().filterByCategory(category);
                                },
                                style: isSelected
                                    ? AnimatedButtonStyle.filled
                                    : AnimatedButtonStyle.outlined,
                                backgroundColor: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                foregroundColor: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                minimumSize: Size(0, 32.h),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Product Grid Section
            Expanded(
              child: AnimatedPageWrapper(
                child: Container(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
                    child: BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          // Calculate responsive grid layout for loading state
                          final screenWidth = 1.sw;
                          final isTablet = screenWidth > 600;
                          final crossAxisCount = isTablet ? 3 : 2;
                          // CHANGED: Reduced aspect ratio to give more height
                          final childAspectRatio = isTablet ? 0.65 : 0.58;

                          return GridView.builder(
                            padding: EdgeInsets.all(8.w),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return const ShimmerProductCard();
                            },
                          );
                        }

                        if (state is ProductLoaded) {
                          final products = state.products;

                          if (products.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64.sp,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No products found',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Try adjusting your search or category filter',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          // Calculate responsive grid layout for products
                          final screenWidth = 1.sw;
                          final isTablet = screenWidth > 600;
                          final crossAxisCount = isTablet ? 3 : 2;
                          // CHANGED: Reduced aspect ratio to give more height
                          final childAspectRatio = isTablet ? 0.65 : 0.58;

                          return GridView.builder(
                            padding: EdgeInsets.all(8.w),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return AmazonStyleProductCard(product: product);
                            },
                          );
                        }
                        if (state is ProductError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64.sp,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Failed to load products',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  state.message,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 14.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                AnimatedButton(
                                  text: 'Retry',
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    context.read<ProductCubit>().loadProducts();
                                  },
                                  style: AnimatedButtonStyle.filled,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}