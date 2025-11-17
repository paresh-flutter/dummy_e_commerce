import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced loading states with professional animations and micro-interactions
class EnhancedLoadingStates {
  
  /// Pulsing dot loader for buttons and small spaces
  static Widget pulsingDots({
    Color? color,
    double size = 8.0,
    int dotCount = 3,
  }) {
    return _PulsingDotsLoader(
      color: color,
      size: size,
      dotCount: dotCount,
    );
  }

  /// Skeleton loader for content areas
  static Widget skeleton({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return _SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Spinning loader with custom design
  static Widget spinner({
    Color? color,
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return _SpinnerLoader(
      color: color,
      size: size,
      strokeWidth: strokeWidth,
    );
  }

  /// Bouncing cart icon for add to cart actions
  static Widget bouncingCart({
    Color? color,
    double size = 24.0,
  }) {
    return _BouncingCartLoader(
      color: color,
      size: size,
    );
  }

  /// Wave loader for page transitions
  static Widget wave({
    Color? color,
    double height = 4.0,
  }) {
    return _WaveLoader(
      color: color,
      height: height,
    );
  }

  /// Fade transition wrapper
  static Widget fadeTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    bool isVisible = true,
  }) {
    return _FadeTransitionWrapper(
      duration: duration,
      isVisible: isVisible,
      child: child,
    );
  }

  /// Scale transition for buttons
  static Widget scaleTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 150),
    bool isPressed = false,
  }) {
    return _ScaleTransitionWrapper(
      duration: duration,
      isPressed: isPressed,
      child: child,
    );
  }
}

class _PulsingDotsLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final int dotCount;

  const _PulsingDotsLoader({
    this.color,
    required this.size,
    required this.dotCount,
  });

  @override
  State<_PulsingDotsLoader> createState() => _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState extends State<_PulsingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: 0.3 + (0.7 * _animations[index].value),
                child: Container(
                  width: widget.size.w,
                  height: widget.size.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const _SkeletonLoader({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width.w,
          height: widget.height.h,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.surfaceContainerHigh,
                Theme.of(context).colorScheme.surfaceContainer,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159 / 4),
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const _SpinnerLoader({
    this.color,
    required this.size,
    required this.strokeWidth,
  });

  @override
  State<_SpinnerLoader> createState() => _SpinnerLoaderState();
}

class _SpinnerLoaderState extends State<_SpinnerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size.w, widget.size.w),
        painter: _SpinnerPainter(
          color: widget.color ?? Theme.of(context).primaryColor,
          strokeWidth: widget.strokeWidth.w,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      3.14159 * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BouncingCartLoader extends StatefulWidget {
  final Color? color;
  final double size;

  const _BouncingCartLoader({
    this.color,
    required this.size,
  });

  @override
  State<_BouncingCartLoader> createState() => _BouncingCartLoaderState();
}

class _BouncingCartLoaderState extends State<_BouncingCartLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.4 * _bounceAnimation.value),
          child: Icon(
            Icons.shopping_cart,
            size: widget.size.w,
            color: widget.color ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class _WaveLoader extends StatefulWidget {
  final Color? color;
  final double height;

  const _WaveLoader({
    this.color,
    required this.height,
  });

  @override
  State<_WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<_WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height.h),
          painter: _WavePainter(
            color: widget.color ?? Theme.of(context).primaryColor,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _WavePainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.5;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          waveHeight *
              math.sin((x / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FadeTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isVisible;

  const _FadeTransitionWrapper({
    required this.child,
    required this.duration,
    required this.isVisible,
  });

  @override
  State<_FadeTransitionWrapper> createState() => _FadeTransitionWrapperState();
}

class _FadeTransitionWrapperState extends State<_FadeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_FadeTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _ScaleTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isPressed;

  const _ScaleTransitionWrapper({
    required this.child,
    required this.duration,
    required this.isPressed,
  });

  @override
  State<_ScaleTransitionWrapper> createState() => _ScaleTransitionWrapperState();
}

class _ScaleTransitionWrapperState extends State<_ScaleTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ScaleTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
