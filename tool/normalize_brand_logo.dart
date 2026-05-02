import 'dart:io';

import 'package:image/image.dart' as img;

/// Produces a square, opaque launcher/splash asset so Android/iOS never stretch
/// a non-square PNG. Fills with #0A0A0A and scales the artwork uniformly.
void main(List<String> args) {
  const targetSize = 1024;
  /// Slightly inset so pyramid / wide marks survive circular Android 12 splash crop.
  const fillFraction = 0.80;

  final inputPath = args.isNotEmpty ? args[0] : 'assets/branding/_logo_source.png';
  final outputPath = args.length > 1 ? args[1] : 'assets/branding/app_logo.png';

  final bg = img.ColorRgb8(10, 10, 10);

  final bytes = File(inputPath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode image: $inputPath');
    exitCode = 1;
    return;
  }

  var src = decoded;

  if (src.width != src.height) {
    final side = src.width < src.height ? src.width : src.height;
    final x = (src.width - side) ~/ 2;
    final y = (src.height - side) ~/ 2;
    src = img.copyCrop(src, x: x, y: y, width: side, height: side);
  }

  final maxSide = (targetSize * fillFraction).round();
  final resized = img.copyResize(
    src,
    width: maxSide,
    height: maxSide,
    interpolation: img.Interpolation.average,
  );

  final canvas = img.Image(width: targetSize, height: targetSize);
  img.fill(canvas, color: bg);

  final ox = (targetSize - resized.width) ~/ 2;
  final oy = (targetSize - resized.height) ~/ 2;
  img.compositeImage(canvas, resized, dstX: ox, dstY: oy);

  File(outputPath).writeAsBytesSync(img.encodePng(canvas, level: 9));
  stdout.writeln('Wrote $outputPath (${canvas.width}x${canvas.height})');
}
