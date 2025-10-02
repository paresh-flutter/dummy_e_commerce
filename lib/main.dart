
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/router.dart';
import 'theme/app_theme.dart';
import 'services/product_service.dart';
import 'services/authentication_service.dart';
import 'services/order_repository.dart';
import 'viewmodels/product_cubit.dart';
import 'viewmodels/cart_cubit.dart';
import 'viewmodels/auth_cubit.dart';
import 'viewmodels/wishlist_cubit.dart';
import 'viewmodels/order_cubit.dart';
import 'viewmodels/address_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with default options
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          create: (context) => OrderCubit(orderRepository),
        ),
        BlocProvider<AddressCubit>(
          create: (context) => AddressCubit(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 13 design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Dummy E-Commerce',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter().router,
          );
        },
      ),
    );
  }
}
