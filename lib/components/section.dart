import 'package:bio/components/icon_badge.dart';
import 'package:bio/components/surface.dart';
import 'package:bio/components/text.dart';
import 'package:flutter/widgets.dart';

class FCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const FCard({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return FSurface(
      margin: margin,
      padding: padding ?? EdgeInsets.all(24),
      child: child,
    );
  }
}

class FSectionTitle extends StatelessWidget {
  final String icon;
  final String text;

  const FSectionTitle({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 6, top: 6),
      child: Row(
        spacing: 14,
        children: [
          FIconBadge(icon, size: 30, scale: 0.58),
          FText(text, heading: 3),
        ],
      ),
    );
  }
}
