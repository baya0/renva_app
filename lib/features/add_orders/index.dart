import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/style/repo.dart';
import '../../../gen/assets.gen.dart';
import '../../core/localization/strings.dart';
import '../../core/services/pagination/options/list_view.dart';
import '../home/models/service_categories.dart';
import 'controller.dart';

class AddOrdersPage extends StatelessWidget {
  const AddOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddOrderPageController(), permanent: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [StyleRepo.deepBlue, Color(0xFF0048D9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Opacity(
                opacity: 0.08,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.logo.renva.svg(
                      height: 92.75,
                      colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    _buildCentralIcon(),

                    const SizedBox(height: 15.14),

                    _buildTitleSection(context),

                    const SizedBox(height: 40),

                    Expanded(
                      child: ListViewPagination<ServiceCategoryModel>.builder(
                        tag: 'add_order_services',
                        fetchApi: controller.fetchData,
                        fromJson: ServiceCategoryModel.fromJson,

                        initialLoading: _buildLoadingState(),

                        errorWidget: (error) => _buildErrorState(controller, error),

                        itemBuilder: (context, index, service) {
                          return _buildServiceItem(context, service, controller);
                        },
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralIcon() {
    return Center(child: Assets.images.background.addOrder.svg(height: 172.86, width: 170));
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      children: [
        Text(
          tr(LocaleKeys.orders_add_order),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: StyleRepo.softWhite,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 23),
        Text(
          tr(LocaleKeys.orders_select_services_type_to_complete_order),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.softGrey,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: StyleRepo.softWhite),
          const SizedBox(height: 16),
          Text(
            tr(LocaleKeys.common_loading),
            style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AddOrderPageController controller, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Retry handled automatically by pagination
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleRepo.softWhite,
              foregroundColor: StyleRepo.deepBlue,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    ServiceCategoryModel service,
    AddOrderPageController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Obx(() {
        final isTapped = controller.isServiceTapped(service.id.toString());

        return GestureDetector(
          onTap: () => controller.selectServiceCategory(service),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 105,
            decoration: BoxDecoration(
              color: isTapped ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(17),
              border: isTapped ? Border.all(color: Colors.white.withOpacity(0.3), width: 1) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: _buildServiceIconWithShaderMask(service)),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: StyleRepo.softWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.prvCnt} providers available',
                          style: TextStyle(
                            fontSize: 12,
                            color: StyleRepo.softWhite.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    child: Assets.icons.arrows.rightCircle.svg(
                      colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                      width: 22,
                      height: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServiceIconWithShaderMask(ServiceCategoryModel service) {
    // Try to use SVG from API first (if available)
    if (service.svg.isNotEmpty && service.svg.trim().isNotEmpty) {
      return _buildSvgFromApi(service);
    }

    // Try asset icons based on title
    Widget? assetIcon = _buildAssetIcon(service);
    if (assetIcon != null) {
      return assetIcon;
    }

    // Fallback to category icon with ShaderMask
    return _buildFallbackIconWithShaderMask(service);
  }

  Widget _buildSvgFromApi(ServiceCategoryModel service) {
    try {
      return SizedBox(
        width: 42,
        height: 42,
        child: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [StyleRepo.softWhite, StyleRepo.softWhite.withValues(alpha: 0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: SvgPicture.string(
            service.svg,
            placeholderBuilder: (context) => _buildFallbackIconWithShaderMask(service),
          ),
        ),
      );
    } catch (e) {
      print('Error rendering SVG from API: $e');
      return _buildFallbackIconWithShaderMask(service);
    }
  }

  // Try to match asset icons (same logic as my home screen)
  Widget? _buildAssetIcon(ServiceCategoryModel service) {
    try {
      final titleLower = service.title.toLowerCase();

      if (titleLower.contains('clean') ||
          titleLower.contains('household') ||
          titleLower.contains('home')) {
        return Assets.icons.services.house.svg(
          width: 42,
          height: 42,
          colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
        );
      } else if (titleLower.contains('professional') ||
          titleLower.contains('medical') ||
          titleLower.contains('health')) {
        return Assets.icons.services.wrench.svg(
          width: 42,
          height: 42,
          colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
        );
      } else if (titleLower.contains('personal') ||
          titleLower.contains('training') ||
          titleLower.contains('education')) {
        return Assets.icons.services.certificate.svg(
          width: 42,
          height: 42,
          colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
        );
      } else if (titleLower.contains('logistical') ||
          titleLower.contains('transport') ||
          titleLower.contains('delivery')) {
        return Assets.icons.services.truck.svg(
          width: 42,
          height: 42,
          colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
        );
      }

      return null;
    } catch (e) {
      print('Error loading asset icon: $e');
      return null;
    }
  }

  Widget _buildFallbackIconWithShaderMask(ServiceCategoryModel service) {
    return SizedBox(
      width: 42,
      height: 42,
      child: ShaderMask(
        shaderCallback:
            (bounds) => LinearGradient(
              colors: [StyleRepo.softWhite, StyleRepo.softWhite.withValues(alpha: 0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Icon(
          Icons.category_outlined, // Simple fallback as requested
          color: StyleRepo.softWhite,
          size: 42,
        ),
      ),
    );
  }
}
