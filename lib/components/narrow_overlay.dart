import 'package:bio/components/global.dart';
import 'package:bio/components/text.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// The "too narrow" plate: when the window is squeezed horizontally beyond
/// reason, it covers the window with a fully opaque backdrop (so the
/// squeezed render does not show through) and displays a vertical message
/// asking to widen the window. Appears and disappears smoothly, via opacity.
class NarrowOverlay extends StatelessWidget {
  /// Below this width the window counts as too narrow.
  static const double minWidth = 300;

  /// Whether to show the plate (the window is too narrow for the page).
  final bool visible;

  const NarrowOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return IgnorePointer(
      // Hidden plate must not swallow clicks meant for the page beneath.
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: ColoredBox(
          color: Global.backgroundColor,
          child: Center(
            // scaleDown: on short windows the message shrinks instead of
            // getting clipped.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RotatedBox(
                // The text reads top-to-bottom with the head tilted right.
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
