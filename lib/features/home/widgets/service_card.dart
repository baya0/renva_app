import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:renva0/core/style/style.dart';

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
    this.width = 159,
    this.height = 129,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
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
            borderRadius: BorderRadius.circular(17),
            color: AppStyle.theme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon section
                SizedBox(
                  height: 42,
                  child: Align(alignment: Alignment.topCenter, child: _buildServiceIcon()),
                ),

                // Text section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        service.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _buildSubtitleText(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
  Widget _buildServiceIcon() {
    // Try to use SVG from API first
    if (service.svg.isNotEmpty && service.svg.trim().isNotEmpty) {
      return _buildSvgFromApi();
    }

    // Fallback to asset icons or Material icons
    return _buildAssetIcon() ?? _buildFallbackIcon();
  }

  // Render SVG from API response
  Widget _buildSvgFromApi() {
    try {
      return SizedBox(
        width: 37,
        height: 37,
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

            placeholderBuilder: (context) => _buildFallbackIcon(),
          ),
        ),
      );
    } catch (e) {
      print(' Error rendering SVG from API: $e');
      return _buildFallbackIcon();
    }
  }

  // Try to match asset icons
  Widget? _buildAssetIcon() {
    try {
      final titleLower = service.title.toLowerCase();

      if (titleLower.contains('clean')) {
        return Assets.icons.services.house.svg(
          width: 37,
          height: 37,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('car')) {
        return Assets.icons.services.truck.svg(
          width: 37,
          height: 37,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('house')) {
        return Assets.icons.services.house.svg(
          width: 37,
          height: 37,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('professional')) {
        return Assets.icons.services.wrench.svg(
          width: 37,
          height: 37,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('personal')) {
        return Assets.icons.services.certificate.svg(
          width: 37,
          height: 37,
          colorFilter: ColorFilter.mode(AppStyle.theme.colorScheme.surface, BlendMode.srcIn),
        );
      } else if (titleLower.contains('logistical')) {
        return Assets.icons.services.truck.svg(
          width: 37,
          height: 37,
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
  Widget _buildFallbackIcon() {
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

    return SizedBox(
      width: 37,
      height: 37,
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
        child: Icon(iconData, color: AppStyle.theme.colorScheme.surface, size: 37),
      ),
    );
  }
}
