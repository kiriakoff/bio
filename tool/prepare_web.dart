import 'dart:convert';
import 'dart:io';

/// Prepares `build/web` for serving. Run after `flutter build web`:
///
///  1. Injects `window.__BIO_SIZES__` (decoded byte sizes of the build files)
///     into index.html — the web loader needs this map to turn downloaded
///     bytes into an honest progress percentage.
///  2. Prunes renderer engines and symbol maps that a dart2js build never
///     downloads, keeping the image small.
void main() {
  const root = 'build/web';
  if (!Directory(root).existsSync()) {
    stderr.writeln('$root not found — run `flutter build web` first');
    exitCode = 1;
    return;
  }

  // --- 1. Size map ---------------------------------------------------------
  // Keys must be suffixes of the runtime URLs (the loader matches them with
  // endsWith). Only files that a dart2js/canvaskit build actually downloads.
  final sizes = <String, int>{};
  void add(String relativePath) {
    final file = File('$root/$relativePath');
    if (file.existsSync()) sizes[relativePath] = file.lengthSync();
  }

  add('main.dart.js');
  add('assets/FontManifest.json');
  add('assets/AssetManifest.bin');
  add('assets/AssetManifest.bin.json');
  for (final dir in ['canvaskit', 'canvaskit/chromium']) {
    final engine = Directory('$root/$dir');
    if (!engine.existsSync()) continue;
    for (final entry in engine.listSync()) {
      if (entry is! File) continue;
      if (!entry.path.endsWith('.js') && !entry.path.endsWith('.wasm')) continue;
      final key = entry.path.replaceAll('\\', '/').replaceFirst('$root/', '');
      sizes[key] = entry.lengthSync();
    }
  }
  for (final dir in ['assets/assets/fonts', 'assets/assets/images']) {
    final assets = Directory('$root/$dir');
    if (!assets.existsSync()) continue;
    for (final entry in assets.listSync()) {
      if (entry is! File) continue;
      if (!entry.path.endsWith('.ttf') && !entry.path.endsWith('.png')) continue;
      final key = entry.path.replaceAll('\\', '/').replaceFirst('$root/', '');
      sizes[key] = entry.lengthSync();
    }
  }

  const token = '<script>/*__BIO_SIZES__*/</script>';
  final index = File('$root/index.html');
  final html = index.readAsStringSync();
  if (!html.contains(token)) {
    stderr.writeln('sizes token not found in index.html');
    exitCode = 1;
    return;
  }
  final json = const JsonEncoder.withIndent(' ').convert(sizes);
  index.writeAsStringSync(
    html.replaceFirst(token, '<script>window.__BIO_SIZES__ = $json;</script>'),
  );
  stdout.writeln('injected size map with ${sizes.length} files');

  // --- 2. Prune ------------------------------------------------------------
  // The dart2js build only ever loads canvaskit + canvaskit/chromium; skwasm,
  // wimp and webparagraph engines belong to dart2wasm builds, .symbols files
  // are for devtools stack traces.
  for (final name in ['skwasm', 'skwasm_heavy', 'wimp', 'webparagraph']) {
    final engine = Directory('$root/canvaskit/$name');
    if (engine.existsSync()) engine.deleteSync(recursive: true);
  }
  for (final entry in Directory(root).listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('.symbols')) entry.deleteSync();
  }
}
