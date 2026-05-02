import 'package:flutter/material.dart';

/// Single source for the app mark: same asset as launcher + native splash.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 50,
    this.borderRadius = 14,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/branding/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );

    if (borderRadius <= 0) {
      return image;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}
