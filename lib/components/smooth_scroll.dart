import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FSmoothScroll extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  /// Exponential approach rate, 1/second.
  final double smoothness;

  /// Minimum approach speed, px/s — trims off the asymptotic tail of the
  /// exponential so the last few pixels do not drag on forever.
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

    // Each wheel tick only pushes the target further away; the motion toward
    // it stays continuous (the ticker keeps running between ticks).
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

    // External scrolling (touch, scrollbar) is in progress — yield to the
    // native behavior instead of fighting over the position.
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

    // Exponential approach: the closer we are, the slower we move, but never
    // slower than minVelocity — otherwise the tail of the ease would drag on.
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
