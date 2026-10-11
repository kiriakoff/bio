import 'package:bio/components/global.dart';
import 'package:flutter/widgets.dart';

class FTextStyle {
  static const headingMapping = {
    'Source Code Pro': {
      1: (fontSize: 28.0, fontWeight: FontWeight.w400),
      2: (fontSize: 24.0, fontWeight: FontWeight.w600),
      3: (fontSize: 20.0, fontWeight: FontWeight.w700),
      4: (fontSize: 18.0, fontWeight: FontWeight.w800),
      0: (fontSize: 14.0, fontWeight: FontWeight.w500),
    },
    'Cormorant Infant': {
      1: (fontSize: 30.0, fontWeight: FontWeight.w700),
      2: (fontSize: 24.0, fontWeight: FontWeight.w500),
      3: (fontSize: 20.0, fontWeight: FontWeight.w600),
      4: (fontSize: 18.0, fontWeight: FontWeight.w700),
      0: (fontSize: 18.0, fontWeight: FontWeight.w500),
    },
    'Geologica': {
      1: (fontSize: 30.0, fontWeight: FontWeight.w800),
      2: (fontSize: 24.0, fontWeight: FontWeight.w500),
      3: (fontSize: 20.0, fontWeight: FontWeight.w600),
      4: (fontSize: 18.0, fontWeight: FontWeight.w700),
      0: (fontSize: 18.0, fontWeight: FontWeight.w400),
    },
  };

  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final int? heading;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? letterSpacing;

  const FTextStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.heading,
    this.decoration,
    this.decorationColor,
    this.letterSpacing,
  });

  TextStyle get style {
    var fontFamilyCalced = fontFamily ?? Global.fontFamily;
    return TextStyle(
      color: color ?? Global.foregroundColor,
      fontSize: headingMapping[fontFamilyCalced]?[heading]?.fontSize ?? fontSize ?? headingMapping[fontFamilyCalced]?[0]!.fontSize,
      fontWeight: headingMapping[fontFamilyCalced]?[heading]?.fontWeight ?? fontWeight ?? headingMapping[fontFamilyCalced]?[0]!.fontWeight,
      fontFamily: fontFamilyCalced,
      decoration: decoration,
      decorationColor: decorationColor ?? color ?? Global.foregroundColor,
      letterSpacing: letterSpacing,
    );
  }
}
