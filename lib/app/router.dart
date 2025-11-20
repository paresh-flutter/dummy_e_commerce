import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_cubit.dart';
import '../views/screens/checkout_screen.dart';
import '../views/screens/forgot_password_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/cart_screen.dart';
import '../views/screens/wishlist_screen.dart';
import '../views/screens/profile_screen.dart';
import '../views/screens/main_navigation_screen.dart';
import '../views/screens/orders_screen.dart';
import '../views/screens/product_detail_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/address_screen.dart';
import '../views/screens/add_edit_address_screen.dart';
import '../views/screens/order_detail_screen.dart';
import '../views/screens/edit_profile_screen.dart';
import '../views/screens/notifications_screen.dart';
import '../views/screens/settings_screen.dart';
import '../views/screens/help_support_screen.dart';
import '../views/screens/about_screen.dart';
import '../models/address.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Helper method to create a page with no transition
  Page _noTransitionPage(Widget child, String routeName) {
    return MaterialPage(
      key: ValueKey('no-transition-$routeName'),
      child: child,
    );
  }

  late final GoRouter router;

  factory AppRouter() {
    return _instance;
  }

  AppRouter._internal() {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),
      redirect: (BuildContext context, GoRouterState state) {
        final authCubit = context.read<AuthCubit>();
        final isAuthenticated = authCubit.state is AuthAuthenticated;
        final isAuthRoute = _isAuthRoute(state.matchedLocation);

        // If not authenticated and not on auth route, redirect to login
        if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/') {
          return '/login';
        }

        // If authenticated and on auth route, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null; // No redirect needed
      },
      routes: [
        // Splash screen
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Main navigation shell
            // These routes will be rendered inside the ShellRoute's Navigator
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => _noTransitionPage(
                const MainNavigationScreen(initialIndex: 0),
                'home',
              ),
            ),
            // Direct home screen route for cart navigation
            GoRoute(
              path: '/cart',
              name: 'cart',
              pageBuilder: (context, state) => _noTransitionPage(
                const CartScreen(),
                'cart',
              ),
            ),
            GoRoute(
              path: '/wishlist',
              name: 'wishlist',
              pageBuilder: (context, state) => _noTransitionPage(
                const MainNavigationScreen(),
                'wishlist',
              ),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => _noTransitionPage(
                const MainNavigationScreen(),
                'profile',
              ),
            ),

        // Other routes
        GoRoute(
          path: '/product/:id',
          name: 'product_detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductDetailScreen(productId: id);
          },
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/addresses',
          name: 'addresses',
          builder: (context, state) => const AddressScreen(),
        ),
        GoRoute(
          path: '/add-edit-address',
          name: 'add_edit_address',
          builder: (context, state) {
            final address = state.extra as Address?;
            return AddEditAddressScreen(address: address);
          },
        ),
        GoRoute(
          path: '/order/:orderId',
          name: 'order_detail',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderDetailScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/edit-profile',
          name: 'edit_profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/help-support',
          name: 'help_support',
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }

  bool _isAuthRoute(String location) {
    return location.startsWith('/login') ||
        location.startsWith('/register') ||
        location.startsWith('/forgot-password');
  }

  int _getIndexForRoute(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/cart':
        return 1;
      case '/wishlist':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}
