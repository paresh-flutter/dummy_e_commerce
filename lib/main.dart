
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app/router.dart';
import 'theme/app_theme.dart';
import 'services/product_service.dart';
import 'services/authentication_service.dart';
import 'services/order_repository.dart';
import 'services/stripe_service.dart';
import 'viewmodels/product_cubit.dart';
import 'viewmodels/cart_cubit.dart';
import 'viewmodels/auth_cubit.dart';
import 'viewmodels/wishlist_cubit.dart';
import 'viewmodels/order_cubit.dart';
import 'viewmodels/address_cubit.dart';
import 'viewmodels/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase with default options
  await Firebase.initializeApp();

  // Initialize Stripe
  final stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.com.tbg.ecommerce';
  Stripe.instance.applySettings();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Set system UI overlay style for better dark mode support
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Size _getDesignSize() {
    try {
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final physicalSize = window.physicalSize;
      final devicePixelRatio = window.devicePixelRatio;
      final logicalSize = physicalSize / devicePixelRatio;

      if (logicalSize.shortestSide < 600) {
        debugPrint("📱 Using Mobile design size");
        return const Size(428, 926); // Mobile
      } else {
        debugPrint("💻 Using Tablet design size");
        return const Size(1024, 1366); // Tablet
      }
    } catch (e) {
      debugPrint("⚠️ Failed to detect device size, using default mobile design. Error: $e");
      return const Size(428, 926);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Firebase services
    final firebaseAuth = FirebaseAuth.instance;

    // Initialize services with dependency injection
    final authService = AuthenticationService(
      firebaseAuth: firebaseAuth,
    );

    // Initialize other services
    final productService = ProductService();
    final orderRepository = OrderRepository();

    return MultiBlocProvider(
      providers: [
        // Theme Cubit
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),

        // Auth Cubit with dependency injection
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authService)..checkAuthStatus(),
        ),

        // Other cubits
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(productService),
        ),
        BlocProvider<CartCubit>(
          create: (context) => CartCubit(),
        ),
        BlocProvider<WishlistCubit>(
          create: (context) => WishlistCubit(),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => OrderCubit(),
        ),
        BlocProvider<AddressCubit>(
          create: (context) => AddressCubit(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // When user authenticates, set user ID in all cubits
          if (state is AuthAuthenticated) {
            final userId = state.user.id;
            print('Auth state changed to authenticated, setting user ID: $userId');
            context.read<CartCubit>().setUserId(userId);
            context.read<WishlistCubit>().setUserId(userId);
            context.read<OrderCubit>().setUserId(userId);
            context.read<AddressCubit>().setUserId(userId);
          }
          // When user logs out, clear user ID from all cubits
          else if (state is AuthUnauthenticated) {
            print('Auth state changed to unauthenticated, clearing user IDs');
            context.read<CartCubit>().setUserId(null);
            context.read<WishlistCubit>().setUserId(null);
            context.read<OrderCubit>().setUserId(null);
            context.read<AddressCubit>().clear();
          }
        },
        child: ScreenUtilInit(
        designSize: _getDesignSize(),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              // Update system UI overlay style based on theme
              final isDark = themeState.themeMode == ThemeMode.dark ||
                  (themeState.themeMode == ThemeMode.system &&
                      MediaQuery.of(context).platformBrightness == Brightness.dark);
              
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                ),
              );
              
              return MaterialApp.router(
                title: 'Dummy E-Commerce',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: AppRouter().router,
              );
            },
          );
        },
        ),
      ),
    );
  }
}
