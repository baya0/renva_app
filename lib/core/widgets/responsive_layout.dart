import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// A responsive container that centers content on larger screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final Color? color;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      color: color,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? r.maxContentWidth),
          padding: padding ?? r.screenPadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid view that adapts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GridView.count(
      crossAxisCount: r.gridColumns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: childAspectRatio ?? 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive row that converts to column on small screens
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool forceColumn;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8,
    this.forceColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile || forceColumn;

    if (isMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, true),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, spacing, false),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing, bool isColumn) {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          isColumn ? SizedBox(height: spacing) : SizedBox(width: spacing),
        );
      }
    }
    return spacedChildren;
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    EdgeInsets padding;
    if (all != null) {
      padding = EdgeInsets.all(r.value(mobile: all!, tablet: all! * 1.1, desktop: all! * 1.2));
    } else {
      padding = EdgeInsets.only(
        top: top != null ? r.value(mobile: top!, tablet: top! * 1.1, desktop: top! * 1.2) : 0,
        bottom:
            bottom != null ? r.value(mobile: bottom!, tablet: bottom! * 1.1, desktop: bottom! * 1.2) : 0,
        left: left != null ? r.value(mobile: left!, tablet: left! * 1.1, desktop: left! * 1.2) : 0,
        right:
            right != null ? r.value(mobile: right!, tablet: right! * 1.1, desktop: right! * 1.2) : 0,
      );

      if (horizontal != null) {
        padding = padding.copyWith(
          left: r.value(mobile: horizontal!, tablet: horizontal! * 1.1, desktop: horizontal! * 1.2),
          right:
              r.value(mobile: horizontal!, tablet: horizontal! * 1.1, desktop: horizontal! * 1.2),
        );
      }

      if (vertical != null) {
        padding = padding.copyWith(
          top: r.value(mobile: vertical!, tablet: vertical! * 1.1, desktop: vertical! * 1.2),
          bottom: r.value(mobile: vertical!, tablet: vertical! * 1.1, desktop: vertical! * 1.2),
        );
      }
    }

    return Padding(padding: padding, child: child);
  }
}

/// Responsive card with adaptive padding and border radius
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(r.radius12),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation!,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: r.cardPadding,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}
