# AGENTS.md

Guidance for AI agents working in this repository. Read this before changing
anything — it captures the non-obvious decisions that are easy to break.

## What this is

Personal bio/landing page of Fedor Kiriakov, built with **Flutter Web**
(dart2js + canvaskit renderer), deployed to <https://kiria-f.ru>.
There is **no Material** — the entire design system is custom
(`lib/components/`), state management is `provider`.

## Commands

| Command | Purpose |
|---|---|
| `flutter analyze` | linter; must stay clean |
| `flutter test` | widget tests, `test/smoke_test.dart` |
| `flutter build web --release` | production build into `build/web` |
| Deployment | automatic: push to `master` (see *Deployment*) |

## Architecture

- `lib/main.dart` — root: watches `AppState`, mirrors the palette into
  `Global` statics, builds the page **or** the narrow-window overlay.
- `lib/state/app_state.dart` — `ChangeNotifier`: language (ru/en), dark theme
  with an animated wave transition (`themeT` 0..1, `waveT` wave-front
  progress, `transitionId` used to invalidate per-surface caches).
- `lib/content.dart` — **all** user-visible texts live here
  (`Strings.ru` / `Strings.en`). Adding a field means adding it to the class
  and to **both** instances.
- `lib/components/` — the design system:
  - `FSurface` — the core surface (fill, outline, shadow, optional lift);
    everything else is built on top of it.
  - `FButton` / `FStateButton` — press animation driven by an elevation
    controller (resting 1 → pressed 0).
  - `FText` — text with a per-letter scramble animation on language switch.
  - `FIconBadge`, `FCard`, `FSectionTitle`, `FSmoothScroll`, `WavePainter`,
    `NarrowOverlay`.
- `lib/sections/` — page sections in order: Toggles, Head, About, Stack,
  Now, Footer.

## Non-obvious behaviors — do not break

- **Theme transition.** `WavePainter` paints a blurred circle growing from
  the press origin. Each `FSurface` plays its own copy of the progress with a
  cascade delay (distance from the wave origin + random jitter, see
  `_staggeredProgress`), so surfaces flip one after another. A surface can
  opt out with `stagger: false` — then it flips exactly while the wave front
  passes over it (used for the photo: its thin ring reads as abrupt when
  played inside a stagger window).
- **`FSurface.lift`** (default `false`) — the raised resting position. It is
  enabled **only** for `FButton` / `FStateButton`. Static surfaces (badges,
  cards, photo) must not move: they would misalign and jump during the theme
  animation.
- **Outlines.** Never put `border` into the back `BoxDecoration`:
  `Container` adds `Decoration.padding` (the border dimensions) to its
  padding, so in the dark theme content gets a ~1px inset and buttons drift
  during the theme animation. The outline is painted via
  `foregroundDecoration` with `StrokeAlign.outside` — zero layout impact.
- **`FText` scramble.** Every character has a random switch moment
  (`_switchAt`); `_compose` stitches the intermediate string from old/new
  characters. A mid-animation language flip restarts from the currently
  displayed mix. Texts whose data is identical across locales never animate.
- **Narrow window** (< `NarrowOverlay.minWidth` = 300): the page is **not
  built at all**; a localized vertical plate fades in instead
  (`AnimatedOpacity` + `IgnorePointer`).
- **Localization.** `Strings.ru` and `Strings.en` must always have identical
  field sets.

## Tests (`test/smoke_test.dart`)

- Texts are referenced via `Strings.ru.*` / `Strings.en.*` constants — do not
  hardcode them in tests.
- The scramble test depends on probability math (see the comments: 0.27^14,
  0.73^135) — do not "simplify" the thresholds, they are chosen to be flake-free.
- Theme-transition tests measure per-frame state: pump with explicit
  durations, do not insert `pumpAndSettle` mid-transition.
- A surface subtree contains **two** `DecoratedBox`es (fill + foreground
  outline). When asserting decoration colors, select the one with a
  non-null color.

## Web bootstrap & loader (`web/index.html`)

- Placeholders `{{flutter_js}}` and `{{flutter_build_config}}` are substituted
  by `flutter build web`.
- The custom bootstrap streams `main.dart.js` via `fetch` for honest
  progress, then hands it to the engine as a **blob URL**
  (`jsBuild.mainJsPath`) — the Flutter loader explicitly supports those.
- `canvasKitBaseUrl: 'canvaskit'` forces the local renderer build (served by
  our nginx with gzip) instead of the gstatic CDN default.
- `fetch`/XHR shims count received bytes for the progress bar and match them
  against `window.__BIO_SIZES__` (decoded byte sizes of the build files).
- The `__BIO_SIZES__` token is replaced by the deploy staging step with the
  real size map. A plain `flutter build web` output still works without it
  (fallback estimates kick in).
- Watchdog: if the blob entrypoint does not start the engine within 10 s, the
  page reloads with `?noblob=1`, which skips streaming. Arm that timer only
  inside `boot()` — canvaskit downloading slowly is not a failure.
- The loader hides on the `flutter-first-frame` event, with a
  `MutationObserver` fallback on the `flutter-view` element (+4 s grace).
- The Flutter engine **replaces** any `meta[name=viewport]` with its own on
  boot — keep ours in `index.html` for correct pre-boot mobile rendering.
- Old Flutter service workers are unregistered on load (deprecated upstream,
  they served stale bundles).

## Deployment (CI-driven)

Push to `master` runs `.github/workflows/build-and-deploy.yml`:

1. GitHub Actions builds the Docker image. **`tool/prepare_web.dart` runs
   inside the build** (`dart run tool/prepare_web.dart`): it injects the
   `window.__BIO_SIZES__` map into `build/web/index.html` and prunes unused
   renderer engines / `*.symbols`. The nginx stage copies
   `nginx/default.conf` (gzip for JS/WASM/fonts, long cache for
   `/canvaskit/`) — do not lose either, they are load-bearing.
2. The image is pushed to `ghcr.io/kiriakoff/bio:latest`.
3. `peter-evans/repository-dispatch` (secret `DEPLOY_TOKEN`, a fine-grained
   PAT with contents:write) triggers `repository_dispatch: Deploy role` in
   **kiriakoff/ansible-master**, whose `deploy.yml` runs the ansible `bio`
   role over SSH (`--limit fornex`): the host pulls the new image and
   recreates the container.

Manual fallback (no CI): `flutter build web --release`, then run
`tool/prepare_web.dart` (`dart run tool/prepare_web.dart`), then build the
image from the repo Dockerfile and push/deploy as above — the repo Dockerfile
already does both serving-critical steps, so prefer it over hand-rolled
staging.

## Gotchas

- `MediaQuery` is available without a `WidgetsApp` (sections already use
  `MediaQuery.sizeOf`).
- Fonts: declare only the weights actually used in `pubspec.yaml` — canvaskit
  downloads **all** fonts from `FontManifest` before the first frame.
- Headless verification (`msedge --headless=new --virtual-time-budget`) races
  the real network against a prod URL; verify boots against a local server
  (`build/web` + any static file server) instead.
- `Global.apply(palette)` mutates colors only — never add layout-affecting
  statics there.
