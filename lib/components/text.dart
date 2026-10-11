import 'package:bio/components/text_style.dart';
import 'package:flutter/widgets.dart';

class FText extends StatelessWidget {
  final String data;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final FTextStyle? style;
  final int? heading;

  const FText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style?.style ?? FTextStyle(heading: heading).style,
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}
