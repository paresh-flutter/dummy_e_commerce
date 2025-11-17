import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Professional Design System for E-Commerce App
/// 
/// This file contains all design tokens, constants, and utilities
/// for maintaining consistent UI/UX across the entire application.
class DesignSystem {
  
  // ==================== COLORS ====================
  
  /// Primary brand colors
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryBlueLight = Color(0xFF818CF8);
  static const Color primaryBlueDark = Color(0xFF4F46E5);
  
  /// Secondary colors
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenLight = Color(0xFF34D399);
  static const Color emeraldGreenDark = Color(0xFF059669);
  
  /// Accent colors
  static const Color amberYellow = Color(0xFFF59E0B);
  static const Color amberYellowLight = Color(0xFFFBBF24);
  static const Color amberYellowDark = Color(0xFFD97706);
  
  /// Status colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  /// Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // ==================== SPACING ====================
  
  /// Responsive spacing system
  static double get space2 => 2.w;   // 2px
  static double get space4 => 4.w;   // 4px
  static double get space6 => 6.w;   // 6px
  static double get space8 => 8.w;   // 8px
  static double get space10 => 10.w; // 10px
  static double get space12 => 12.w; // 12px
  static double get space16 => 16.w; // 16px
  static double get space20 => 20.w; // 20px
  static double get space24 => 24.w; // 24px
  static double get space32 => 32.w; // 32px
  static double get space40 => 40.w; // 40px
  static double get space48 => 48.w; // 48px
  static double get space56 => 56.w; // 56px
  static double get space64 => 64.w; // 64px
  static double get space80 => 80.w; // 80px
  static double get space96 => 96.w; // 96px
  
  // ==================== BORDER RADIUS ====================
  
  /// Responsive border radius system
  static double get radius2 => 2.r;   // 2px
  static double get radius4 => 4.r;   // 4px
  static double get radius6 => 6.r;   // 6px
  static double get radius8 => 8.r;   // 8px
  static double get radius12 => 12.r; // 12px
  static double get radius16 => 16.r; // 16px
  static double get radius20 => 20.r; // 20px
  static double get radius24 => 24.r; // 24px
  static double get radius32 => 32.r; // 32px
  static double get radiusFull => 9999.r; // Full radius
  
  // ==================== TYPOGRAPHY ====================
  
  /// Font sizes (responsive)
  static double get fontSize10 => 10.sp;
  static double get fontSize12 => 12.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;
  static double get fontSize32 => 32.sp;
  static double get fontSize36 => 36.sp;
  static double get fontSize48 => 48.sp;
  
  /// Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  
  /// Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;
  
  // ==================== SHADOWS ====================
  
