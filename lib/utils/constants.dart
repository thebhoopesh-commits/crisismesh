// Re-export of the canonical TacticalColors class so widgets/services
// that prefer importing from `utils/` can do so without coupling to the
// theme file directly.

export '../app_theme.dart' show TacticalColors;

/// Layout & spacing tokens — kept in sync with [[TacticalTheme]].
class Spacing {
  Spacing._();

  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double touchTarget = 48.0;
}

class Radii {
  Radii._();

  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
}

class Durations {
  Durations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
}
