import 'dart:math';

import 'package:bio/components/text_style.dart';
import 'package:flutter/widgets.dart';

/// Text with a per-letter language-switch transition: every character flips
/// from the old value to the new one at its own random moment within the
/// shared animation. All the FText widgets on the page switch simultaneously,
/// but each one in its own random order.
class FText extends StatefulWidget {
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
  State<FText> createState() => _FTextState();
}

class _FTextState extends State<FText> with SingleTickerProviderStateMixin {
  /// Transition duration.
  static const Duration _duration = Duration(milliseconds: 800);

  late final AnimationController _controller;
  final Random _random = Random();

  String _display = '';
  String _from = '';
  String _to = '';

  /// Per-character random switch moment, 0..1 of the animation timeline.
  List<double> _switchAt = const [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _display = widget.data;
  }

  @override
  void didUpdateWidget(FText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Text unchanged (e.g. a rebuild caused by the theme switch) — do not
    // animate.
    if (widget.data == oldWidget.data || widget.data == _display) return;
    _scramble(from: _display, to: widget.data);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scramble({required String from, required String to}) {
    // Start from the currently displayed state: if the toggle is flipped
    // mid-animation, the transition continues from the current mix of old
    // and new letters instead of starting over.
    final count = max(from.length, to.length);
    _switchAt = List<double>.generate(count, (_) => _random.nextDouble());
    _from = from;
    _to = to;
    _controller.forward(from: 0);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() => _display = _to);
  }

  void _onTick() {
    final t = Curves.easeOutCubic.transform(_controller.value);
    setState(() => _display = _compose(t));
  }

  String _compose(double t) {
    // Stitch the intermediate string: characters past their switch moment
    // come from the new text, the rest from the old one. Indices beyond the
    // shorter string simply have no character (text may shrink or grow).
    final buffer = StringBuffer();
    for (var i = 0; i < _switchAt.length; i++) {
      if (t >= _switchAt[i]) {
        if (i < _to.length) buffer.writeCharCode(_to.codeUnitAt(i));
      } else {
        if (i < _from.length) buffer.writeCharCode(_from.codeUnitAt(i));
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _display,
      style: widget.style?.style ?? FTextStyle(heading: widget.heading).style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
    );
  }
}