  /// Box shadow presets
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: black.withValues(alpha: 0.05),
      blurRadius: 2.r,
      offset: Offset(0, 1.h),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: black.withValues(alpha: 0.1),
      blurRadius: 6.r,
      offset: Offset(0, 4.h),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: black.withValues(alpha: 0.1),
      blurRadius: 15.r,
      offset: Offset(0, 10.h),
    ),
  ];
  
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: black.withValues(alpha: 0.15),
      blurRadius: 25.r,
      offset: Offset(0, 20.h),
    ),
  ];
  
  // ==================== GRADIENTS ====================
  
  /// Gradient presets
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successGradient => LinearGradient(
    colors: [emeraldGreen, emeraldGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get warningGradient => LinearGradient(
    colors: [amberYellow, amberYellowDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get shimmerGradient => LinearGradient(
    colors: [
      gray200,
      gray100,
      gray200,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ==================== ANIMATIONS ====================
  
  /// Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 800);
  
  /// Animation curves
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
  
  // ==================== BREAKPOINTS ====================
  
  /// Responsive breakpoints
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointLarge = 1280;
  
  /// Helper methods for responsive design
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointTablet;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
  
  // ==================== COMPONENT SIZES ====================
  
  /// Button sizes
  static Size get buttonSizeSmall => Size(80, 32);
  static Size get buttonSizeMedium => Size(120, 44);
  static Size get buttonSizeLarge => Size(160, 56);
  
  /// Icon sizes
  static double get iconSizeSmall => 16;
  static double get iconSizeMedium => 24;
  static double get iconSizeLarge => 32;
  static double get iconSizeXLarge => 48;
  
  /// Avatar sizes
  static double get avatarSizeSmall => 32;
  static double get avatarSizeMedium => 48;
  static double get avatarSizeLarge => 64;
  static double get avatarSizeXLarge => 96;
  
  // ==================== UTILITY METHODS ====================
  
  /// Create consistent padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }
  
  /// Create consistent margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }
  
  /// Create consistent border radius
  static BorderRadius borderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) {
      return BorderRadius.circular(all);
    }
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }
  
  /// Create consistent text style
  static TextStyle textStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize ?? fontSize14,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color ?? gray900,
      height: height ?? lineHeightNormal,
      letterSpacing: letterSpacing,
    );
  }
}

/// Extension methods for spacing (non-conflicting with flutter_screenutil)
extension DesignSystemSpacing on num {
  /// Create vertical spacing
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  
  /// Create horizontal spacing
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

/// Semantic color system for better maintainability
class SemanticColors {
  static const Color primary = DesignSystem.primaryBlue;
  static const Color secondary = DesignSystem.emeraldGreen;
  static const Color accent = DesignSystem.amberYellow;
  
  static const Color success = DesignSystem.successGreen;
  static const Color warning = DesignSystem.warningOrange;
  static const Color error = DesignSystem.errorRed;
  static const Color info = DesignSystem.infoBlue;
  
  // Light theme colors
  static const Color textPrimaryLight = DesignSystem.gray900;
  static const Color textSecondaryLight = DesignSystem.gray600;
  static const Color textTertiaryLight = DesignSystem.gray400;
  static const Color textInverseLight = DesignSystem.white;
  
  static const Color backgroundPrimaryLight = DesignSystem.white;
  static const Color backgroundSecondaryLight = DesignSystem.gray50;
  static const Color backgroundTertiaryLight = DesignSystem.gray100;
  
  static const Color borderPrimaryLight = DesignSystem.gray200;
  static const Color borderSecondaryLight = DesignSystem.gray300;
  
  // Dark theme colors
  static const Color textPrimaryDark = DesignSystem.gray50;
  static const Color textSecondaryDark = DesignSystem.gray400;
  static const Color textTertiaryDark = DesignSystem.gray500;
  static const Color textInverseDark = DesignSystem.gray900;
  
  static const Color backgroundPrimaryDark = DesignSystem.gray900;
  static const Color backgroundSecondaryDark = DesignSystem.gray800;
  static const Color backgroundTertiaryDark = DesignSystem.gray700;
  
  static const Color borderPrimaryDark = DesignSystem.gray700;
  static const Color borderSecondaryDark = DesignSystem.gray600;
  
  // Common colors
  static const Color borderFocus = DesignSystem.primaryBlue;
  
  // Context-aware getters
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color textInverse(bool isDark) => isDark ? textInverseDark : textInverseLight;
  
  static Color backgroundPrimary(bool isDark) => isDark ? backgroundPrimaryDark : backgroundPrimaryLight;
  static Color backgroundSecondary(bool isDark) => isDark ? backgroundSecondaryDark : backgroundSecondaryLight;
  static Color backgroundTertiary(bool isDark) => isDark ? backgroundTertiaryDark : backgroundTertiaryLight;
  
  static Color borderPrimary(bool isDark) => isDark ? borderPrimaryDark : borderPrimaryLight;
  static Color borderSecondary(bool isDark) => isDark ? borderSecondaryDark : borderSecondaryLight;
}

/// Dark mode specific gradients
class DarkModeGradients {
  static LinearGradient get shimmerGradient => LinearGradient(
    colors: [
      DesignSystem.gray800,
      DesignSystem.gray700,
      DesignSystem.gray800,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get cardGradient => LinearGradient(
    colors: [
      DesignSystem.gray800,
      DesignSystem.gray900,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
