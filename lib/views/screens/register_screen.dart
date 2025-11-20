import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    VoidCallback? onFieldSubmitted,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 16.sp),
      onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted() : null,
      decoration: InputDecoration(
        labelText: labelText,
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
            prefixIcon,
            size: 20.sp,
            color: colorScheme.primary,
          ),
        ),
        suffixIcon: suffixIcon,
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
    );
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    SizedBox(height: 32.h),
                    
                    // Logo and Header Section
                    Container(
                      padding: EdgeInsets.all(20.w),
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
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 48.sp,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    Text(
                      'Create Account',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Join us and start your shopping journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 15.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),

                    // Registration Form Card
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
                            // Name Field
                            _buildTextField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: _validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 20.h),

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              prefixIcon: Icons.email_outlined,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 20.h),

                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              validator: _validatePassword,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
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
                            ),
                            SizedBox(height: 20.h),

                            // Confirm Password Field
                            _buildTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline,
                              validator: _validateConfirmPassword,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              //onFieldSubmitted: _register,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 22.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // Register Button
                            BlocConsumer<AuthCubit, AuthState>(
                              listener: (context, state) {
                                if (state is AuthError) {
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
                                } else if (state is AuthAuthenticated) {
                                  context.go('/home');
                                }
                              },
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
                                    onPressed: state is AuthLoading ? null : _register,
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
                                            'Create Account',
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 15.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign In',
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
                    // SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
