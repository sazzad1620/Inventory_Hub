import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1A1A1A);
  static const _emerald = Color(0xFF10B981);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        surface: _surface,
        primary: _emerald,
        secondary: _emerald,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface.withValues(alpha: 0.55),
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _emerald),
        ),
      ),
    );
  }
}
