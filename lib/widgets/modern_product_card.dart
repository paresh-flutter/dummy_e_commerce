import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../viewmodels/cart_cubit.dart';
import '../viewmodels/wishlist_cubit.dart';
import '../utils/price_formatter.dart';
import '../theme/app_theme.dart';

class ModernProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ModernProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
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
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: () {
              widget.onTap?.call();
              context.push('/product/${widget.product.id}');
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image with Wishlist Button
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        // Product Image
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppBorderRadius.lg),
                              topRight: Radius.circular(AppBorderRadius.lg),
                            ),
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppBorderRadius.lg),
                              topRight: Radius.circular(AppBorderRadius.lg),
                            ),
                            child: Image.network(
                              widget.product.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(AppBorderRadius.lg),
                                      topRight: Radius.circular(AppBorderRadius.lg),
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(AppBorderRadius.lg),
                                      topRight: Radius.circular(AppBorderRadius.lg),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Wishlist Button
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: BlocBuilder<WishlistCubit, WishlistState>(
                            builder: (context, state) {
                              final isInWishlist = context
                                  .read<WishlistCubit>()
                                  .isInWishlist(widget.product);

                              return Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.shadow.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
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
                                          : colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<WishlistCubit>()
                                        .toggleWishlist(widget.product);
                                  },
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              );
                            },
                          ),
                        ),

                        // Discount Badge (if applicable)
                        if (widget.product.price < 50) // Example discount logic
                          Positioned(
                            top: AppSpacing.sm,
                            left: AppSpacing.sm,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                              ),
                              child: Text(
                                'SALE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onError,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product Details
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category
                        Text(
                          widget.product.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppSpacing.xs),

                        // Product Title
                        Text(
                          widget.product.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppSpacing.sm),

                        // Rating and Price Row
                        Row(
                          children: [
                            // Rating
                            if (widget.product.rating != null) ...[
                              Icon(
                                Icons.star,
                                size: 12,
                                color: colorScheme.tertiary,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                widget.product.rating!.rate.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                            ],

                            // Price
                            Text(
                              PriceFormatter.format(widget.product.price),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppSpacing.sm),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<CartCubit>().add(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.product.title} added to cart'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.add_shopping_cart, size: 14.sp),
                            label: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
