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

// class HomeScreen extends StatefulWidget {
//   final bool showAppBar;
//
//   const HomeScreen({
//     super.key,
//     this.showAppBar = true,
//   });
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final PageController _bannerController = PageController();
//   int _currentBannerIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ProductCubit>().loadProducts();
//     });
//
//     // Auto-scroll banners
//     Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
//   }
//
//   void _autoScrollBanner() {
//     if (!mounted) return;
//     if (_bannerController.hasClients) {
//       final nextPage = (_currentBannerIndex + 1) % 4;
//       _bannerController.animateToPage(
//         nextPage,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//       Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
//     }
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _bannerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: widget.showAppBar ? AppBar(
//         backgroundColor: Colors.blue.shade700,
//         elevation: 0,
//         title: Container(
//           height: 40.h,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(4.r),
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search for products, brands and more',
//               hintStyle: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 14.sp,
//               ),
//               prefixIcon: Icon(
//                 Icons.search,
//                 color: Colors.grey.shade600,
//                 size: 20.sp,
//               ),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                 icon: Icon(Icons.clear, size: 18.sp),
//                 onPressed: () {
//                   _searchController.clear();
//                   context.read<ProductCubit>().searchProducts('');
//                   setState(() {});
//                 },
//               )
//                   : null,
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.symmetric(vertical: 10.h),
//             ),
//             onChanged: (value) {
//               context.read<ProductCubit>().searchProducts(value);
//               setState(() {});
//             },
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.mic, color: Colors.white, size: 22.sp),
//             onPressed: () {},
//           ),
//           const CartIconButton(),
//           SizedBox(width: 8.w),
//         ],
//       ) : null,
//       body: CustomScrollView(
//         slivers: [
//           // Hero Banner Section
//           SliverToBoxAdapter(
//             child: Container(
//               height: 180.h,
//               margin: EdgeInsets.only(bottom: 8.h),
//               child: PageView.builder(
//                 controller: _bannerController,
//                 onPageChanged: (index) {
//                   setState(() => _currentBannerIndex = index);
//                 },
//                 itemCount: 4,
//                 itemBuilder: (context, index) {
//                   return _buildBanner(index);
//                 },
//               ),
//             ),
//           ),
//
//           // Banner Indicators
//           SliverToBoxAdapter(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(4, (index) {
//                 return Container(
//                   margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 12.h),
//                   width: _currentBannerIndex == index ? 24.w : 8.w,
//                   height: 8.h,
//                   decoration: BoxDecoration(
//                     color: _currentBannerIndex == index
//                         ? Colors.blue.shade700
//                         : Colors.grey.shade400,
//                     borderRadius: BorderRadius.circular(4.r),
//                   ),
//                 );
//               }),
//             ),
//           ),
//
//           // Category Grid Section
//           SliverToBoxAdapter(
//             child: Container(
//               color: Colors.white,
//               padding: EdgeInsets.symmetric(vertical: 16.h),
//               margin: EdgeInsets.only(bottom: 8.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w),
//                     child: Text(
//                       'Shop by Category',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18.sp,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   _buildCategoryGrid(),
//                 ],
//               ),
//             ),
//           ),
//
//           // Deals Section
//           SliverToBoxAdapter(
//             child: Container(
//               color: Colors.white,
//               padding: EdgeInsets.all(16.w),
//               margin: EdgeInsets.only(bottom: 8.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Deals of the Day',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 18.sp,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           'VIEW ALL',
//                           style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12.h),
//                   SizedBox(
//                     height: 220.h,
//                     child: BlocBuilder<ProductCubit, ProductState>(
//                       builder: (context, state) {
//                         if (state is ProductLoaded) {
//                           final products = state.products.take(5).toList();
//                           return ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: products.length,
//                             itemBuilder: (context, index) {
//                               return _buildDealCard(products[index]);
//                             },
//                           );
//                         }
//                         return ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: 5,
//                           itemBuilder: (context, index) {
//                             return const ShimmerProductCard();
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Products Grid Section
//           SliverToBoxAdapter(
//             child: Container(
//               color: Colors.white,
//               padding: EdgeInsets.all(16.w),
//               child: Text(
//                 'Recommended for You',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18.sp,
//                 ),
//               ),
//             ),
//           ),
//
//           // Product Grid
//           BlocBuilder<ProductCubit, ProductState>(
//             builder: (context, state) {
//               if (state is ProductLoading) {
//                 return SliverPadding(
//                   padding: EdgeInsets.all(8.w),
//                   sliver: SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 8.h,
//                       crossAxisSpacing: 8.w,
//                       childAspectRatio: 0.58,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) => const ShimmerProductCard(),
//                       childCount: 6,
//                     ),
//                   ),
//                 );
//               }
//
//               if (state is ProductLoaded) {
//                 final products = state.products;
//
//                 if (products.isEmpty) {
//                   return SliverFillRemaining(
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
//                           SizedBox(height: 16.h),
//                           Text(
//                             'No products found',
//                             style: theme.textTheme.titleMedium,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//
//                 return SliverPadding(
//                   padding: EdgeInsets.all(8.w),
//                   sliver: SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 8.h,
//                       crossAxisSpacing: 8.w,
//                       childAspectRatio: 0.58,
//                     ),
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                         return AmazonStyleProductCard(product: products[index]);
//                       },
//                       childCount: products.length,
//                     ),
//                   ),
//                 );
//               }
//
//               return SliverFillRemaining(
//                 child: Center(child: Text('Something went wrong')),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBanner(int index) {
//     final banners = [
//       {'color': Colors.purple.shade700, 'text': 'MEGA SALE\n50% OFF'},
//       {'color': Colors.orange.shade700, 'text': 'NEW ARRIVALS\nShop Now'},
//       {'color': Colors.blue.shade700, 'text': 'FLASH DEALS\nLimited Time'},
//       {'color': Colors.green.shade700, 'text': 'FREE SHIPPING\nOn Orders'},
//     ];
//
//     final banner = banners[index];
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             banner['color'] as Color,
//             (banner['color'] as Color).withValues(alpha: 0.7),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Center(
//         child: Text(
//           banner['text'] as String,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 28.sp,
//             fontWeight: FontWeight.w900,
//             height: 1.2,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryGrid() {
//     final categories = [
//       {'icon': Icons.phone_android, 'name': 'Electronics'},
//       {'icon': Icons.checkroom, 'name': 'Fashion'},
//       {'icon': Icons.home, 'name': 'Home'},
//       {'icon': Icons.sports_basketball, 'name': 'Sports'},
//       {'icon': Icons.book, 'name': 'Books'},
//       {'icon': Icons.toys, 'name': 'Toys'},
//       {'icon': Icons.spa, 'name': 'Beauty'},
//       {'icon': Icons.more_horiz, 'name': 'More'},
//     ];
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         mainAxisSpacing: 16.h,
//         crossAxisSpacing: 16.w,
//         childAspectRatio: 0.85,
//       ),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         final category = categories[index];
//         return GestureDetector(
//           onTap: () {
//             context.read<ProductCubit>().filterByCategory(category['name'] as String);
//           },
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(16.w),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   category['icon'] as IconData,
//                   size: 28.sp,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 category['name'] as String,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDealCard(Product product) {
//     return Container(
//       width: 140.w,
//       margin: EdgeInsets.only(right: 12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: GestureDetector(
//         onTap: () => context.push('/product/${product.id}'),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Deal Image
//             ClipRRect(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
//               child: Image.network(
//                 product.imageUrl,
//                 height: 130.h,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     height: 130.h,
//                     color: Colors.grey.shade200,
//                     child: Icon(Icons.image, size: 40.sp, color: Colors.grey),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4.h),
//                   Row(
//                     children: [
//                       Text(
//                         '\$${product.price.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                       SizedBox(width: 6.w),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade600,
//                           borderRadius: BorderRadius.circular(2.r),
//                         ),
//                         child: Text(
//                           '20% OFF',
//                           style: TextStyle(
//                             fontSize: 9.sp,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }