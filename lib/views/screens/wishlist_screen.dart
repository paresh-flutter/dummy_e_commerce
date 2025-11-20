import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/wishlist_cubit.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/amazon_style_product_card.dart';

class WishlistScreen extends StatelessWidget {
  final bool showAppBar;
  
  const WishlistScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: showAppBar ? AppBar(
        title: Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: const [CartIconButton()],
      ) : null,
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          final wishlistItems = context.read<WishlistCubit>().wishlistItems;
          
          if (wishlistItems.isEmpty) {
            return _buildEmptyWishlist(context);
          }

          return SafeArea(
            child: Column(
              children: [
                // Wishlist Header with Stats
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.surface,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: colorScheme.error,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${wishlistItems.length} ${wishlistItems.length == 1 ? 'item' : 'items'} saved',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Your favorite products',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (wishlistItems.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showClearWishlistDialog(context),
                          icon: Icon(Icons.clear_all, size: 18.sp),
                          label: Text(
                            'Clear All',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Wishlist Grid with Professional Cards
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.58, // Adjusted for better proportions
                      ),
                      itemCount: wishlistItems.length,
                      itemBuilder: (context, index) {
                        final product = wishlistItems[index];
                        return AmazonStyleProductCard(
                          product: product,
                          onTap: () => context.push('/product/${product.id}'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 80.sp,
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Your wishlist is empty',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Save your favorite products by tapping the heart icon.\nWe\'ll keep them safe for you!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              // SizedBox(height: 32.h),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     onPressed: () => context.go('/home'),
              //     icon: Icon(Icons.shopping_bag_outlined, size: 20.sp),
              //     label: Text(
              //       'Discover Products',
              //       style: TextStyle(
              //         fontSize: 16.sp,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: colorScheme.primary,
              //       foregroundColor: colorScheme.onPrimary,
              //       padding: EdgeInsets.symmetric(vertical: 16.h),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WishlistCubit>().clearWishlist();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wishlist cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
