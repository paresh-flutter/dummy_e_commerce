import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/product_cubit.dart';
import '../../viewmodels/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // Load products and check authentication, then navigate accordingly
    context.read<ProductCubit>().loadProducts();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final authCubit = context.read<AuthCubit>();
        if (authCubit.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Text animation controller
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    // Start logo animation immediately
    _logoAnimationController.forward();
    
    // Start text animation after a delay
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.9),
                    colorScheme.primaryContainer.withOpacity(0.1),
                  ]
                : [
                    colorScheme.primaryContainer.withOpacity(0.1),
                    colorScheme.surface,
                    colorScheme.secondaryContainer.withOpacity(0.05),
                  ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Section
                  AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(32.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.2),
                                  colorScheme.primary.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary.withOpacity(0.3),
                                    colorScheme.primary.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 80.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 48.h),

                  // Animated App Name
                  AnimatedBuilder(
                    animation: _textAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'ShopEase',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Your Shopping Companion',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16.sp,
                                  color: colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}