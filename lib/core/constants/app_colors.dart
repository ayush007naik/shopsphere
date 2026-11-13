import 'package:flutter/material.dart';

/// Central colour palette for ShopSphere.
///
/// The palette pairs a deep forest green with warm ivory and terracotta to give
/// the store a considered, boutique feel while keeping contrast accessible.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF14342B);
  static const Color primaryDark = Color(0xFF0B201A);
  static const Color primaryLight = Color(0xFF2A5245);
  static const Color accent = Color(0xFFD97757);
  static const Color accentSoft = Color(0xFFF6E6DE);

  static const Color background = Color(0xFFF8F6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF12211C);
  static const Color muted = Color(0xFF6E7A75);
  static const Color border = Color(0xFFE7E2D8);
  static const Color rating = Color(0xFFE0A33E);
  static const Color success = Color(0xFF2E7D5B);
  static const Color error = Color(0xFFB3261E);
  static const Color errorSoft = Color(0xFFFBEAE8);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE58B6C), accent],
  );

  static const LinearGradient imagePlaceholder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE9E4D9), Color(0xFFF4F0E7)],
  );
}
