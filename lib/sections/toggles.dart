import 'dart:math';

import 'package:bio/components/state_button.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TogglesSection extends StatelessWidget {
  const TogglesSection({super.key});

  static final GlobalKey<FStateButtonState> _langRu = GlobalKey();
  static final GlobalKey<FStateButtonState> _langEn = GlobalKey();
  static final GlobalKey<FStateButtonState> _themeLight = GlobalKey();
  static final GlobalKey<FStateButtonState> _themeDark = GlobalKey();

  void _ensureSelected(GlobalKey<FStateButtonState> key, bool wantSelected) {
    final state = key.currentState;
    if (state == null) return;
    if (wantSelected && !state.selected) {
      state.select();
    } else if (!wantSelected && state.selected) {
      state.diselect();
    }
  }

  void _syncSelection(AppState app) {
    _ensureSelected(_langRu, app.language == AppLanguage.ru);
    _ensureSelected(_langEn, app.language == AppLanguage.en);
    _ensureSelected(_themeLight, !app.dark);
    _ensureSelected(_themeDark, app.dark);
  }

  (Offset?, double) _waveMetrics(BuildContext buttonContext) {
    final renderObject = buttonContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return (null, 0);
    final origin = renderObject.localToGlobal(renderObject.size.center(Offset.zero));
    final size = MediaQuery.sizeOf(buttonContext);
    var maxDist = 0.0;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      maxDist = max(maxDist, (corner - origin).distance);
    }
    return (origin, maxDist * 1.15);
  }

  void _setTheme(AppState app, bool dark, BuildContext buttonContext) {
    final (origin, maxDist) = _waveMetrics(buttonContext);
    app.setDark(dark, origin: origin, maxDist: maxDist);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSelection(app));
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        FStateButton(
          key: _langRu,
          label: 'RU',
          initiallySelected: app.language == AppLanguage.ru,
          groupedWith: [_langEn],
          onPressed: (_) => app.setLanguage(AppLanguage.ru),
        ),
        FStateButton(
          key: _langEn,
          label: 'EN',
          initiallySelected: app.language == AppLanguage.en,
          groupedWith: [_langRu],
          onPressed: (_) => app.setLanguage(AppLanguage.en),
        ),
        const SizedBox(width: 12),
        Builder(
          builder: (buttonContext) => FStateButton(
            key: _themeLight,
            icon: 'assets/icons/sun.svg',
            initiallySelected: !app.dark,
            groupedWith: [_themeDark],
            onPressed: (_) => _setTheme(app, false, buttonContext),
          ),
        ),
        Builder(
          builder: (buttonContext) => FStateButton(
            key: _themeDark,
            icon: 'assets/icons/moon.svg',
            initiallySelected: app.dark,
            groupedWith: [_themeLight],
            onPressed: (_) => _setTheme(app, true, buttonContext),
          ),
        ),
      ],
    );
  }
}
