import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';

class WavePainter extends CustomPainter {
  final AppState app;

  WavePainter(this.app);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final progress = app.waveT;
    final base = progress >= 1 ? app.waveTo : app.waveFrom;
    canvas.drawRect(rect, Paint()..color = base);

    if (progress <= 0 || progress >= 1) return;

    final origin = app.waveOrigin;
    if (origin == null) {
      canvas.drawRect(
        rect,
        Paint()..color = app.waveTo.withValues(alpha: progress),
      );
      return;
    }

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
