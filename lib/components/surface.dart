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

  /// Фиксированный цвет заливки вместо темы-лерпа (например, бейджи).
  final Color? color;

  /// Приподнимает поверхность в положении покоя, как у кнопок: сдвиг вверх
  /// в светлой теме и «доводка» вниз при нажатии и смене темы. По умолчанию
  /// выключено: статичным поверхностям (бейджи, карточки, фото) движение
  /// ни к чему — без него они не съезжают относительно соседей и не прыгают
  /// при анимации темы.
  final bool lift;

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

  /// Прогресс 0..1 к целевой теме с каскадной задержкой поверхности.
  /// Валиден только во время перехода.
  double _staggeredProgress(AppState app) {
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
    return ((app.waveT - _delay * _staggerSpan) / (1 - _staggerSpan)).clamp(0.0, 1.0);
  }

  /// Локальное абсолютное значение темы для этой поверхности.
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

    // Обводка — не в BoxDecoration: Container прибавляет её размеры к padding
    // (_paddingIncludingDecoration), из-за чего в тёмной теме контент
    // получают отступ ~1px, кнопки толстеют и разъезжаются при анимации темы.
    // Рисуем штрих поверх бокса снаружи (StrokeAlign.outside) — на раскладку
    // он не влияет в принципе.
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
