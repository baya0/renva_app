import 'package:flutter/material.dart';

/// A modern background container with watermark for auth screens
/// Uses composition pattern for better flexibility and performance
class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final Widget? watermark;
  final double watermarkOpacity;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry padding;
  final bool showWatermark;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.watermark,
    this.watermarkOpacity = 0.05,
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.showWatermark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: Column(
        children: [
          // Main content takes all available space
          Expanded(child: child),

          // Watermark at the bottom if enabled
          if (showWatermark && watermark != null)
            Opacity(
              opacity: watermarkOpacity,
              child: SizedBox(height: 200, width: 200, child: watermark!),
            ),
        ],
      ),
    );
  }
}
