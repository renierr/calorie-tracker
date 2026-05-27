import 'package:flutter/material.dart';

class AppThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppThemeColors._({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });
}

class AppTheme {
  // Accent colors — same regardless of brightness
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Theme-aware color accessor
  static AppThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkColors : _lightColors;
  }

  static final AppThemeColors _darkColors = AppThemeColors._(
    background: const Color(0xFF0B0F19),
    surface: const Color(0xFF161F30),
    surfaceLight: const Color(0xFF222F47),
    textPrimary: const Color(0xFFF9FAFB),
    textSecondary: const Color(0xFF9CA3AF),
    textMuted: const Color(0xFF6B7280),
  );

  static final AppThemeColors _lightColors = AppThemeColors._(
    background: const Color(0xFFF9FAFB),
    surface: const Color(0xFFFFFFFF),
    surfaceLight: const Color(0xFFF3F4F6),
    textPrimary: const Color(0xFF111827),
    textSecondary: const Color(0xFF6B7280),
    textMuted: const Color(0xFF9CA3AF),
  );

  // Card decoration with glassmorphism glow
  static BoxDecoration premiumCardDecoration({
    required BuildContext context,
    Color? color,
    double borderRadius = 16.0,
    bool showGlow = false,
    Color glowColor = accentEmerald,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = of(context);
    return BoxDecoration(
      color: color ?? colors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark ? const Color(0x14FFFFFF) : const Color(0x0F000000),
        width: 1,
      ),
      boxShadow: [
        if (showGlow)
          BoxShadow(
            color: glowColor.withValues(alpha: isDark ? 0.15 : 0.12),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        else
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0D000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  // Dark Theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentEmerald,
      scaffoldBackgroundColor: _darkColors.background,
      cardColor: _darkColors.surface,
      dialogTheme: DialogThemeData(backgroundColor: _darkColors.surface),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: _darkColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: _darkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: _darkColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: _darkColors.textSecondary, fontSize: 14),
        labelLarge: TextStyle(
          color: _darkColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColors.surfaceLight.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentEmerald, width: 1.5),
        ),
        labelStyle: TextStyle(color: _darkColors.textSecondary),
        hintStyle: TextStyle(color: _darkColors.textMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentEmerald,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentEmerald,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _darkColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _darkColors.textPrimary),
        titleTextStyle: TextStyle(
          color: _darkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkColors.surface,
        indicatorColor: accentEmerald.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: accentEmerald,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(color: _darkColors.textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentEmerald);
          }
          return IconThemeData(color: _darkColors.textSecondary);
        }),
      ),
    );
  }

  // Light Theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: accentEmerald,
      scaffoldBackgroundColor: _lightColors.background,
      cardColor: _lightColors.surface,
      dialogTheme: DialogThemeData(backgroundColor: _lightColors.surface),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: _lightColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: _lightColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: _lightColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: _lightColors.textSecondary, fontSize: 14),
        labelLarge: TextStyle(
          color: _lightColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentEmerald, width: 1.5),
        ),
        labelStyle: TextStyle(color: _lightColors.textSecondary),
        hintStyle: TextStyle(color: _lightColors.textMuted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentEmerald,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentEmerald,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _lightColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _lightColors.textPrimary),
        titleTextStyle: TextStyle(
          color: _lightColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightColors.surface,
        indicatorColor: accentEmerald.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: accentEmerald,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(color: _lightColors.textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentEmerald);
          }
          return IconThemeData(color: _lightColors.textSecondary);
        }),
      ),
    );
  }
}
