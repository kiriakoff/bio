import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FSmoothScroll extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  /// Коэффициент экспоненциального сближения, 1/сек.
  final double smoothness;

  /// Минимальная скорость подхода к цели, пикс/сек — срезает хвост асимптоты.
  final double minVelocity;

  const FSmoothScroll({
    super.key,
    required this.controller,
    required this.child,
    this.smoothness = 13,
    this.minVelocity = 120,
  });

  @override
  State<FSmoothScroll> createState() => _FSmoothScrollState();
}

class _FSmoothScrollState extends State<FSmoothScroll>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  double _target = 0;
  bool _scrolling = false;
  Duration? _lastElapsed;

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, _resolveScroll);
  }

  void _resolveScroll(PointerSignalEvent event) {
    final scrollEvent = event as PointerScrollEvent;
    if (scrollEvent.scrollDelta.dy == 0) return;
    final position = widget.controller.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;

    // Каждый тик колеса лишь отодвигает цель; движение к ней непрерывно.
    if (!_scrolling) {
      _target = position.pixels;
      _scrolling = true;
      _lastElapsed = null;
      _ticker.start();
    }
    _target = (_target + scrollEvent.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  void _onTick(Duration elapsed) {
    final position = widget.controller.position;
    if (!position.hasContentDimensions || !position.hasPixels) return _stop();

    // Внешняя прокрутка (тач, скроллбар) — отдаём управление нативу.
    if (position.isScrollingNotifier.value) return _stop();

    final dt = _lastElapsed == null
        ? 1 / 60
        : (elapsed - _lastElapsed!).inMicroseconds / 1e6;
    _lastElapsed = elapsed;

    _target = _target.clamp(position.minScrollExtent, position.maxScrollExtent);
    final diff = _target - position.pixels;

    if (diff.abs() < 0.5) {
      position.jumpTo(_target);
      return _stop();
    }

    final velocity = max(widget.smoothness * diff.abs(), widget.minVelocity);
    final step = min(velocity * dt, diff.abs());
    position.jumpTo(position.pixels + diff.sign * step);
  }

  void _stop() {
    _ticker.stop();
    _scrolling = false;
    _lastElapsed = null;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: _onPointerSignal,
      child: widget.child,
    );
  }
}
