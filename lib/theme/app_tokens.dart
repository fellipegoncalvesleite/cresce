import 'package:flutter/material.dart';

/// Semantic design tokens for Cresce.
///
/// The palette stays deliberately restrained: warm neutral surfaces, eucalyptus
/// for primary actions, and a small peach accent. Growth and vaccine states keep
/// their own muted semantic colors and are always paired with text/icons.
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.groupedSurface,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.underFg,
    required this.underBg,
    required this.healthyFg,
    required this.healthyBg,
    required this.aboveFg,
    required this.aboveBg,
    required this.pendingFg,
    required this.pendingBg,
    required this.lateFg,
    required this.lateBg,
    required this.brightness,
  });

  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color accentSoft;

  final Color background;
  final Color surface;
  final Color groupedSurface;
  final Color ink;
  final Color inkMuted;
  final Color hairline;

  final Color underFg;
  final Color underBg;
  final Color healthyFg;
  final Color healthyBg;
  final Color aboveFg;
  final Color aboveBg;

  final Color pendingFg;
  final Color pendingBg;
  final Color lateFg;
  final Color lateBg;

  final Brightness brightness;

  Color get takenFg => healthyFg;
  Color get takenBg => healthyBg;
  Color get upcomingFg => aboveFg;
  Color get upcomingBg => aboveBg;
}

const AppPalette lightPalette = AppPalette(
  brightness: Brightness.light,
  primary: Color(0xFF5D8F83),
  primaryDark: Color(0xFF3E6F65),
  accent: Color(0xFFE9B89B),
  accentSoft: Color(0xFFF8E8DE),
  background: Color(0xFFF7F6F2),
  surface: Color(0xFFFFFFFF),
  groupedSurface: Color(0xFFF1F3F0),
  ink: Color(0xFF202724),
  inkMuted: Color(0xFF69736F),
  hairline: Color(0xFFE7E9E5),
  underFg: Color(0xFFB47724),
  underBg: Color(0xFFF8EDDA),
  healthyFg: Color(0xFF477F72),
  healthyBg: Color(0xFFE4EFEA),
  aboveFg: Color(0xFF547EB5),
  aboveBg: Color(0xFFE8EEF6),
  pendingFg: Color(0xFF69736F),
  pendingBg: Color(0xFFEDEFEA),
  lateFg: Color(0xFFB85E40),
  lateBg: Color(0xFFF6E5DE),
);

const AppPalette darkPalette = AppPalette(
  brightness: Brightness.dark,
  primary: Color(0xFF83AA9F),
  primaryDark: Color(0xFFA8C9C0),
  accent: Color(0xFFD5A68C),
  accentSoft: Color(0xFF3A302B),
  background: Color(0xFF191A18),
  surface: Color(0xFF232522),
  groupedSurface: Color(0xFF2C2E2B),
  ink: Color(0xFFF0F1EC),
  inkMuted: Color(0xFFA2A8A3),
  hairline: Color(0xFF383A36),
  underFg: Color(0xFFD6B071),
  underBg: Color(0xFF342D21),
  healthyFg: Color(0xFF91BAAE),
  healthyBg: Color(0xFF283833),
  aboveFg: Color(0xFF94AED2),
  aboveBg: Color(0xFF29313D),
  pendingFg: Color(0xFFA2A8A3),
  pendingBg: Color(0xFF30322F),
  lateFg: Color(0xFFD89479),
  lateBg: Color(0xFF3A2B25),
);

/// The active palette, swapped at the app root whenever resolved brightness
/// changes. Existing `AppColors.x` call sites remain semantic and theme-aware.
class AppColors {
  AppColors._();

  static AppPalette _p = lightPalette;

  static void apply(Brightness brightness) {
    _p = brightness == Brightness.dark ? darkPalette : lightPalette;
  }

  static Brightness get brightness => _p.brightness;

  static Color get primary => _p.primary;
  static Color get primaryDark => _p.primaryDark;
  static Color get accent => _p.accent;
  static Color get accentSoft => _p.accentSoft;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get groupedSurface => _p.groupedSurface;
  static Color get ink => _p.ink;
  static Color get inkMuted => _p.inkMuted;
  static Color get hairline => _p.hairline;

  static Color get underFg => _p.underFg;
  static Color get underBg => _p.underBg;
  static Color get healthyFg => _p.healthyFg;
  static Color get healthyBg => _p.healthyBg;
  static Color get aboveFg => _p.aboveFg;
  static Color get aboveBg => _p.aboveBg;

  static Color get pendingFg => _p.pendingFg;
  static Color get pendingBg => _p.pendingBg;
  static Color get takenFg => _p.takenFg;
  static Color get takenBg => _p.takenBg;
  static Color get lateFg => _p.lateFg;
  static Color get lateBg => _p.lateBg;
  static Color get upcomingFg => _p.upcomingFg;
  static Color get upcomingBg => _p.upcomingBg;
}

/// 4-point spacing scale used across pages, groups, and metadata.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

class AppRadii {
  AppRadii._();

  static const double card = 22;
  static const double chip = 999;
  static const double field = 16;

  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get fieldRadius => BorderRadius.circular(field);
}
