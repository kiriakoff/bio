import 'package:bio/components/global.dart';
import 'package:bio/components/surface.dart';
import 'package:bio/components/text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FStateButton extends StatefulWidget {
  final String label;
  final String? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool initiallySelected;
  final PointerDownEventListener? onPressed;
  final List<GlobalKey<FStateButtonState>>? groupedWith;

  const FStateButton({
    super.key,
    this.label = '',
    this.icon,
    this.iconColor,
    this.iconSize,
    this.initiallySelected = false,
    this.onPressed,
    this.groupedWith,
  });

  @override
  State<FStateButton> createState() => FStateButtonState();
}

class FStateButtonState extends State<FStateButton>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController elevationController;
  late final Animation<double> elevationTween;
  late final AnimationController hilightController;
  late final Animation<double> hilightTween;
  late bool selected;
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
    selected = widget.initiallySelected;
    if (selected) {
      elevationController.value = 1;
    }
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
    unpress();
  }

  void unpress() {
    setState(() {
      pressed = false;
      hovered = false;
    });
    hilightController.stop();
    animateExit();
  }

  void select() {
    setState(() {
      selected = true;
      elevationController.stop();
      animatePress();
    });
    for (GlobalKey<FStateButtonState> sibling in widget.groupedWith ?? []) {
      sibling.currentState?.diselect();
    }
  }

  void diselect() {
    if (!selected) return;
    setState(() {
      selected = false;
      elevationController.stop();
      animateRelease();
    });
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

  void onPointerDown(PointerDownEvent event) {
    if (selected) return;
    pressed = true;
    widget.onPressed?.call(event);
    select();
  }

  void onPointerUp(PointerUpEvent event) {
    pressed = false;
  }

  void onPointerCancel(PointerCancelEvent event) {
    unpress();
  }

  void onEnter(PointerEnterEvent event) {
    hovered = true;
    animateEnter();
  }

  void onExit(PointerExitEvent event) {
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
                  hilight: hilightTween.value * elevationTween.value,
                  child: externalChild!,
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
                      if (widget.label.isNotEmpty) FText(widget.label),
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
