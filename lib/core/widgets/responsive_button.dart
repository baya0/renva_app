import 'package:flutter/material.dart';
import '../utils/responsive.dart';

enum ButtonSize { small, medium, large }

/// Responsive primary button
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (size) {
      case ButtonSize.small:
        height = r.buttonHeightSmall;
        fontSize = r.fontSize14;
        padding = EdgeInsets.symmetric(horizontal: r.space16);
        break;
      case ButtonSize.medium:
        height = r.buttonHeightMedium;
        fontSize = r.fontSize16;
        padding = EdgeInsets.symmetric(horizontal: r.space20);
        break;
      case ButtonSize.large:
        height = r.buttonHeightLarge;
        fontSize = r.fontSize18;
        padding = EdgeInsets.symmetric(horizontal: r.space24);
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius12),
          ),
          padding: padding,
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: fontSize,
                width: fontSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize, color: textColor),
                    SizedBox(width: r.space8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Responsive outlined button
class ResponsiveOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final Color? borderColor;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const ResponsiveOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.borderColor,
    this.textColor,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (size) {
      case ButtonSize.small:
        height = r.buttonHeightSmall;
        fontSize = r.fontSize14;
        padding = EdgeInsets.symmetric(horizontal: r.space16);
        break;
      case ButtonSize.medium:
        height = r.buttonHeightMedium;
        fontSize = r.fontSize16;
        padding = EdgeInsets.symmetric(horizontal: r.space20);
        break;
      case ButtonSize.large:
        height = r.buttonHeightLarge;
        fontSize = r.fontSize18;
        padding = EdgeInsets.symmetric(horizontal: r.space24);
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor ?? Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius12),
          ),
          padding: padding,
        ),
        child: isLoading
            ? SizedBox(
                height: fontSize,
                width: fontSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize, color: textColor),
                    SizedBox(width: r.space8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Responsive text button
class ResponsiveTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final Color? textColor;
  final IconData? icon;

  const ResponsiveTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    double fontSize;
    switch (size) {
      case ButtonSize.small:
        fontSize = r.fontSize14;
        break;
      case ButtonSize.medium:
        fontSize = r.fontSize16;
        break;
      case ButtonSize.large:
        fontSize = r.fontSize18;
        break;
    }

    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: textColor),
            SizedBox(width: r.space8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
