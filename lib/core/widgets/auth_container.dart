// AuthContainer with expanding white area and subtle watermark

import 'package:flutter/material.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/gen/assets.gen.dart';

class AuthContainer extends StatelessWidget {
  final Widget child;
  final bool showWatermark;
  final double watermarkOpacity;
  final Color watermarkColor;
  final EdgeInsetsGeometry contentPadding;
  final bool addScrolling;

  const AuthContainer({
    super.key,
    required this.child,
    this.showWatermark = true,
    this.watermarkOpacity = 0.05,
    this.watermarkColor = StyleRepo.deepBlue,
    this.contentPadding = const EdgeInsets.all(20),
    this.addScrolling = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Main content widget
        Widget contentWidget = child;

        // Add scrolling with physics that allows the container to expand/move up
        if (addScrolling) {
          contentWidget = SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Allows nice bouncing effect :D
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - contentPadding.vertical,
              ),
              child: contentWidget,
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, -5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Stack(
              children: [
                // Watermark layer - very subtle and positioned carefully
                if (showWatermark)
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: watermarkOpacity,
                        child: Center(
                          child: Transform.rotate(
                            angle: 30,
                            child: Assets.images.logo.logo.svg(
                              width: 400,
                              height: 400,
                              color: watermarkColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Content layer with padding
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: contentPadding,
                  child: contentWidget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
