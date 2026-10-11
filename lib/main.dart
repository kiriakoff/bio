import 'package:bio/components/global.dart';
import 'package:bio/components/smooth_scroll.dart';
import 'package:bio/components/wave_painter.dart';
import 'package:bio/sections/about.dart';
import 'package:bio/sections/footer.dart';
import 'package:bio/sections/head.dart';
import 'package:bio/sections/now.dart';
import 'package:bio/sections/stack.dart';
import 'package:bio/sections/toggles.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    Global.apply(app.palette);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Global.backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: WavePainter(app)),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              child: FSmoothScroll(
                controller: _scrollController,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 660),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      spacing: 32,
                      children: [
                        TogglesSection(),
                        HeadSection(),
                        AboutSection(),
                        StackSection(),
                        NowSection(),
                        FooterSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
