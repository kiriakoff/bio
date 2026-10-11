import 'package:bio/components/surface.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/global.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FButton extends StatefulWidget {
  final String label;
  final String? icon;
  final Color? iconColor;
  final double? iconSize;
  final PointerDownEventListener? onPressed;

  const FButton({super.key, this.label = '', this.icon, this.iconColor, this.iconSize, this.onPressed});

  @override
  State<FButton> createState() => _FButtonState();
}

class _FButtonState extends State<FButton>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController elevationController;
  late final Animation<double> elevationTween;
  late final AnimationController hilightController;
  late final Animation<double> hilightTween;
  bool pressed = false;
  bool hovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    elevationController = AnimationController(vsync: this);
    elevationTween = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(elevationController);
    hilightController = AnimationController(vsync: this);
    hilightTween = Tween<double>(begin: 1, end: 0).animate(hilightController);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    elevationController.dispose();
    hilightController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    if (!mounted) return;
    release();
  }

  void release() {
    setState(() {
      pressed = false;
      hovered = false;
    });
    hilightController.stop();
    animateExit();
    if (elevationController.isAnimating) {
      // Кнопка ещё падает — даём ей упасть до конца. Отжимание начнётся
      // из onPointerDown после завершения animatePress (pressed уже false).
      return;
    }
    animateRelease();
  }

  TickerFuture animatePress() {
    return elevationController.animateTo(
      1,
      duration: const Duration(milliseconds: 50),
    );
  }

  TickerFuture animateRelease() {
    return elevationController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
    );
  }

  TickerFuture animateEnter() {
    return hilightController.animateTo(
      1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  TickerFuture animateExit() {
    return hilightController.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  void onPointerDown(PointerDownEvent event) async {
    if (elevationController.isAnimating) return;
    pressed = true;
    if (widget.onPressed != null) {
      widget.onPressed!(event);
    }
    elevationController.stop();
    await animatePress();
    if (!pressed) {
      animateRelease();
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    pressed = false;
    if (!elevationController.isAnimating) {
      animateRelease();
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    release();
  }

  void onEnter(PointerEnterEvent event) async {
    hovered = true;
    animateEnter();
  }

  void onExit(PointerExitEvent event) async {
    hovered = false;
    animateExit();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: onEnter,
      onExit: onExit,
      child: Listener(
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        child: AnimatedBuilder(
          animation: elevationTween,
          builder: (context, externalChild) {
            return AnimatedBuilder(
              animation: hilightTween,
              builder: (context, internalChild) {
                return FSurface(
                  lift: true,
                  elevation: elevationTween.value,
                  hilight: hilightTween.value,
                  child: externalChild,
                );
              },
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Global.radius * 4 / 3),
            child: IntrinsicWidth(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      if (widget.icon != null)
                        SvgPicture.asset(
                          widget.icon!,
                          width: widget.iconSize ?? 16,
                          height: widget.iconSize ?? 16,
                          colorFilter: ColorFilter.mode(
                            widget.iconColor ?? Global.foregroundColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      FText(widget.label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
