import 'package:bio/components/global.dart';
import 'package:bio/components/surface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FIconBadge extends StatelessWidget {
  final String asset;
  final double size;
  final double scale;
  final Color? color;
  final Color? background;

  const FIconBadge(
    this.asset, {
    super.key,
    this.size = 34,
    this.scale = 0.55,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return FSurface(
      round: true,
      width: size,
      height: size,
      constraints: BoxConstraints.tight(Size(size, size)),
      color: background ?? Global.badgeColor,
      child: Padding(
        padding: EdgeInsets.all(size * (1 - scale) / 2),
        child: SvgPicture.asset(
          asset,
          width: size * scale,
          height: size * scale,
          colorFilter: ColorFilter.mode(
            color ?? Global.badgeIconColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
