import 'package:dummy_e_commerce/models/order.dart';
import 'package:dummy_e_commerce/viewmodels/order_cubit.dart';
import 'package:dummy_e_commerce/viewmodels/address_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_cubit.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../viewmodels/wishlist_cubit.dart';
import '../../widgets/cart_icon_button.dart';

class ProfileScreen extends StatelessWidget {
  final bool showAppBar;
  
  const ProfileScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: showAppBar ? AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [CartIconButton()],
      ) : null,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 16.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            user.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // User Stats Row
                          _buildUserStats(context),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Menu Options
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildMenuSection(
                          context,
                          'Shopping',
                          [
                            _buildMenuItem(
                              context,
                              Icons.shopping_bag_outlined,
                              'My Orders',
                              'View your order history',
                              () => context.push('/orders'),
                              Colors.blue,
                            ),
                            // _buildMenuItem(
                            //   context,
                            //   Icons.favorite_outline,
                            //   'Wishlist',
                            //   'Your saved products',
                            //   () => context.push('/wishlist'),
                            //   Colors.red,
                            // ),
                            // _buildMenuItem(
                            //   context,
                            //   Icons.shopping_cart_outlined,
                            //   'Shopping Cart',
                            //   'Items ready to checkout',
                            //   () => context.push('/cart'),
                            //   Colors.orange,
                            // ),
                          ],
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        _buildMenuSection(
                          context,
                          'Account',
                          [
                            _buildMenuItem(
                              context,
                              Icons.person_outline,
                              'Edit Profile',
                              'Update your information',
                              () => _showComingSoon(context),
                              Colors.purple,
                            ),
                            _buildMenuItem(
                              context,
                              Icons.location_on_outlined,
                              'My Addresses',
                              'Manage delivery addresses',
                              () => context.push('/addresses'),
                              Colors.teal,
                            ),
                            _buildMenuItem(
                              context,
                              Icons.notifications_outlined,
                              'Notifications',
                              'Manage your preferences',
                              () => _showComingSoon(context),
                              Colors.green,
                            ),
                            _buildMenuItem(
                              context,
                              Icons.settings_outlined,
                              'Settings',
                              'App preferences',
                              () => _showComingSoon(context),
                              Colors.grey,
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        _buildMenuSection(
                          context,
                          'Support',
                          [
                            _buildMenuItem(
                              context,
                              Icons.help_outline,
                              'Help & Support',
                              'Get help when you need it',
                              () => _showComingSoon(context),
                              Colors.teal,
                            ),
                            _buildMenuItem(
                              context,
                              Icons.info_outline,
                              'About',
                              'App information',
                              () => _showComingSoon(context),
                              Colors.indigo,
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Logout Button
                        BlocListener<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state is AuthUnauthenticated) {
                              context.go('/login');
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showLogoutDialog(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          Icons.logout,
                                          color: Colors.red.shade600,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Logout',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.sp,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                            Text(
                                              'Sign out of your account',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.red.shade500,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.red.shade400,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Not authenticated'));
        },
      ),
    );
  }

  Widget _buildUserStats(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
  builder: (context, state) {
    int orderCount = 0;
    if (state is OrdersLoaded) {
      orderCount = state.orders.length;
    }
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final cartCount = context.read<CartCubit>().itemCount;
        return BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, wishlistState) {
            final wishlistCount = context.read<WishlistCubit>().wishlistItems.length;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Orders', '$orderCount', Icons.shopping_bag_outlined),
                _buildStatItem('Cart', '$cartCount', Icons.shopping_cart_outlined),
                _buildStatItem('Wishlist', '$wishlistCount', Icons.favorite_outline),
              ],
            );
          },
        );
      },
    );
  },
);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1.h,
                      indent: 56.w,
                      endIndent: 16.w,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
