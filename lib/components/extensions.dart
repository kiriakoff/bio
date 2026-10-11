import 'package:flutter/widgets.dart';

abstract final class GrayScale {
  static Color fromInt(int value) {
    return Color.fromARGB(255, value, value, value);
  }

  static Color fromDouble(double value) {
    return Color.from(alpha: 1, red: value, green: value, blue: value);
  }

  static Color fromIntAlpha(int value, int alpha) {
    return Color.fromARGB(alpha, value, value, value);
  }

  static Color fromDoubleAlpha(double value, double alpha) {
    return Color.from(alpha: alpha, red: value, green: value, blue: value);
  }
}
