import 'package:flutter/material.dart';

/// Central place for OrderSync's "dark charcoal, rich typography, vibrant status
/// accents" visual identity described in the project proposal.
class AppTheme {
  AppTheme._();

  // Brand + surface palette ---------------------------------------------------
  static const Color brand = Color(0xFFFF7A1A); // vibrant saffron-orange
  static const Color brandAlt = Color(0xFFFFB020); // amber accent

  static const Color charcoal = Color(0xFF15151B); // app background (dark)
  static const Color surfaceDark = Color(0xFF1E1E26); // cards
  static const Color surfaceDarkHigh = Color(0xFF272731); // elevated cards

  static const Color charcoalLight = Color(0xFFF4F4F7); // app background (light)
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.dark)
            .copyWith(
      primary: brand,
      onPrimary: Colors.black,
      secondary: brandAlt,
      onSecondary: Colors.black,
      surface: charcoal,
      onSurface: const Color(0xFFEDEDF3),
      surfaceContainerHighest: surfaceDarkHigh,
    );
    return _base(scheme, surfaceDark);
  }

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(seedColor: brand, brightness: Brightness.light)
            .copyWith(
      primary: brand,
      onPrimary: Colors.white,
      secondary: const Color(0xFFD97706),
      surface: charcoalLight,
      surfaceContainerHighest: const Color(0xFFE8E8EE),
    );
    return _base(scheme, surfaceLight);
  }

  static ThemeData _base(ColorScheme scheme, Color cardColor) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // "Rich typography": strong, condensed weights with clear hierarchy.
      textTheme: Typography.material2021()
          .englishLike
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          )
          .copyWith(
            headlineSmall: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            titleMedium: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceDarkHigh : const Color(0xFFEFEFF4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? surfaceDarkHigh : const Color(0xFFE8E8EE),
        side: BorderSide.none,
        labelStyle: TextStyle(
            color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? surfaceDarkHigh : const Color(0xFF22222A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Vibrant status accents used across the three portals to communicate order
/// lifecycle at a glance.
class StatusColors {
  StatusColors._();
  static const Color newOrder = Color(0xFF3B82F6); // blue
  static const Color accepted = Color(0xFF8B5CF6); // violet
  static const Color preparing = Color(0xFFF59E0B); // amber
  static const Color ready = Color(0xFF22C55E); // green
  static const Color assigned = Color(0xFF14B8A6); // teal
  static const Color enRoute = Color(0xFF0EA5E9); // sky
  static const Color delivered = Color(0xFF16A34A); // deep green
  static const Color offline = Color(0xFFEF4444); // red
  static const Color online = Color(0xFF22C55E); // green
}
