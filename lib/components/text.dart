import 'dart:math';

import 'package:bio/components/text_style.dart';
import 'package:flutter/widgets.dart';

/// Текст с побуквенным переходом при смене языка: каждый символ в свой
/// случайный момент внутри общей анимации мигает «помехами» и фиксируется
/// в новом значении. Все FText на странице переключаются одновременно,
/// но каждый — в своём случайном порядке.
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
  /// Пул символов для «помех»: латиница, кириллица, цифры и пара знаков.
  static const String _noiseChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
      'абвгдежзийклмнопрстуфхцчшщъыьэюя'
      '0123456789#%&@\$';

  /// Длительность перехода.
  static const Duration _duration = Duration(milliseconds: 800);

  /// Какую долю длительности символ мигает помехами, прежде чем зафиксироваться.
  static const double _flickerWindow = 0.35;

  late final AnimationController _controller;
  final Random _random = Random();

  String _display = '';
  String _from = '';
  String _to = '';
  List<double> _starts = const [];
  List<double> _ends = const [];

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
    // посреди анимации, переход продолжится из «абракадабры», а не начнётся заново.
    final count = max(from.length, to.length);
    final starts = List<double>.filled(count, 0);
    final ends = List<double>.filled(count, 0);
    for (var i = 0; i < count; i++) {
      final start = _random.nextDouble() * (1 - _flickerWindow);
      starts[i] = start;
      ends[i] = start + _flickerWindow;
    }
    _from = from;
    _to = to;
    _starts = starts;
    _ends = ends;
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
    for (var i = 0; i < _starts.length; i++) {
      if (t >= _ends[i]) {
        if (i < _to.length) buffer.writeCharCode(_to.codeUnitAt(i));
      } else if (t <= _starts[i]) {
        if (i < _from.length) buffer.writeCharCode(_from.codeUnitAt(i));
      } else {
        buffer.write(_noiseChars[_random.nextInt(_noiseChars.length)]);
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
