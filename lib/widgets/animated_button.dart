import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'enhanced_loading_states.dart';

/// Professional animated button with micro-interactions and loading states
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Size? minimumSize;
  final AnimatedButtonStyle style;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.minimumSize,
    this.style = AnimatedButtonStyle.filled,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _scaleController.forward();
    _rippleController.forward();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!mounted) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _scaleController.reverse();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _rippleController.reverse();
      }
    });
  }

  void _handleTap() {
    if (!widget.isEnabled || widget.isLoading) return;
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.isEnabled && !widget.isLoading;
    
    Color backgroundColor;
    Color foregroundColor;
    
    switch (widget.style) {
      case AnimatedButtonStyle.filled:
        backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
        foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
        break;
      case AnimatedButtonStyle.outlined:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        foregroundColor = widget.foregroundColor ?? theme.primaryColor;
        break;
      case AnimatedButtonStyle.text:
        backgroundColor = Colors.transparent;
        foregroundColor = widget.foregroundColor ?? theme.primaryColor;
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                minWidth: widget.minimumSize?.width ?? 88.w,
                minHeight: widget.minimumSize?.height ?? 48.h,
              ),
              decoration: BoxDecoration(
                color: isEnabled 
                    ? backgroundColor 
                    : backgroundColor.withValues(alpha: 0.5),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
                border: widget.style == AnimatedButtonStyle.outlined
                    ? Border.all(
                        color: isEnabled 
                            ? foregroundColor 
                            : foregroundColor.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : null,

              ),
              child: Stack(
                children: [
                  // Ripple effect
                  if (_isPressed && widget.style == AnimatedButtonStyle.filled)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
                        child: AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: _rippleAnimation.value * 2,
                                  colors: [
                                    theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // Button content
                  Padding(
                    padding: widget.padding ?? EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          EnhancedLoadingStates.pulsingDots(
                            color: foregroundColor,
                            size: 6.0,
                          ),
                          SizedBox(width: 12.w),
                        ] else if (widget.icon != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: isEnabled 
                                  ? foregroundColor 
                                  : foregroundColor.withValues(alpha: 0.5),
                              size: 18.w,
                            ),
                            child: widget.icon!,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: isEnabled 
                                ? foregroundColor 
                                : foregroundColor.withValues(alpha: 0.5),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum AnimatedButtonStyle {
  filled,
  outlined,
  text,
}

/// Floating Action Button with enhanced animations
class AnimatedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExtended;
  final String? label;
  final bool isLoading;

  const AnimatedFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isExtended = false,
    this.label,
    this.isLoading = false,
  });

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLoading) return;
    
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _handleTap,
              backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
              foregroundColor: widget.foregroundColor ?? theme.colorScheme.onPrimary,
              elevation: 8,
              isExtended: widget.isExtended,
              icon: widget.isLoading 
                  ? EnhancedLoadingStates.spinner(
                      color: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                      size: 20.0,
                    )
                  : widget.child,
              label: widget.label != null 
                  ? Text(
                      widget.label!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

/// Icon button with bounce animation
class AnimatedIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const AnimatedIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
    this.size,
    this.padding,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? EdgeInsets.all(8.w),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.color,
                  size: widget.size?.w ?? 24.w,
                ),
                child: widget.icon,
              ),
            ),
          );
        },
      ),
    );
  }
}
