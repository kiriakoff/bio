import 'dart:math';
import 'dart:ui';

import 'package:bio/components/global.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FSurface extends StatefulWidget {
  const FSurface({
    super.key,
    this.alignment,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.color,
    this.lift = false,
    this.stagger = true,
    this.elevation = 1,
    this.hilight = 0,
    this.round = false,
    this.clip = true,
    this.child,
  }) : assert(elevation >= 0);

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final bool clip;

  /// Fixed fill color instead of the theme lerp (e.g. badges).
  final Color? color;

  /// Raises the surface in its resting state, the way buttons behave: shifted
  /// up in the light theme, settling back down when pressed and when the theme
  /// animates. Off by default: static surfaces (badges, cards, the photo) do
  /// not need the motion — without it they stay aligned with their neighbors
  /// and do not jump during the theme transition.
  final bool lift;

  /// Whether the surface participates in the staggered cascade during the
  /// theme transition (see [_staggeredProgress]). Thin decorative outlines
  /// (e.g. the photo ring) look better synced with the wave front, so such
  /// surfaces can opt out.
  final bool stagger;

  final double elevation;
  final double hilight;
  final bool round;

  @override
  State<FSurface> createState() => _FSurfaceState();
}

class _FSurfaceState extends State<FSurface> {
  static const double _staggerSpan = 0.55;

  final Random _random = Random();
  int? _cachedTransitionId;
  double _delay = 0;

  /// Theme transition progress 0..1 toward the target, with a cascade delay
  /// specific to this surface. Only meaningful while a transition is running.
  ///
  /// The delay makes surfaces flip one after another instead of all at once:
  /// the farther a surface is from the wave origin (the toggle that was
  /// pressed), the later it switches, plus a bit of randomness so the
  /// cascade does not look mechanical.
  double _staggeredProgress(AppState app) {
    // Opted-out surfaces stay in rhythm with the wave: their progress is the
    // fraction of the wave front that has passed over this surface, so the
    // flip happens exactly while the front crosses it (with a small soft
    // band instead of an instant flip).
    if (!widget.stagger &&
        app.waveOrigin != null &&
        app.waveMaxDist > 0) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        final center = renderObject.localToGlobal(renderObject.size.center(Offset.zero));
        final dist = (center - app.waveOrigin!).distance;
        return ((app.waveT * app.waveMaxDist - dist) / (app.waveMaxDist * 0.15))
            .clamp(0.0, 1.0);
      }
    }

    if (_cachedTransitionId != app.transitionId) {
      var normDist = 0.5;
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox &&
          renderObject.hasSize &&
          app.waveOrigin != null &&
          app.waveMaxDist > 0) {
        final center = renderObject.localToGlobal(renderObject.size.center(Offset.zero));
        normDist = ((center - app.waveOrigin!).distance / app.waveMaxDist).clamp(0.0, 1.0);
      }
      _delay = (normDist * 0.7 + _random.nextDouble() * 0.15).clamp(0.0, 0.85);
      _cachedTransitionId = app.transitionId;
    }
    // Shift the shared progress back by the delay, then renormalize so every
    // surface still plays the full 0..1 range inside the global transition.
    return ((app.waveT - _delay * _staggerSpan) / (1 - _staggerSpan)).clamp(0.0, 1.0);
  }

  /// This surface's own absolute theme value, independent of other surfaces.
  double _localThemeT(AppState app) {
    if (!app.themeTransitionActive) return app.themeT;
    return lerpDouble(app.transitionFromT, app.transitionToT, _staggeredProgress(app))!;
  }

  BoxShadow _shadowOf(Palette palette, double pressK) {
    return BoxShadow(
      color: palette.shadowColor.withValues(
        alpha: lerpDouble(palette.shadowRestAlpha, palette.shadowPressAlpha, pressK)!,
      ),
      blurRadius: lerpDouble(palette.shadowRestBlur, palette.shadowPressBlur, pressK)!,
      spreadRadius: lerpDouble(palette.shadowRestSpread, palette.shadowPressSpread, pressK)!,
      offset: Offset(
        0,
        lerpDouble(palette.shadowRestOffsetY, palette.shadowPressOffsetY, pressK)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final localThemeT = _localThemeT(app);
    final palette = Palette.lerp(Palette.light, Palette.dark, localThemeT)!;
    final pressK = 1 - widget.elevation;

    final shadow = BoxShadow.lerp(
      _shadowOf(Palette.light, pressK),
      _shadowOf(Palette.dark, pressK),
      localThemeT,
    )!;
    final borderAlpha = lerpDouble(palette.borderRestAlpha, palette.borderPressAlpha, pressK)!;
    final borderWidth = lerpDouble(palette.borderRestWidth, palette.borderPressWidth, pressK)!;

    // The outline must not live in `decoration`: Container adds the border's
    // dimensions to its padding (_paddingIncludingDecoration), so in the dark
    // theme the content would get a ~1px inset, buttons would grow wider and
    // drift apart during the theme animation. Instead the stroke is painted
    // on top of the box, on its outside (StrokeAlign.outside) — it has no
    // effect on layout at all.
    final border = borderWidth > 0
        ? Border.all(
            color: palette.borderColor.withValues(alpha: borderAlpha),
            width: borderWidth,
            strokeAlign: BorderSide.strokeAlignOutside,
          )
        : null;
    final borderRadius = BorderRadius.circular(widget.round ? 1000 : Global.radius);

    final surface = Container(
      alignment: widget.alignment,
      padding: widget.padding,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      constraints:
          widget.constraints ?? BoxConstraints(minHeight: Global.radius * 2, minWidth: Global.radius * 2),
      clipBehavior: widget.clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: widget.color ??
            Color.lerp(palette.background, palette.backgroundHilight, widget.hilight),
        borderRadius: borderRadius,
        boxShadow: [shadow],
      ),
      foregroundDecoration:
          border == null ? null : BoxDecoration(border: border, borderRadius: borderRadius),
      child: widget.child,
    );

    if (!widget.lift) return surface;
    return Transform.translate(
      offset: Offset(0, -3 * widget.elevation * (1 - localThemeT)),
      child: surface,
    );
  }
}
