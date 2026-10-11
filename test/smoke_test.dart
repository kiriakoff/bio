import 'package:bio/components/global.dart';
import 'package:bio/components/narrow_overlay.dart';
import 'package:bio/components/section.dart';
import 'package:bio/components/state_button.dart';
import 'package:bio/components/surface.dart';
import 'package:bio/content.dart';
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
    // 'RU'/'EN' appear both in the toggles and in the language stack —
    // target the toggle specifically.
    expect(find.widgetWithText(FStateButton, 'RU'), findsOneWidget);
    expect(find.widgetWithText(FStateButton, 'EN'), findsOneWidget);
  });

  testWidgets('language toggle switches content to EN', (tester) async {
    final appState = await pumpApp(tester);

    await tester.tap(find.widgetWithText(FStateButton, 'EN'));
    await tester.pumpAndSettle();

    expect(appState.language, AppLanguage.en);
    expect(find.text('Fedor Kiriakov'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Stack'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
    expect(find.text('Фёдор Кирьяков'), findsNothing);
  });

  testWidgets('language switch scrambles text letter by letter', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(FStateButton, 'EN'));
    await tester.pump(); // throwaway frame: the animation starts with elapsed = 0
    // 80ms out of 800: easeOutCubic yields ~0.27 progress, so each character
    // has a 27% chance of having flipped already. The name (14 characters)
    // cannot have fully assembled into EN (0.27^14 ~ 1e-8)...
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Fedor Kiriakov'), findsNothing);
    // ...while the long RU paragraph is guaranteed to be touched already:
    // the chance of all ~135 characters staying in place is negligible
    // (0.73^135).
    expect(find.text(Strings.ru.aboutItems[0]), findsNothing);

    await tester.pumpAndSettle();

    // By the end of the animation all the text has settled into EN.
    expect(find.text('Fedor Kiriakov'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('narrow window overlay covers page and localizes', (tester) async {
    final appState = AppState();
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(280 * 3, 700 * 3); // narrow window
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    AnimatedOpacity overlayOpacity() => tester.widget<AnimatedOpacity>(find.descendant(of: find.byType(NarrowOverlay), matching: find.byType(AnimatedOpacity)));

    expect(find.text('Сделай пошире'), findsOneWidget);
    expect(overlayOpacity().opacity, 1);
    // The page is not built at all in narrow mode — "instead of", not
    // "on top of".
    expect(find.text('Фёдор Кирьяков'), findsNothing);

    // Widened the window — the plate has fully faded out.
    tester.view.physicalSize = const Size(900 * 3, 700 * 3);
    await tester.pumpAndSettle();
    expect(overlayOpacity().opacity, 0);

    // Narrow again plus a language switch — the message got localized.
    tester.view.physicalSize = const Size(280 * 3, 700 * 3);
    appState.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Make it wider'), findsOneWidget);
    expect(overlayOpacity().opacity, 1);
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
    await tester.pump(); // first frame: the ticker starts with elapsed = 0
    await tester.pump(const Duration(milliseconds: 150)); // animation in progress

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
    await tester.pump(); // first frame of the transition: elapsed = 0

    // The background must not flash light: wave progress 0, no circle yet,
    // the base fill is dark.
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
    await tester.pump(); // first frame of the transition: progress 0

    // Pick the box with the fill specifically: a surface now also contains
    // a foreground box carrying the outline (that one has no color).
    final cardDecoration = find
        .descendant(
          of: find.byType(FCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is DecoratedBox && (widget.decoration as BoxDecoration).color != null,
          ),
        )
        .first;

    // The surface must not snap to light at the very start of the transition.
    final decorationAtStart = tester.widget<DecoratedBox>(cardDecoration).decoration as BoxDecoration;
    expect(decorationAtStart.color, Palette.dark.background);

    await tester.pumpAndSettle();
    expect(appState.dark, isFalse);
    expect(appState.themeT, 0.0);

    // Once the transition is over the surface must be light, not stuck dark.
    final decorationAtEnd = tester.widget<DecoratedBox>(cardDecoration).decoration as BoxDecoration;
    expect(decorationAtEnd.color, Palette.light.background);
  });

  testWidgets('surface border does not shift content between themes', (tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: FSurface(
          width: 60,
          height: 30,
          child: SizedBox(key: const Key('probe'), width: 10, height: 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Offset probeOffset() => tester.getTopLeft(find.byKey(const Key('probe'))) - tester.getTopLeft(find.byType(FSurface));

    // The light theme has no outline — the child sits flush with the
    // surface corner.
    expect(probeOffset(), Offset.zero);

    // The dark theme adds a 0.9px outline, but it must stay out of layout:
    // the content has to remain in exactly the same spot.
    appState.setDark(true);
    await tester.pumpAndSettle();
    expect(probeOffset(), Offset.zero);
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

    // A second tick mid-animation: it does not tear the animation down,
    // it continues the motion.
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
    Transform buttonTransform() => tester.widget<Transform>(find.ancestor(of: github, matching: find.byType(Transform)).first);

    final gesture = await tester.startGesture(tester.getCenter(github));
    await tester.pump(); // throwaway frame: the fall ticker starts with elapsed = 0
    await tester.pump(const Duration(milliseconds: 20)); // button mid-fall

    final midFallOffset = buttonTransform().transform.getTranslation().y;
    expect(midFallOffset, greaterThan(-3.0));
    expect(midFallOffset, lessThan(0.0));

    // The window loses focus mid-fall.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 15));

    // The button keeps falling (the value grows toward 0, the pressed
    // state) instead of bouncing back.
    final stillFallingOffset = buttonTransform().transform.getTranslation().y;
    expect(stillFallingOffset, greaterThan(midFallOffset));

    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    // Outcome: it finished the fall and returned fully to its resting spot.
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

    // Tapping an already selected button again must not restart the wave.
    await tester.tap(moonButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(appState.transitionId, transitionIdAfterFirstToggle);
    expect(appState.themeTransitionActive, isFalse);
  });
}
