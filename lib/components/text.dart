import 'dart:math';

import 'package:bio/components/text_style.dart';
import 'package:flutter/widgets.dart';

/// Текст с побуквенным переходом при смене языка: каждый символ в свой
/// случайный момент внутри общей анимации переключается со старого значения
/// на новое. Все FText на странице переключаются одновременно, но каждый —
/// в своём случайном порядке.
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
  /// Длительность перехода.
  static const Duration _duration = Duration(milliseconds: 800);

  late final AnimationController _controller;
  final Random _random = Random();

  String _display = '';
  String _from = '';
  String _to = '';

  /// Случайный момент переключения 0..1 для каждого символа.
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
    // Текст не изменился (например, ребилд из-за смены темы) — не анимируем.
    if (widget.data == oldWidget.data || widget.data == _display) return;
    _scramble(from: _display, to: widget.data);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scramble({required String from, required String to}) {
    // Стартуем из текущего отображаемого состояния: если дёрнуть переключатель
    // посреди анимации, переход продолжится с текущей смеси букв, а не
    // начнётся заново.
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
