import 'package:flutter/material.dart';
import 'package:renva0/core/style/repo.dart';

class AppStyle {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: StyleRepo.deepBlue,
      scaffoldBackgroundColor: StyleRepo.softWhite,
      colorScheme: ColorScheme.light(
        primary: StyleRepo.deepBlue,
        secondary: StyleRepo.forestGreen,
        surface: StyleRepo.softWhite,
        error: Colors.red,
      ),

      // Text themes
      textTheme: TextTheme(
        // Button text
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: StyleRepo.softWhite,
        ),

        titleMedium: TextStyle(fontSize: 20, color: StyleRepo.black),

        // Page titles
        headlineSmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: StyleRepo.black,
        ),
        // Subtitles & fields name
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: StyleRepo.black,
        ),

        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: StyleRepo.softWhite,
        ),
        //text inside field
        labelSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: StyleRepo.grey,
        ),

        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: StyleRepo.grey,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: StyleRepo.grey.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StyleRepo.deepBlue),
        ),
        filled: true,
        fillColor: StyleRepo.softWhite,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        // For SVG icons in prefix
        prefixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 48),
        prefixStyle: const TextStyle(color: StyleRepo.grey),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StyleRepo.deepBlue,
          foregroundColor: StyleRepo.softWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Container decorations
      cardTheme: CardTheme(
        color: StyleRepo.softWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: StyleRepo.forestGreen);
          }
          return const IconThemeData(color: StyleRepo.softGreen);
        }),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: StyleRepo.deepBlue,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: StyleRepo.softWhite),
        titleTextStyle: TextStyle(
          color: StyleRepo.softWhite,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Helper methods for common UI elements

  // Standard rounded container decoration
  static BoxDecoration get roundedTopContainer => const BoxDecoration(
    color: StyleRepo.softWhite,
    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
  );

  // Standard padding for content
  static const EdgeInsets contentPadding = EdgeInsets.all(20);

  // Standard vertical spacing between form elements
  static const double formSpacing = 20;

  // Standard small spacing
  static const double smallSpacing = 8;

  // Custom input decoration factory with vertical divider
  static InputDecoration inputDecorationWithIcon({
    required IconData icon,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Stack(
        alignment: Alignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Icon(icon, color: StyleRepo.grey)),
          // Vertical divider line
          Positioned(
            right: 0,
            top: 8,
            bottom: 8,
            child: Container(width: 1, color: Colors.grey.shade300),
          ),
        ],
      ),
      suffixIcon: suffixIcon,
    );
  }

  // Asset icon input decoration factory with vertical divider
  static InputDecoration inputDecorationWithAssetIcon({
    required Widget iconWidget,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Stack(
        alignment: Alignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(12), child: iconWidget),
          // Vertical divider line
          Positioned(
            right: 0,
            top: 8,
            bottom: 8,
            child: Container(width: 1, color: Colors.grey.shade300),
          ),
        ],
      ),
      suffixIcon: suffixIcon,
    );
  }

  // Modern container with SVG watermark
  static Widget containerWithSvgWatermark({
    required Widget child,
    required Widget svgLogo,
    double opacity = 0.05,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    BoxDecoration? decoration,
  }) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Content
          child,

          // Watermark at the bottom
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Opacity(opacity: opacity, child: svgLogo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
