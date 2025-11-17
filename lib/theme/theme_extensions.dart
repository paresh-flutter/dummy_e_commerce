import 'package:flutter/material.dart';

/// Extension to provide additional theme-aware colors
extension ThemeExtensions on ThemeData {
  /// Get appropriate background color for cards and containers
  Color get cardBackground => colorScheme.brightness == Brightness.light 
    ? Colors.white 
    : const Color(0xFF1E1E1E);
  
  /// Get appropriate subtle text color
  Color get subtleTextColor => colorScheme.brightness == Brightness.light 
    ? Colors.grey.shade600 
    : Colors.grey.shade400;
  
  /// Get appropriate border color
  Color get borderColor => colorScheme.brightness == Brightness.light 
    ? Colors.grey.shade300 
    : Colors.grey.shade700;
  
  /// Get appropriate shadow color
  Color get shadowColor => colorScheme.brightness == Brightness.light 
    ? Colors.black.withValues(alpha: 0.05)
    : Colors.black.withValues(alpha: 0.2);
  
  /// Get appropriate disabled color
  Color get disabledColor => colorScheme.brightness == Brightness.light 
    ? Colors.grey.shade400 
    : Colors.grey.shade600;
  
  /// Get appropriate hint text color
  Color get hintTextColor => colorScheme.brightness == Brightness.light 
    ? Colors.grey.shade500 
    : Colors.grey.shade500;
}

/// Extension for ColorScheme to provide additional colors
extension ColorSchemeExtensions on ColorScheme {
  /// Get appropriate text color for secondary content
  Color get secondaryText => brightness == Brightness.light 
    ? Colors.grey.shade700 
    : Colors.grey.shade300;
  
  /// Get appropriate background for elevated surfaces
  Color get elevatedSurface => brightness == Brightness.light 
    ? Colors.white 
    : const Color(0xFF2A2A2A);
  
  /// Get appropriate color for subtle backgrounds
  Color get subtleBackground => brightness == Brightness.light 
    ? Colors.grey.shade50 
    : const Color(0xFF1A1A1A);
}