import 'package:flutter/material.dart';

import '../../gen/assets.gen.dart';

class SvgIcon extends StatelessWidget {
  final SvgGenImage icon;
  final Color? color;
  final double size;

  const SvgIcon({super.key, required this.icon, this.color, this.size = 23});

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? IconTheme.of(context).color!;
    return SizedBox(
      height: size,
      width: size,
      child: icon.svg(colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcATop)),
    );
  }
}
