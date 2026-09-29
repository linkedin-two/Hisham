import 'package:flutter/material.dart';

/// Centralized Color Tokens System for Teacher CMS Mobile App.
/// All colors, gradients, surface shades, and status tokens are grouped TOGETHER here.
abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF144787);
  static const Color primaryDark = Color(0xFF0F3B6A);
  static const Color secondary = Color(0xFFFD9202);

  // Surface & Canvas
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6E9EF);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6C757D);

  // Status Indicators
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC3545);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient progressBarGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A101828),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
}
