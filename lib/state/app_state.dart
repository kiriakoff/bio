import 'dart:ui';

import 'package:bio/components/global.dart';
import 'package:bio/content.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

enum AppLanguage { ru, en }

class AppState extends ChangeNotifier {
  static const Duration _transitionDuration = Duration(milliseconds: 550);

  AppLanguage _language = AppLanguage.ru;
  bool? _darkOverride;
  bool _systemDark;
  double _themeT;
  int _transitionId = 0;
  Color _waveFrom;
  Color _waveTo;
  Offset? _waveOrigin;
  double _waveMaxDist = 0;
  double _animFrom = 0;
  double _animTo = 1;
  double _progress = 0;
  double _transitionFromT = 0;

  late final Ticker _ticker = Ticker(_onTick);

  AppState()
      : _systemDark =
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
        _themeT = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? 1
            : 0,
        _waveFrom = WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? Palette.dark.background
            : Palette.light.background,
        _waveTo = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? Palette.dark.background
            : Palette.light.background {
    _transitionFromT = _themeT;
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _systemDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      if (_darkOverride == null) {
        _animateThemeTo(_systemDark, null, 0);
      }
    };
  }

  AppLanguage get language => _language;

  /// Итоговый выбор темы (намерение), независимо от прогресса анимации.
  bool get dark => _darkOverride ?? _systemDark;

  /// Значение themeT на старте текущего/последнего перехода.
  double get transitionFromT => _transitionFromT;

  /// Целевое значение themeT текущего/последнего перехода.
  double get transitionToT => dark ? 1.0 : 0.0;

  /// Текущее анимированное значение темы: 0 — светлая, 1 — тёмная.
  double get themeT => _themeT;

  /// Прогресс фронта волны к целевой теме: 0..1, быстрый старт, мягкое затухание.
  double get waveT => _progress;

  bool get themeTransitionActive => _ticker.isActive;

  int get transitionId => _transitionId;
  Color get waveFrom => _waveFrom;
  Color get waveTo => _waveTo;
  Offset? get waveOrigin => _waveOrigin;
  double get waveMaxDist => _waveMaxDist;

  Strings get strings => _language == AppLanguage.ru ? Strings.ru : Strings.en;

  Palette get palette => Palette.lerp(Palette.light, Palette.dark, _themeT)!;

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  void setDark(bool? override, {Offset? origin, double maxDist = 0}) {
    _darkOverride = override;
    _animateThemeTo(dark, origin, maxDist);
  }

  void _animateThemeTo(bool target, Offset? origin, double maxDist) {
    _ticker.stop();
    _transitionId++;
    _transitionFromT = _themeT;
    _waveOrigin = origin;
    _waveMaxDist = maxDist;
    _waveFrom = palette.background;
    _waveTo = target ? Palette.dark.background : Palette.light.background;
    _animFrom = _themeT;
    _animTo = target ? 1.0 : 0.0;
    _progress = 0;

    if (_animFrom == _animTo) {
      notifyListeners();
      return;
    }
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final k = (elapsed.inMicroseconds / _transitionDuration.inMicroseconds).clamp(0.0, 1.0);
    _progress = Curves.easeOutCubic.transform(k);
    _themeT = lerpDouble(_animFrom, _animTo, Curves.easeInOutCubic.transform(k))!;
    if (k >= 1) {
      _themeT = _animTo;
      _progress = 1;
      _ticker.stop();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }
}
