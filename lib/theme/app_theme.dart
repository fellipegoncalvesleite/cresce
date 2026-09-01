import 'package:flutter/material.dart';

import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(lightPalette);
  static ThemeData get dark => _build(darkPalette);

  static ThemeData _build(AppPalette c) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: c.brightness,
        ).copyWith(
          primary: c.primary,
          secondary: c.accent,
          surface: c.surface,
          onSurface: c.ink,
          outline: c.hairline,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: colorScheme,
    );
    final t = base.textTheme;
    final textTheme = t
        .copyWith(
          displayLarge: t.displayLarge?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: t.displayMedium?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: t.displaySmall?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: t.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: t.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: t.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: t.titleLarge?.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: t.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: t.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: t.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodyMedium: t.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodySmall: t.bodySmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
          labelLarge: t.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: t.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: t.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        )
        .apply(bodyColor: c.ink, displayColor: c.ink);

    final restBorder = OutlineInputBorder(
      borderRadius: AppRadii.fieldRadius,
      borderSide: BorderSide.none,
    );

    return base.copyWith(
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: c.ink,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: c.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.field),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: c.primaryDark,
          side: BorderSide(color: c.hairline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.field),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: c.primaryDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: c.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.groupedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: restBorder,
        enabledBorder: restBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.fieldRadius,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.fieldRadius,
          borderSide: BorderSide(color: c.lateFg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.fieldRadius,
          borderSide: BorderSide(color: c.lateFg, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: c.primary,
        labelColor: c.primaryDark,
        unselectedLabelColor: c.inkMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
    );
  }
}
