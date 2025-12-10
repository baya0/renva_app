import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:renva0/core/style/style.dart';
import 'package:renva0/core/utils/responsive.dart';

import '../../../gen/assets.gen.dart';
import '../models/service_categories.dart';

class ServiceCard extends StatelessWidget {
  final ServiceCategoryModel service;
  final double? width;
  final double? height;
  final EdgeInsets? margin;

  const ServiceCard({
    super.key,
    required this.service,
    this.width = 140,
    this.height = 110,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.8, sigmaY: 25.8),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppStyle.theme.colorScheme.surface.withValues(alpha: 0.15),
                AppStyle.theme.colorScheme.surface,
                AppStyle.theme.colorScheme.surface,
                AppStyle.theme.colorScheme.surface.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(r.radius16),
            color: AppStyle.theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: EdgeInsets.all(r.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon section
                SizedBox(
                  height: r.iconSize48,
                  child: Align(alignment: Alignment.topCenter, child: _buildServiceIcon(context)),
                ),

                // Text section
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          service.title,
                          style: TextStyle(
                            fontSize: r.fontSize12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: r.space4),
                      Text(
                        _buildSubtitleText(),
                        style: TextStyle(fontSize: r.fontSize10, color: Colors.grey[400]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build subtitle with  API data
  String _buildSubtitleText() {
    final subtitle = service.subtitle;
    return subtitle;
  }

  //  Service icon with  SVG handling and fallbacks
  Widget _buildServiceIcon(BuildContext context) {
    final r = context.responsive;

    // Try to use SVG from API first
    if (service.svg.isNotEmpty && service.svg.trim().isNotEmpty) {
      return _buildSvgFromApi(context);
    }

    // Fallback to asset icons or Material icons
    return _buildAssetIcon(context) ?? _buildFallbackIcon(context);
  }

  // Render SVG from API response
  Widget _buildSvgFromApi(BuildContext context) {
    final r = context.responsive;

    try {
      return Center(
        child: SizedBox(
          width: r.iconSize32,
          height: r.iconSize32,
          child: ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    AppStyle.theme.colorScheme.surface,
                    AppStyle.theme.colorScheme.surface.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: SvgPicture.string(
              service.svg,
              placeholderBuilder: (ctx) => _buildFallbackIcon(context),
            ),
          ),
        ),
      );
    } catch (e) {
      print(' Error rendering SVG from API: $e');
      return _buildFallbackIcon(context);
    }
  }

  // Try to match asset icons
  Widget? _buildAssetIcon(BuildContext context) {
    final r = context.responsive;

    try {
      final titleLower = service.title.toLowerCase();

      if (titleLower.contains('clean')) {
        return Assets.icons.services.house.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('car')) {
        return Assets.icons.services.truck.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('house')) {
        return Assets.icons.services.house.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('professional')) {
        return Assets.icons.services.wrench.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('personal')) {
        return Assets.icons.services.certificate.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('logistical')) {
        return Assets.icons.services.truck.svg(
          width: r.iconSize32,
          height: r.iconSize32,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      }

      return null;
    } catch (e) {
      print(' Error loading asset icon: $e');
      return null;
    }
  }

  // Fallback Material icon
  Widget _buildFallbackIcon(BuildContext context) {
    final r = context.responsive;
    final titleLower = service.title.toLowerCase();
    IconData iconData;

    if (titleLower.contains('clean')) {
      iconData = Icons.cleaning_services;
    } else if (titleLower.contains('car')) {
      iconData = Icons.directions_car;
    } else if (titleLower.contains('house')) {
      iconData = Icons.house_outlined;
    } else {
      iconData = Icons.business;
    }

    return Center(
      child: SizedBox(
        width: r.iconSize32,
        height: r.iconSize32,
        child: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [
                  AppStyle.theme.colorScheme.surface,
                  AppStyle.theme.colorScheme.surface.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Icon(iconData, color: AppStyle.theme.colorScheme.surface, size: r.iconSize32),
        ),
      ),
    );
  }
}
