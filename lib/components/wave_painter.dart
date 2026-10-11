import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';

/// Paints the theme transition as a wave: the target color spreads over the
/// screen as a soft-edged circle growing from the point where the theme
/// toggle was pressed. Once the circle covers the viewport, it becomes the
/// new base fill.
class WavePainter extends CustomPainter {
  final AppState app;

  WavePainter(this.app);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final progress = app.waveT;
    // Base fill: the color the wave started from — until the wave fully
    // covers the screen, then the target color takes over for good.
    final base = progress >= 1 ? app.waveTo : app.waveFrom;
    canvas.drawRect(rect, Paint()..color = base);

    if (progress <= 0 || progress >= 1) return;

    final origin = app.waveOrigin;
    // No origin (e.g. the system theme changed on its own): fall back to a
    // plain cross-fade instead of a directional circle.
    if (origin == null) {
      canvas.drawRect(
        rect,
        Paint()..color = app.waveTo.withValues(alpha: progress),
      );
      return;
    }

    // The wave front: a blurred circle whose radius grows with the progress,
    // revealing the target color over the base.
    canvas.drawCircle(
      origin,
      progress * app.waveMaxDist,
      Paint()
        ..color = app.waveTo
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}
