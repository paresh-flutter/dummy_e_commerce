import 'package:flutter/material.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthenticationService())),
        BlocProvider(create: (_) => ProductCubit(ProductService())),
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => WishlistCubit()),
        BlocProvider(create: (_) => OrderCubit(OrderRepository())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 11 Pro design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Modern Store',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
