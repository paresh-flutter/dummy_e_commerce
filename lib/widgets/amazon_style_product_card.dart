import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product.dart';
import '../viewmodels/wishlist_cubit.dart';
import '../viewmodels/cart_cubit.dart';
import '../utils/price_formatter.dart';

class AmazonStyleProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const AmazonStyleProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<AmazonStyleProductCard> createState() => _AmazonStyleProductCardState();
}

class _AmazonStyleProductCardState extends State<AmazonStyleProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  double get _discountPercentage {
    // Calculate discount based on price (mock logic)
    if (widget.product.price > 100) return 15;
    if (widget.product.price > 50) return 10;
    if (widget.product.price > 25) return 5;
    return 0;
  }

  bool get _hasDiscount => _discountPercentage > 0;

  double get _originalPrice {
    return widget.product.price / (1 - _discountPercentage / 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: GestureDetector(
              onTap: () {
                widget.onTap?.call();
                context.push('/product/${widget.product.id}');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: _isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 12.r : 6.r,
                      offset: Offset(0, _isHovered ? 6.h : 3.h),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          // Main Product Image
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
                              color: colorScheme.surfaceContainerHigh,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
                              child: Image.network(
                                widget.product.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12.r),
                                      ),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12.r),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                                      size: 40.sp,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // Discount Badge (Top Left)
                          if (_hasDiscount)
                            Positioned(
                              top: 8.h,
                              left: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '${_discountPercentage.toInt()}% OFF',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Wishlist Button (Top Right)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: BlocBuilder<WishlistCubit, WishlistState>(
                              builder: (context, state) {
                                final isInWishlist = context
                                    .read<WishlistCubit>()
                                    .isInWishlist(widget.product);
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withValues(alpha: 0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(alpha: 0.1),
                                        blurRadius: 4.r,
                                        offset: Offset(0, 2.h),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        isInWishlist
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey(isInWishlist),
                                        color: isInWishlist
                                            ? colorScheme.error
                                            : colorScheme.onSurface.withValues(alpha: 0.6),
                                        size: 18.sp,
                                      ),
                                    ),
                                    onPressed: () {
                                      context
                                          .read<WishlistCubit>()
                                          .toggleWishlist(widget.product);
                                    },
                                    constraints: BoxConstraints(
                                      minWidth: 32.w,
                                      minHeight: 32.h,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Product Details Section
                    Padding(
                      padding: EdgeInsets.only(left: 12.w, right: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand/Category
                          Text(
                            widget.product.category.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 4.h),

                          // Product Title
                          Text(
                            widget.product.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: colorScheme.onSurface,
                              fontSize: 13.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 6.h),

                          // Rating Row
                          if (widget.product.rating != null)
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.product.rating!.rate.toStringAsFixed(1),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onTertiary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Icon(
                                        Icons.star,
                                        size: 10.sp,
                                        color: colorScheme.onTertiary,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '(${widget.product.rating!.count})',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),

                          SizedBox(height: 8.h),

                          // Price Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Current Price
                                  Text(
                                    PriceFormatter.format(widget.product.price),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                    ),
                                  ),

                                  // Original Price (if discounted)
                                  if (_hasDiscount) ...[
                                    SizedBox(width: 6.w),
                                    Text(
                                      PriceFormatter.format(_originalPrice),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Delivery Info
                              SizedBox(height: 2.h),
                              Text(
                                'FREE Delivery',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.tertiary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            height: 36.h,
                            child: BlocBuilder<CartCubit, CartState>(
                              builder: (context, cartState) {
                                final isInCart = cartState.items.containsKey(widget.product.id);
                                final quantity = cartState.items[widget.product.id]?.quantity ?? 0;
                                
                                return ElevatedButton(
                                  onPressed: () {
                                    context.read<CartCubit>().add(widget.product);
                                    
                                    // Show feedback snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added ${widget.product.name} to cart',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: colorScheme.tertiary,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInCart
                                        ? colorScheme.secondary.withValues(alpha: 0.8)
                                        : colorScheme.secondary,
                                    foregroundColor: colorScheme.onSecondary,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        isInCart ? 'In Cart ($quantity)' : 'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8.h),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
