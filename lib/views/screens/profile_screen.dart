import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_cubit.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../viewmodels/order_cubit.dart';
import '../../viewmodels/wishlist_cubit.dart';
import '../../viewmodels/theme_cubit.dart';
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
      backgroundColor: theme.colorScheme.surface,
      appBar: showAppBar ? AppBar(
        title: Text(
          'My Profile',
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return SafeArea(
              child: SingleChildScrollView(
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
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
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
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
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
                                () => context.push('/edit-profile'),
                                theme.colorScheme.secondary,
                              ),
                              _buildMenuItem(
                                context,
                                Icons.location_on_outlined,
                                'My Addresses',
                                'Manage delivery addresses',
                                () => context.push('/addresses'),
                                theme.colorScheme.tertiary,
                              ),
                              _buildMenuItem(
                                context,
                                Icons.settings_outlined,
                                'Settings',
                                'App preferences',
                                () => context.push('/settings'),
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              //_buildThemeToggleMenuItem(context),
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
                                () => context.push('/help-support'),
                                theme.colorScheme.tertiary,
                              ),
                              _buildMenuItem(
                                context,
                                Icons.info_outline,
                                'About',
                                'App information',
                                () => context.push('/about'),
                                theme.colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            Icons.logout,
                                            color: theme.colorScheme.error,
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
                                                  color: theme.colorScheme.error,
                                                ),
                                              ),
                                              Text(
                                                'Sign out of your account',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: theme.colorScheme.error.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggleMenuItem(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = Theme.of(context);
        final themeCubit = context.read<ThemeCubit>();
        
        IconData themeIcon;
        String themeTitle;
        String themeSubtitle;
        
        switch (themeState.themeMode) {
          case ThemeMode.light:
            themeIcon = Icons.light_mode;
            themeTitle = 'Light Theme';
            themeSubtitle = 'Tap to switch to dark theme';
            break;
          case ThemeMode.dark:
            themeIcon = Icons.dark_mode;
            themeTitle = 'Dark Theme';
            themeSubtitle = 'Tap to switch to system theme';
            break;
          case ThemeMode.system:
            themeIcon = Icons.brightness_auto;
            themeTitle = 'System Theme';
            themeSubtitle = 'Tap to switch to light theme';
            break;
        }
        
        return _buildMenuItem(
          context,
          themeIcon,
          themeTitle,
          themeSubtitle,
          () => themeCubit.toggleTheme(),
          theme.colorScheme.primary,
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
