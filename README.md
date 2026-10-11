# bio

Personal landing page of [Fedor Kiriakov](https://github.com/kiriakoff) —
SRE, automating things at [T-Bank](https://www.tbank.ru).

**Live:** [kiria-f.ru](https://kiria-f.ru)

## Under the hood

Flutter Web (dart2js + canvaskit) with a fully custom design system — no
Material. A few things worth a look:

- **Wave theme transition** — a blurred circle sweeps the new palette over
  the page from the toggle you pressed; surfaces cascade in a stagger.
- **Language switching** — RU/EN content morphs letter-by-letter in a random
  order, and the loader is a custom bootstrap with real byte-based progress
  (streamed entrypoint, local canvaskit, gzip).
- **Dark/light aware** everything: loader, plates, surfaces, shadows.

## Development

```sh
flutter analyze          # linter
flutter test             # widget tests
flutter build web --release
```

Architecture, deployment pipeline and the fine print live in
[AGENTS.md](AGENTS.md).
