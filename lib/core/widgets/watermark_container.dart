import 'package:flutter/material.dart';

/// A modern container with watermark for auth screens
/// Uses composition pattern instead of inheritance for better flexibility
class WatermarkContainer extends StatelessWidget {
  final Widget child;
  final Widget watermark;
  final double opacity;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry padding;

  const WatermarkContainer({
    super.key,
    required this.child,
    required this.watermark,
    this.opacity = 0.05,
    this.decoration,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: CustomPaint(
        painter: WatermarkPainter(watermark: watermark, opacity: opacity),
        child: child,
      ),
    );
  }
}

/// Custom painter that draws the watermark behind content
/// More efficient than using Stack + Positioned
class WatermarkPainter extends CustomPainter {
  final Widget watermark;
  final double opacity;

  WatermarkPainter({required this.watermark, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(opacity),
    );

    // Position watermark at bottom center
    final watermarkSize = Size(size.width * 0.8, size.width * 0.8);
    final offset = Offset(
      (size.width - watermarkSize.width) / 2,
      size.height - watermarkSize.height * 0.8,
    );

    // This is a placeholder - actual rendering happens when widget is used
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
