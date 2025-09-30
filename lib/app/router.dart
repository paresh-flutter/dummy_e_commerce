import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/screens/main_navigation_screen.dart';
import '../views/screens/product_detail_screen.dart';
import '../views/screens/checkout_screen.dart';
import '../views/screens/orders_screen.dart';
import '../viewmodels/auth_cubit.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router() => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/',
        redirect: (context, state) {
          final authCubit = context.read<AuthCubit>();
          final isAuthenticated = authCubit.isAuthenticated;
          final isAuthRoute = state.matchedLocation.startsWith('/login') || 
                             state.matchedLocation.startsWith('/register');
          
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
          GoRoute(
            path: '/',
            name: 'splash',
            builder: (context, state) => const SplashScreen(),
          ),
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
            path: '/home',
            name: 'home',
            builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
          ),
          GoRoute(
            path: '/wishlist',
            name: 'wishlist',
            builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
          ),
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
        ],
      );
}
