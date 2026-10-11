import 'package:bio/components/global.dart';
import 'package:bio/components/section.dart';
import 'package:bio/components/state_button.dart';
import 'package:bio/main.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<AppState> pumpApp(WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    return appState;
  }

  testWidgets('landing renders without errors', (tester) async {
    await pumpApp(tester);

    expect(find.text('Фёдор Кирьяков'), findsOneWidget);
    expect(find.text('О себе'), findsOneWidget);
    expect(find.text('Стек'), findsOneWidget);
    expect(find.text('Сейчас'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('RU'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
  });

  testWidgets('language toggle switches content to EN', (tester) async {
    final appState = await pumpApp(tester);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(appState.language, AppLanguage.en);
    expect(find.text('Fedor Kiryakov'), findsOneWidget);
    expect(find.text('About me'), findsOneWidget);
    expect(find.text('Stack'), findsOneWidget);
    expect(find.text('Currently'), findsOneWidget);
    expect(find.text('Фёдор Кирьяков'), findsNothing);
  });

  testWidgets('theme toggle switches palette', (tester) async {
    final appState = await pumpApp(tester);

    expect(appState.dark, isFalse);
    expect(appState.themeT, 0.0);

    final moonButton = find.byWidgetPredicate(
      (widget) => widget is FStateButton && widget.icon == 'assets/icons/moon.svg',
    );
    expect(moonButton, findsOneWidget);

    await tester.tap(moonButton);
    await tester.pump(); // первый кадр: тикер стартует с elapsed = 0
    await tester.pump(const Duration(milliseconds: 150)); // прогресс анимации

    expect(appState.themeTransitionActive, isTrue);
    expect(appState.themeT, greaterThan(0.0));
    expect(appState.themeT, lessThan(1.0));

    await tester.pumpAndSettle();

    expect(appState.dark, isTrue);
    expect(appState.themeT, 1.0);
    expect(appState.themeTransitionActive, isFalse);
    expect(appState.waveT, 1.0);
  });

  testWidgets('dark to light transition has no flash frames', (tester) async {
    final appState = await pumpApp(tester);
    final moonButton = find.byWidgetPredicate(
      (widget) => widget is FStateButton && widget.icon == 'assets/icons/moon.svg',
    );

    await tester.tap(moonButton);
    await tester.pumpAndSettle();

    appState.setDark(false, origin: const Offset(400, 100), maxDist: 1500);
    await tester.pump(); // первый кадр перехода: elapsed = 0

    // Фон не должен мигнуть светлым: прогресс волны 0, круга нет, база — тёмная.
    expect(appState.waveT, 0.0);
    expect(appState.waveFrom, appState.palette.background);
    expect(appState.waveTo, isNot(appState.waveFrom));

    await tester.pump(const Duration(milliseconds: 250));
    expect(appState.waveT, greaterThan(0.0));
    expect(appState.waveT, lessThan(1.0));

    await tester.pumpAndSettle();
    expect(appState.dark, isFalse);
    expect(appState.waveT, 1.0);
  });

  testWidgets('surfaces stay dark when dark to light transition starts', (tester) async {
    final appState = await pumpApp(tester);
    final moonButton = find.byWidgetPredicate(
      (widget) => widget is FStateButton && widget.icon == 'assets/icons/moon.svg',
    );

    await tester.tap(moonButton);
    await tester.pumpAndSettle();
    expect(appState.dark, isTrue);

    appState.setDark(false, origin: const Offset(400, 100), maxDist: 4000);
    await tester.pump(); // первый кадр перехода: прогресс 0

    final cardDecoration = find
        .descendant(of: find.byType(FCard), matching: find.byType(DecoratedBox))
        .first;

    // Поверхность не должна щёлкаться в светлую на старте перехода.
    final decorationAtStart = tester.widget<DecoratedBox>(cardDecoration).decoration
        as BoxDecoration;
    expect(decorationAtStart.color, Palette.dark.background);

    await tester.pumpAndSettle();
    expect(appState.dark, isFalse);
    expect(appState.themeT, 0.0);

    // По окончании перехода поверхность обязана быть светлой, а не застрять в тёмной.
    final decorationAtEnd = tester.widget<DecoratedBox>(cardDecoration).decoration
        as BoxDecoration;
    expect(decorationAtEnd.color, Palette.light.background);
  });

  testWidgets('wheel scroll glues animations together', (tester) async {
    await pumpApp(tester);

    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(find.byType(SingleChildScrollView))));
    await tester.pump();

    ScrollableState scrollable() => tester.state<ScrollableState>(find.byType(Scrollable));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 300)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final midFlight = scrollable().position.pixels;

    // Второй тик в процессе анимации: не рвёт её, а продолжает движение.
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 300)));
    await tester.pump(const Duration(milliseconds: 60));
    final glued = scrollable().position.pixels;

    expect(midFlight, greaterThan(0));
    expect(glued, greaterThan(midFlight));

    await tester.pumpAndSettle();
    expect(scrollable().position.pixels, closeTo(600, 1));
  });

  testWidgets('button finishes falling before releasing on focus loss', (tester) async {
    await pumpApp(tester);

    final github = find.text('GitHub');
    Transform buttonTransform() =>
        tester.widget<Transform>(find.ancestor(of: github, matching: find.byType(Transform)).first);

    final gesture = await tester.startGesture(tester.getCenter(github));
    await tester.pump(); // холостой кадр: тикер падения стартует с elapsed = 0
    await tester.pump(const Duration(milliseconds: 20)); // кнопка в середине падения

    final midFallOffset = buttonTransform().transform.getTranslation().y;
    expect(midFallOffset, greaterThan(-3.0));
    expect(midFallOffset, lessThan(0.0));

    // Теряем фокус окна в момент падения.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 15));

    // Кнопка продолжает падать (значение растёт к 0 — прижатому), а не отскакивает.
    final stillFallingOffset = buttonTransform().transform.getTranslation().y;
    expect(stillFallingOffset, greaterThan(midFallOffset));

    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    // Итог: доиграла падение и полностью вернулась в исходное положение.
    expect(buttonTransform().transform.getTranslation().y, -3.0);
  });

  testWidgets('selected state button ignores repeated taps', (tester) async {
    final appState = await pumpApp(tester);
    final moonButton = find.byWidgetPredicate(
      (widget) => widget is FStateButton && widget.icon == 'assets/icons/moon.svg',
    );

    await tester.tap(moonButton);
    await tester.pumpAndSettle();
    expect(appState.dark, isTrue);

    final transitionIdAfterFirstToggle = appState.transitionId;

    // Повторный тап по уже выбранной кнопке не должен перезапускать волну.
    await tester.tap(moonButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(appState.transitionId, transitionIdAfterFirstToggle);
    expect(appState.themeTransitionActive, isFalse);
  });
}
