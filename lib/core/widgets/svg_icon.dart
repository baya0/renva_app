import 'package:flutter/material.dart';
import '../../gen/assets.gen.dart';

class SvgIcon extends StatelessWidget {
  final SvgGenImage icon;
  final Color? color;
  final double? size;
  final double? width;
  final double? height;

  const SvgIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? IconTheme.of(context).color!;

    final double effectiveWidth = width ?? size ?? 24;
    final double effectiveHeight = height ?? size ?? 24;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: icon.svg(
        colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcATop),
      ),
    );
  }
}
