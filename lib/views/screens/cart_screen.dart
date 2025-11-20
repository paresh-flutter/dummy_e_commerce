import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../models/cart_item.dart';
import '../../utils/price_formatter.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../widgets/cart_icon_button.dart';

class CartScreen extends StatelessWidget {
  final bool showAppBar;
  
  const CartScreen({
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
          'Shopping Cart',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final items = state.items.values.toList();
            final total = context.read<CartCubit>().total;
            final itemCount = context.read<CartCubit>().itemCount;
            
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }
            
            return Column(
              children: [
                // Cart Header with item count
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.surface,
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$itemCount ${itemCount == 1 ? 'item' : 'items'} in cart',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showClearCartDialog(context),
                        icon: Icon(Icons.clear_all, size: 18.sp),
                        label: Text(
                          'Clear All',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(12.w),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItem(context, item);
                    },
                  ),
                ),
                
                // Simple Checkout Button
                Container(
                  color: theme.colorScheme.surface,
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/checkout'),
                      icon: Icon(Icons.shopping_bag_outlined, size: 20.sp),
                      label: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80.sp,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Looks like you haven\'t added anything to your cart yet.\nStart shopping to fill it up!',
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
            //       'Start Shopping',
            //       style: TextStyle(
            //         fontSize: 16.sp,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: colorScheme.primary,
            //       foregroundColor: Theme.of(context).colorScheme.surface,
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
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.product.imageUrl,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80.w,
                    height: 80.h,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 32.sp,
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: 16.w),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.product.category.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        PriceFormatter.format(item.product.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: ${PriceFormatter.format(item.totalPrice)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => context.read<CartCubit>().decrement(item.product),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.remove,
                                  size: 18.sp,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                  vertical: BorderSide(color: Theme.of(context).colorScheme.outline),
                                ),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => context.read<CartCubit>().increment(item.product),
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(8.r)),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.add,
                                  size: 18.sp,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Remove Button
                      InkWell(
                        onTap: () => _showRemoveItemDialog(context, item),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showRemoveItemDialog(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.product.name} from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartCubit>().remove(item.product);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.product.name} removed from cart'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

