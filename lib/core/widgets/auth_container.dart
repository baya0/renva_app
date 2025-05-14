import 'package:flutter/material.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/core/style/style.dart';
import 'package:renva0/gen/assets.gen.dart';

/// A modern container for authentication screens
/// Uses composition pattern and follows Flutter 2025 best practices
class AuthContainer extends StatelessWidget {
  final Widget child;
  final bool showWatermark;
  final Widget? headerContent;
  final EdgeInsetsGeometry contentPadding;
  final ScrollPhysics? scrollPhysics;

  const AuthContainer({
    super.key,
    required this.child,
    this.showWatermark = true,
    this.headerContent,
    this.contentPadding = const EdgeInsets.all(20),
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppStyle.roundedTopContainer,
      child: SingleChildScrollView(
        physics: scrollPhysics,
        padding: contentPadding,
        child: Column(
          children: [
            // Optional header content
            if (headerContent != null) headerContent!,

            // Main content
            child,

            if (showWatermark)
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Opacity(
                  opacity: 0.05,
                  child: Assets.images.logo.logo.svg(
                    width: 300,
                    height: 300,
                    color: StyleRepo.deepBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
