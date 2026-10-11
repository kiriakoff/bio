import 'dart:ui';

class Palette {
  final Color background;
  final Color backgroundHilight;
  final Color foreground;
  final Color divider;
  final Color badge;
  final Color badgeIcon;
  final Color secondary;
  final Color tertiary;
  final Color faint;

  final Color shadowColor;
  final double shadowRestAlpha;
  final double shadowRestBlur;
  final double shadowRestSpread;
  final double shadowRestOffsetY;
  final double shadowPressAlpha;
  final double shadowPressBlur;
  final double shadowPressSpread;
  final double shadowPressOffsetY;

  final Color borderColor;
  final double borderRestAlpha;
  final double borderRestWidth;
  final double borderPressAlpha;
  final double borderPressWidth;

  const Palette({
    required this.background,
    required this.backgroundHilight,
    required this.foreground,
    required this.divider,
    required this.badge,
    required this.badgeIcon,
    required this.secondary,
    required this.tertiary,
    required this.faint,
    required this.shadowColor,
    required this.shadowRestAlpha,
    required this.shadowRestBlur,
    required this.shadowRestSpread,
    required this.shadowRestOffsetY,
    required this.shadowPressAlpha,
    required this.shadowPressBlur,
    required this.shadowPressSpread,
    required this.shadowPressOffsetY,
    required this.borderColor,
    required this.borderRestAlpha,
    required this.borderRestWidth,
    required this.borderPressAlpha,
    required this.borderPressWidth,
  });

  static const Palette light = Palette(
    background: Color.fromARGB(255, 250, 250, 250),
    backgroundHilight: Color.fromARGB(255, 255, 255, 255),
    foreground: Color.fromARGB(255, 0, 0, 0),
    divider: Color.fromARGB(255, 102, 102, 102),
    badge: Color.fromARGB(255, 51, 51, 51),
    badgeIcon: Color.fromARGB(255, 250, 250, 250),
    secondary: Color.fromARGB(255, 60, 60, 60),
    tertiary: Color.fromARGB(255, 130, 130, 130),
    faint: Color.fromARGB(255, 170, 170, 170),
    shadowColor: Color.fromARGB(255, 0, 0, 0),
    shadowRestAlpha: 0.40,
    shadowRestBlur: 3,
    shadowRestSpread: 0,
    shadowRestOffsetY: 3,
    shadowPressAlpha: 1,
    shadowPressBlur: 0,
    shadowPressSpread: -1,
    shadowPressOffsetY: 0,
    borderColor: Color.fromARGB(255, 0, 0, 0),
    borderRestAlpha: 0,
    borderRestWidth: 0,
    borderPressAlpha: 0,
    borderPressWidth: 0,
  );

  static const Palette dark = Palette(
    background: Color.fromARGB(255, 22, 22, 22),
    backgroundHilight: Color.fromARGB(255, 44, 44, 44),
    foreground: Color.fromARGB(255, 235, 235, 235),
    divider: Color.fromARGB(255, 95, 95, 95),
    badge: Color.fromARGB(255, 228, 228, 228),
    badgeIcon: Color.fromARGB(255, 24, 24, 24),
    secondary: Color.fromARGB(255, 175, 175, 175),
    tertiary: Color.fromARGB(255, 140, 140, 140),
    faint: Color.fromARGB(255, 100, 100, 100),
    shadowColor: Color.fromARGB(255, 143, 216, 255),
    shadowRestAlpha: 0.12,
    shadowRestBlur: 16,
    shadowRestSpread: 1,
    shadowRestOffsetY: 0,
    shadowPressAlpha: 0.34,
    shadowPressBlur: 24,
    shadowPressSpread: 2,
    shadowPressOffsetY: 0,
    borderColor: Color.fromARGB(255, 143, 216, 255),
    borderRestAlpha: 0.22,
    borderRestWidth: 0.9,
    borderPressAlpha: 0.45,
    borderPressWidth: 1.2,
  );

  static Palette? lerp(Palette a, Palette b, double t) {
    return Palette(
      background: Color.lerp(a.background, b.background, t)!,
      backgroundHilight: Color.lerp(a.backgroundHilight, b.backgroundHilight, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      divider: Color.lerp(a.divider, b.divider, t)!,
      badge: Color.lerp(a.badge, b.badge, t)!,
      badgeIcon: Color.lerp(a.badgeIcon, b.badgeIcon, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      tertiary: Color.lerp(a.tertiary, b.tertiary, t)!,
      faint: Color.lerp(a.faint, b.faint, t)!,
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
      shadowRestAlpha: lerpDouble(a.shadowRestAlpha, b.shadowRestAlpha, t)!,
      shadowRestBlur: lerpDouble(a.shadowRestBlur, b.shadowRestBlur, t)!,
      shadowRestSpread: lerpDouble(a.shadowRestSpread, b.shadowRestSpread, t)!,
      shadowRestOffsetY: lerpDouble(a.shadowRestOffsetY, b.shadowRestOffsetY, t)!,
      shadowPressAlpha: lerpDouble(a.shadowPressAlpha, b.shadowPressAlpha, t)!,
      shadowPressBlur: lerpDouble(a.shadowPressBlur, b.shadowPressBlur, t)!,
      shadowPressSpread: lerpDouble(a.shadowPressSpread, b.shadowPressSpread, t)!,
      shadowPressOffsetY: lerpDouble(a.shadowPressOffsetY, b.shadowPressOffsetY, t)!,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      borderRestAlpha: lerpDouble(a.borderRestAlpha, b.borderRestAlpha, t)!,
      borderRestWidth: lerpDouble(a.borderRestWidth, b.borderRestWidth, t)!,
      borderPressAlpha: lerpDouble(a.borderPressAlpha, b.borderPressAlpha, t)!,
      borderPressWidth: lerpDouble(a.borderPressWidth, b.borderPressWidth, t)!,
    );
  }
}

abstract final class Global {
  static double radius = 18;
  static Color backgroundColor = Palette.light.background;
  static Color backgroundHilightColor = Palette.light.backgroundHilight;
  static Color foregroundColor = Palette.light.foreground;
  static Color dividerColor = Palette.light.divider;
  static Color badgeColor = Palette.light.badge;
  static Color badgeIconColor = Palette.light.badgeIcon;
  static Color secondaryColor = Palette.light.secondary;
  static Color tertiaryColor = Palette.light.tertiary;
  static Color faintColor = Palette.light.faint;
  static String fontFamily = 'Geologica';

  static void apply(Palette palette) {
    backgroundColor = palette.background;
    backgroundHilightColor = palette.backgroundHilight;
    foregroundColor = palette.foreground;
    dividerColor = palette.divider;
    badgeColor = palette.badge;
    badgeIconColor = palette.badgeIcon;
    secondaryColor = palette.secondary;
    tertiaryColor = palette.tertiary;
    faintColor = palette.faint;
  }
}
