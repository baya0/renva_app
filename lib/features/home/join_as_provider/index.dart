import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/state_management/widgets/obs_widget.dart';
import '../../../core/style/repo.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/image.dart';
import '../../../core/widgets/svg_icon.dart';
import '../../../gen/assets.gen.dart';
import '../models/service_categories.dart';
import 'controller.dart';

class JoinAsProviderPage extends StatelessWidget {
  const JoinAsProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinAsProviderController());
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final r = context.responsive;

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
              // Background watermark
              Opacity(
                opacity: 0.08,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.images.logo.renva.svg(
                      height: r.value(mobile: 92.75, tablet: 100.0, desktop: 110.0),
                      colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.space24),
                child: Column(
                  children: [
                    SizedBox(height: r.space20),

                    // Back button - RTL aware
                    _buildBackButton(context, isRTL, r),

                    SizedBox(height: r.space20),

                    // Central icon
                    _buildCentralIcon(r),

                    SizedBox(height: r.space20),

                    // Title and subtitle
                    _buildTitleSection(context, r),

                    SizedBox(height: r.space32),

                    Expanded(child: _buildServicesContent(context, controller, r)),

                    SizedBox(height: r.space20),

                    _buildNextButton(controller, r),

                    SizedBox(height: r.space20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // RTL-aware back button
  Widget _buildBackButton(BuildContext context, bool isRTL, Responsive r) {
    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Transform.flip(
            flipX: isRTL,
            child: Assets.icons.arrows.leftCircle.svg(
              width: r.iconSize24,
              height: r.iconSize24,
              colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: r.space8),
        Text(
          tr(LocaleKeys.common_back),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.softWhite,
            fontSize: r.fontSize14,
          ),
        ),
      ],
    );
  }

  Widget _buildCentralIcon(Responsive r) {
    final iconSize = r.value(mobile: 120.0, tablet: 140.0, desktop: 160.0);
    return Center(child: Assets.images.background.addOrder.svg(height: iconSize, width: iconSize));
  }

  Widget _buildTitleSection(BuildContext context, Responsive r) {
    return Column(
      children: [
        Text(
          tr(LocaleKeys.join_provider_select_services_type),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: StyleRepo.softWhite,
            fontSize: r.fontSize24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: r.space16),
        Text(
          tr(LocaleKeys.join_provider_welcome_message),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.softGrey,
            fontWeight: FontWeight.w400,
            fontSize: r.fontSize14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServicesContent(BuildContext context, JoinAsProviderController controller, Responsive r) {
    return ObsListBuilder<ServiceCategoryModel>(
      obs: controller.availableServices,
      onRefresh: controller.refreshData,
      builder: (context, services) {
        // Services loaded successfully
        return _buildServicesList(context, controller, services, r);
      },

      loader: (context) => _buildLoadingState(controller, r),

      errorBuilder: (context, error) => _buildErrorState(controller, error, r),
    );
  }

  Widget _buildLoadingState(JoinAsProviderController controller, Responsive r) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite)),
        SizedBox(height: r.space16),
        Text(
          tr(LocaleKeys.join_provider_loading_services),
          style: TextStyle(color: StyleRepo.softWhite.withValues(alpha: 0.8), fontSize: r.fontSize16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: r.space8),
        Text(
          tr(LocaleKeys.join_provider_please_wait_loading),
          style: TextStyle(color: StyleRepo.softWhite.withValues(alpha: 0.6), fontSize: r.fontSize12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(JoinAsProviderController controller, String error, Responsive r) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: r.value(mobile: 64.0, tablet: 72.0, desktop: 80.0), color: StyleRepo.softWhite.withValues(alpha: 0.7)),
            SizedBox(height: r.space16),
            Text(
              tr(LocaleKeys.join_provider_failed_to_load_services),
              style: TextStyle(
                color: StyleRepo.softWhite,
                fontSize: r.fontSize18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.space8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: StyleRepo.softWhite.withValues(alpha: 0.8), fontSize: r.fontSize14),
            ),
            SizedBox(height: r.space20),
            ElevatedButton(
              onPressed: controller.retryFetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleRepo.softWhite,
                foregroundColor: StyleRepo.deepBlue,
                padding: EdgeInsets.symmetric(horizontal: r.space24, vertical: r.space12),
              ),
              child: Text(tr(LocaleKeys.join_provider_retry), style: TextStyle(fontSize: r.fontSize14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    JoinAsProviderController controller,
    List<ServiceCategoryModel> services,
    Responsive r,
  ) {
    return Column(
      children: [
        // Status text
        Padding(
          padding: EdgeInsets.only(bottom: r.space16),
          child: Text(
            _getStatusText(controller),
            style: TextStyle(color: StyleRepo.softWhite.withValues(alpha: 0.8), fontSize: r.fontSize12),
            textAlign: TextAlign.center,
          ),
        ),

        // Services list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(context, services[index], controller, r);
            },
          ),
        ),
      ],
    );
  }

  String _getStatusText(JoinAsProviderController controller) {
    if (controller.isServicesLoading) {
      return tr(LocaleKeys.join_provider_loading_services);
    }
    if (controller.hasError) {
      String error = controller.availableServices.error ?? controller.errorMessage.error ?? '';
      return '${tr(LocaleKeys.join_provider_error_prefix)}$error';
    }
    if (!controller.hasServices) {
      return tr(LocaleKeys.join_provider_no_services_available);
    }
    return tr(
      LocaleKeys.join_provider_services_available,
    ).replaceAll('{count}', controller.availableServices.valueLength.toString());
  }

  // Service item with selection state
  Widget _buildServiceItem(
    BuildContext context,
    ServiceCategoryModel service,
    JoinAsProviderController controller,
    Responsive r,
  ) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final cardHeight = r.value(mobile: 105.0, tablet: 115.0, desktop: 125.0);
    final iconSize = r.value(mobile: 42.0, tablet: 46.0, desktop: 50.0);
    final radioSize = r.value(mobile: 24.0, tablet: 26.0, desktop: 28.0);

    return Container(
      margin: EdgeInsets.only(bottom: r.space12),
      child: Obx(() {
        final isSelected = controller.selectedServiceIds.contains(service.id.toString());

        return GestureDetector(
          onTap: () => controller.selectService(service.id.toString()),
          child: Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.radius16),
              border: isSelected ? Border.all(color: StyleRepo.softWhite, width: 2) : null,
            ),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Left edge color indicator
                Container(
                  width: r.value(mobile: 9.5, tablet: 10.0, desktop: 11.0),
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: service.leftEdgeColor,
                    borderRadius: BorderRadius.only(
                      topLeft: isRTL ? const Radius.circular(0) : Radius.circular(r.radius16),
                      bottomLeft: isRTL ? const Radius.circular(0) : Radius.circular(r.radius16),
                      topRight: isRTL ? Radius.circular(r.radius16) : const Radius.circular(0),
                      bottomRight: isRTL ? Radius.circular(r.radius16) : const Radius.circular(0),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.space16, vertical: r.space16),
                    child: Row(
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        // Service icon
                        SizedBox(width: iconSize, height: iconSize, child: _buildServiceIcon(service, iconSize)),

                        SizedBox(width: r.space24),

                        // Service details
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: StyleRepo.softWhite,
                                  fontSize: r.fontSize16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                              SizedBox(height: r.space4),
                              Text(
                                _buildServiceSubtitle(service),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: StyleRepo.softGrey,
                                  fontSize: r.fontSize10,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: r.space16),

                        // Radio button
                        Container(
                          width: radioSize,
                          height: radioSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: StyleRepo.softWhite, width: 2),
                            color: isSelected ? StyleRepo.softWhite : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? Center(
                                    child: Container(
                                      width: radioSize * 0.33,
                                      height: radioSize * 0.33,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: StyleRepo.deepBlue,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _buildServiceSubtitle(ServiceCategoryModel service) {
    List<String> parts = [];

    if (service.subCategories.isNotEmpty) {
      parts.add('${service.subCategories.length} ${tr(LocaleKeys.join_provider_subcategories)}');
    }

    if (service.prvCnt > 0) {
      parts.add('${service.prvCnt} ${tr(LocaleKeys.join_provider_providers)}');
    }

    if (service.maxPrice > 0) {
      parts.add('${tr(LocaleKeys.join_provider_up_to)} \$${service.maxPrice}');
    }

    return parts.isNotEmpty ? parts.join(' • ') : service.subtitle;
  }

  //  Handles different icon types
  Widget _buildServiceIcon(ServiceCategoryModel service, double size) {
    // Try to use banner image from API first
    if (service.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppImage(
          path: service.imageUrl,
          type: ImageType.CachedNetwork,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: _buildFallbackIcon(service, size),
          loadingWidget: _buildLoadingIcon(size),
        ),
      );
    }

    return _buildFallbackIcon(service, size);
  }

  Widget _buildFallbackIcon(ServiceCategoryModel service, double size) {
    final titleLower = service.title.toLowerCase();

    if (titleLower.contains('household') ||
        titleLower.contains('home') ||
        titleLower.contains('clean')) {
      return SvgIcon(icon: Assets.icons.services.house, color: StyleRepo.softWhite, size: size);
    } else if (titleLower.contains('professional') ||
        titleLower.contains('medical') ||
        titleLower.contains('health')) {
      return SvgIcon(icon: Assets.icons.services.wrench, color: StyleRepo.softWhite, size: size);
    } else if (titleLower.contains('personal') ||
        titleLower.contains('training') ||
        titleLower.contains('education')) {
      return SvgIcon(icon: Assets.icons.services.certificate, color: StyleRepo.softWhite, size: size);
    } else if (titleLower.contains('logistical') ||
        titleLower.contains('transport') ||
        titleLower.contains('delivery')) {
      return SvgIcon(icon: Assets.icons.services.truck, color: StyleRepo.softWhite, size: size);
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: service.leftEdgeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.category_outlined, color: StyleRepo.softWhite, size: size * 0.57),
      );
    }
  }

  Widget _buildLoadingIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildNextButton(JoinAsProviderController controller, Responsive r) {
    final buttonHeight = r.buttonHeightMedium;

    return Obx(() {
      final hasSelection = controller.selectedServiceIds.isNotEmpty;
      final canProceed = controller.canProceed;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canProceed ? controller.onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleRepo.softWhite,
            foregroundColor: StyleRepo.deepBlue,
            disabledBackgroundColor: StyleRepo.softWhite.withValues(alpha: 0.5),
            disabledForegroundColor: StyleRepo.deepBlue.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius24)),
            padding: EdgeInsets.symmetric(vertical: r.space16),
            elevation: 0,
            minimumSize: Size(double.infinity, buttonHeight),
          ),
          child:
              controller.isLoading.value
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: r.iconSize20,
                        height: r.iconSize20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            StyleRepo.deepBlue.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      SizedBox(width: r.space12),
                      Text(
                        tr(LocaleKeys.join_provider_loading),
                        style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                          fontSize: r.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: StyleRepo.deepBlue.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  )
                  : Text(
                    hasSelection
                        ? tr(
                          LocaleKeys.join_provider_next_with_count,
                        ).replaceAll('{count}', controller.selectedServiceIds.length.toString())
                        : tr(LocaleKeys.join_provider_next),
                    style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                      fontSize: r.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: canProceed ? StyleRepo.deepBlue : StyleRepo.deepBlue.withValues(alpha: 0.5),
                    ),
                  ),
        ),
      );
    });
  }
}
