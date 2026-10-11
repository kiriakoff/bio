import 'package:bio/components/global.dart';
import 'package:bio/components/text.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Плашка «слишком узко»: когда окно сжато по горизонтали сильнее
/// разумного, полностью закрывает его непрозрачным фоном (чтобы пережатый
/// рендер не просвечивал) и показывает вертикальное сообщение с просьбой
/// расширить окно. Появление и исчезновение — плавное, через прозрачность.
class NarrowOverlay extends StatelessWidget {
  /// Ниже этой ширины окно считается слишком узким.
  static const double minWidth = 300;

  /// Показывать ли плашку (окно слишком узкое для страницы).
  final bool visible;

  const NarrowOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: ColoredBox(
          color: Global.backgroundColor,
          child: Center(
            // scaleDown: на низких окнах сообщение ужмётся, а не обрежется.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RotatedBox(
                // Текст читается сверху вниз при наклоне головы вправо.
                quarterTurns: 1,
                child: FText(strings.narrowWindow, heading: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
