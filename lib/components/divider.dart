import 'package:bio/components/global.dart';
import 'package:flutter/widgets.dart';

class FDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final EdgeInsetsGeometry? margin;

  const FDivider({super.key, this.thickness = 3, this.indent = 0, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      margin: margin ?? EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Global.dividerColor,
        borderRadius: BorderRadius.circular(thickness),
      ),
    );
  }
}
