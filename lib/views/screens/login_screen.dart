import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _loginAsGuest() {
    context.read<AuthCubit>().loginAsGuest();
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
                    colorScheme.surface.withOpacity(0.8),
                    colorScheme.primaryContainer.withOpacity(0.1),
                  ]
                : [
                    colorScheme.primaryContainer.withOpacity(0.1),
                    colorScheme.surface,
                    colorScheme.secondaryContainer.withOpacity(0.05),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  margin: EdgeInsets.all(16.w),
                ),
              );
            }
          },
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and Header Section
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withOpacity(0.1),
                                colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 64.sp,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        
                        Text(
                          'Welcome Back!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Sign in to continue your shopping journey',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48.h),

                        // Login Form Card
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  style: TextStyle(fontSize: 16.sp),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8.w),
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        size: 20.sp,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 18.h,
                                      horizontal: 16.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: _validatePassword,
                                  style: TextStyle(fontSize: 16.sp),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8.w),
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        size: 20.sp,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 22.sp,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 18.h,
                                      horizontal: 16.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32.h),

                                // Login Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return Container(
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.primary.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: state is AuthLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                          ),
                                        ),
                                        child: state is AuthLoading
                                            ? SizedBox(
                                                height: 24.w,
                                                width: 24.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: colorScheme.onPrimary,
                                                ),
                                              )
                                            : Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onPrimary,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),

                                // Guest Login Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return Container(
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colorScheme.outline.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: OutlinedButton(
                                        onPressed: state is AuthLoading ? null : _loginAsGuest,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: colorScheme.surface,
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              size: 20.sp,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Continue as Guest',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurfaceVariant,
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
                        SizedBox(height: 24.h),

                        // Divider with "OR"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: colorScheme.outline.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: colorScheme.outline.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 15.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 24.h),

                        // // Demo Credentials
                        // Container(
                        //   padding: EdgeInsets.all(16.w),
                        //   decoration: BoxDecoration(
                        //     color: colorScheme.surfaceVariant.withOpacity(0.3),
                        //     borderRadius: BorderRadius.circular(12.r),
                        //     border: Border.all(
                        //       color: colorScheme.outline.withOpacity(0.2),
                        //     ),
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       Icon(
                        //         Icons.info_outline,
                        //         size: 20.sp,
                        //         color: colorScheme.primary,
                        //       ),
                        //       SizedBox(height: 8.h),
                        //       Text(
                        //         'Demo Account',
                        //         style: theme.textTheme.titleSmall?.copyWith(
                        //           fontWeight: FontWeight.bold,
                        //           color: colorScheme.onSurfaceVariant,
                        //         ),
                        //       ),
                        //       SizedBox(height: 4.h),
                        //       Text(
                        //         'Email: test@example.com\nPassword: password123',
                        //         textAlign: TextAlign.center,
                        //         style: theme.textTheme.bodySmall?.copyWith(
                        //           color: colorScheme.onSurfaceVariant,
                        //           fontSize: 12.sp,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}