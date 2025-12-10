import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// Provides adaptive spacing, sizing, and layout helpers
class Responsive {
  final BuildContext context;

  Responsive(this.context);

  // Screen dimensions
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  // Device type checks
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  // Screen size categories
  bool get isSmallMobile => width < 360;
  bool get isMediumMobile => width >= 360 && width < 400;
  bool get isLargeMobile => width >= 400 && width < 600;

  // Responsive value getters
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // Percentage-based sizing
  double wp(double percentage) => width * percentage / 100;
  double hp(double percentage) => height * percentage / 100;

  // Responsive font sizes
  double get fontSize10 => value(mobile: 10, tablet: 11, desktop: 12);
  double get fontSize11 => value(mobile: 10, tablet: 12, desktop: 13);
  double get fontSize12 => value(mobile: 12, tablet: 13, desktop: 14);
  double get fontSize14 => value(mobile: 14, tablet: 15, desktop: 16);
  double get fontSize16 => value(mobile: 16, tablet: 17, desktop: 18);
  double get fontSize18 => value(mobile: 18, tablet: 19, desktop: 20);
  double get fontSize20 => value(mobile: 20, tablet: 22, desktop: 24);
  double get fontSize24 => value(mobile: 24, tablet: 26, desktop: 28);
  double get fontSize28 => value(mobile: 28, tablet: 30, desktop: 32);

  // Responsive spacing
  double get space4 => value(mobile: 4, tablet: 5, desktop: 6);
  double get space8 => value(mobile: 8, tablet: 9, desktop: 10);
  double get space12 => value(mobile: 12, tablet: 13, desktop: 14);
  double get space16 => value(mobile: 16, tablet: 18, desktop: 20);
  double get space20 => value(mobile: 20, tablet: 22, desktop: 24);
  double get space24 => value(mobile: 24, tablet: 26, desktop: 28);
  double get space32 => value(mobile: 32, tablet: 36, desktop: 40);
  double get space48 => value(mobile: 48, tablet: 52, desktop: 56);
  double get space64 => value(mobile: 52, tablet: 64, desktop: 84);

  // Responsive icon sizes
  double get iconSize16 => value(mobile: 16, tablet: 18, desktop: 20);
  double get iconSize14 => value(mobile: 14, tablet: 16, desktop: 18);
  double get iconSize20 => value(mobile: 20, tablet: 22, desktop: 24);
  double get iconSize24 => value(mobile: 24, tablet: 26, desktop: 28);
  double get iconSize32 => value(mobile: 32, tablet: 36, desktop: 40);
  double get iconSize48 => value(mobile: 48, tablet: 52, desktop: 56);

  // Responsive border radius
  double get radius8 => value(mobile: 8, tablet: 9, desktop: 10);
  double get radius12 => value(mobile: 12, tablet: 13, desktop: 14);
  double get radius16 => value(mobile: 16, tablet: 18, desktop: 20);
  double get radius20 => value(mobile: 20, tablet: 22, desktop: 24);
  double get radius24 => value(mobile: 24, tablet: 26, desktop: 28);

  // Responsive button heights
  double get buttonHeightSmall => value(mobile: 40, tablet: 44, desktop: 48);
  double get buttonHeightMedium => value(mobile: 48, tablet: 52, desktop: 56);
  double get buttonHeightLarge => value(mobile: 56, tablet: 60, desktop: 64);

  // Responsive container constraints
  double get maxContentWidth => value(mobile: width, tablet: 600, desktop: 800);

  // Grid columns
  int get gridColumns => value(mobile: 2, tablet: 3, desktop: 4);

  // Adaptive padding
  EdgeInsets get screenPadding => EdgeInsets.all(value(mobile: 16, tablet: 20, desktop: 24));
  EdgeInsets get cardPadding => EdgeInsets.all(value(mobile: 12, tablet: 14, desktop: 16));
  EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: value(mobile: 16, tablet: 20, desktop: 24));
}

/// Extension on BuildContext for easy access to Responsive utilities
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);

  // Quick access shortcuts
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}

/// Responsive text styles helper
class ResponsiveTextStyles {
  final BuildContext context;
  late final Responsive _r;

  ResponsiveTextStyles(this.context) {
    _r = Responsive(context);
  }

  TextStyle get h1 => TextStyle(fontSize: _r.fontSize28, fontWeight: FontWeight.bold);

  TextStyle get h2 => TextStyle(fontSize: _r.fontSize24, fontWeight: FontWeight.bold);

  TextStyle get h3 => TextStyle(fontSize: _r.fontSize20, fontWeight: FontWeight.w600);

  TextStyle get bodyLarge => TextStyle(fontSize: _r.fontSize16, fontWeight: FontWeight.normal);

  TextStyle get bodyMedium => TextStyle(fontSize: _r.fontSize14, fontWeight: FontWeight.normal);

  TextStyle get bodySmall => TextStyle(fontSize: _r.fontSize12, fontWeight: FontWeight.normal);

  TextStyle get caption => TextStyle(fontSize: _r.fontSize10, fontWeight: FontWeight.normal);
}

/// Extension for responsive text styles
extension TextStyleExtension on BuildContext {
  ResponsiveTextStyles get textStyles => ResponsiveTextStyles(this);
}

/// Responsive sized box helpers
class RSizedBox {
  static SizedBox h(BuildContext context, double height) {
    return SizedBox(
      height: Responsive(
        context,
      ).value(mobile: height, tablet: height * 1.1, desktop: height * 1.2),
    );
  }

  static SizedBox w(BuildContext context, double width) {
    return SizedBox(
      width: Responsive(context).value(mobile: width, tablet: width * 1.1, desktop: width * 1.2),
    );
  }
}
