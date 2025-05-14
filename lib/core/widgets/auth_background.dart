import 'package:flutter/material.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/gen/assets.gen.dart';

/// A modern background container for authentication screens
/// Uses composition pattern for better maintainability and performance
class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool showWatermark;
  final Color watermarkColor;
  final double watermarkOpacity;

  const AuthBackground({
    super.key,
    required this.child,
    this.showWatermark = true,
    this.watermarkColor = StyleRepo.deepBlue,
    this.watermarkOpacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
        ),
      ),
      child: Column(
        children: [
          // Main content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content
                  child,

                  // Watermark at the bottom
                  if (showWatermark)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Opacity(
                          opacity: watermarkOpacity,
                          child: Assets.images.logo.logo.svg(
                            width: 300,
                            height: 300,
                            color: watermarkColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
