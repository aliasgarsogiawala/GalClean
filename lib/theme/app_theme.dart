import 'package:flutter/material.dart';

/// Central place for the app's "dating app for your gallery" look & feel.
///
/// The palette borrows the warm, romantic feel of swipe-to-match apps:
/// a flame-pink brand gradient, a fresh green "keep" accent and a rose-red
/// "pass" accent.
class AppTheme {
  AppTheme._();

  // Brand colors --------------------------------------------------------------
  static const Color brandPink = Color(0xFFFD297B);
  static const Color brandRed = Color(0xFFFF4E6A);
  static const Color brandOrange = Color(0xFFFF655B);

  /// Green "like / keep" accent.
  static const Color keepColor = Color(0xFF2BD9A8);

  /// Rose-red "pass / delete" accent.
  static const Color deleteColor = Color(0xFFFF4E6A);

  /// Amber "rewind / undo" accent.
  static const Color undoColor = Color(0xFFFFB13C);

  /// The signature flame gradient used across hero areas and buttons.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPink, brandRed, brandOrange],
  );

  static const LinearGradient keepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2BD9A8), Color(0xFF20BDFF)],
  );

  static const LinearGradient deleteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5864), Color(0xFFFD297B)],
  );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.light,
    ).copyWith(
      primary: brandRed,
      secondary: keepColor,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: brandRed,
      secondary: keepColor,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
