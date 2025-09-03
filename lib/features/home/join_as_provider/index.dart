import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/state_management/widgets/obs_widget.dart';
import '../../../core/style/repo.dart';
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
                    const SizedBox(height: 20),

                    // Back button - RTL aware
                    _buildBackButton(context, isRTL),

                    const SizedBox(height: 20),

                    // Central icon
                    _buildCentralIcon(),

                    const SizedBox(height: 20),

                    // Title and subtitle
                    _buildTitleSection(context),

                    const SizedBox(height: 31),

                    Expanded(child: _buildServicesContent(context, controller)),

                    const SizedBox(height: 20),

                    _buildNextButton(controller),

                    const SizedBox(height: 20),
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
  Widget _buildBackButton(BuildContext context, bool isRTL) {
    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Transform.flip(
            flipX: isRTL,
            child: Assets.icons.arrows.leftCircle.svg(
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tr(LocaleKeys.common_back),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: StyleRepo.softWhite),
        ),
      ],
    );
  }

  Widget _buildCentralIcon() {
    return Center(child: Assets.images.background.addOrder.svg(height: 120, width: 120));
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      children: [
        Text(
          tr(LocaleKeys.join_provider_select_services_type),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: StyleRepo.softWhite,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          tr(LocaleKeys.join_provider_welcome_message),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.softGrey,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServicesContent(BuildContext context, JoinAsProviderController controller) {
    return ObsListBuilder<ServiceCategoryModel>(
      obs: controller.availableServices,
      onRefresh: controller.refreshData,
      builder: (context, services) {
        // Services loaded successfully
        return _buildServicesList(context, controller, services);
      },

      loader: (context) => _buildLoadingState(controller),

      errorBuilder: (context, error) => _buildErrorState(controller, error),
    );
  }

  Widget _buildLoadingState(JoinAsProviderController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite)),
        const SizedBox(height: 16),
        Text(
          tr(LocaleKeys.join_provider_loading_services),
          style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.8), fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          tr(LocaleKeys.join_provider_please_wait_loading),
          style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.6), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(JoinAsProviderController controller, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: StyleRepo.softWhite.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              tr(LocaleKeys.join_provider_failed_to_load_services),
              style: TextStyle(
                color: StyleRepo.softWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.retryFetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleRepo.softWhite,
                foregroundColor: StyleRepo.deepBlue,
              ),
              child: Text(tr(LocaleKeys.join_provider_retry)),
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
  ) {
    return Column(
      children: [
        // Status text
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            _getStatusText(controller),
            style: TextStyle(color: StyleRepo.softWhite.withOpacity(0.8), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),

        // Services list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceItem(context, services[index], controller);
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
  ) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Obx(() {
        final isSelected = controller.selectedServiceIds.contains(service.id.toString());

        return GestureDetector(
          onTap: () => controller.selectService(service.id.toString()),
          child: Container(
            width: double.infinity,
            height: 105,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(17),
              border: isSelected ? Border.all(color: StyleRepo.softWhite, width: 2) : null,
            ),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Left edge color indicator
                Container(
                  width: 9.5,
                  height: 105,
                  decoration: BoxDecoration(
                    color: service.leftEdgeColor,
                    borderRadius: BorderRadius.only(
                      topLeft: isRTL ? const Radius.circular(0) : const Radius.circular(17),
                      bottomLeft: isRTL ? const Radius.circular(0) : const Radius.circular(17),
                      topRight: isRTL ? const Radius.circular(17) : const Radius.circular(0),
                      bottomRight: isRTL ? const Radius.circular(17) : const Radius.circular(0),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        // Service icon
                        SizedBox(width: 42, height: 42, child: _buildServiceIcon(service)),

                        const SizedBox(width: 26),

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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _buildServiceSubtitle(service),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: StyleRepo.softGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Radio button
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: StyleRepo.softWhite, width: 2),
                            color: isSelected ? StyleRepo.softWhite : Colors.transparent,
                          ),
                          child:
                              isSelected
                                  ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
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
  Widget _buildServiceIcon(ServiceCategoryModel service) {
    // Try to use banner image from API first
    if (service.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppImage(
          path: service.imageUrl,
          type: ImageType.CachedNetwork,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorWidget: _buildFallbackIcon(service),
          loadingWidget: _buildLoadingIcon(),
        ),
      );
    }

    return _buildFallbackIcon(service);
  }

  Widget _buildFallbackIcon(ServiceCategoryModel service) {
    final titleLower = service.title.toLowerCase();

    if (titleLower.contains('household') ||
        titleLower.contains('home') ||
        titleLower.contains('clean')) {
      return SvgIcon(icon: Assets.icons.services.house, color: StyleRepo.softWhite, size: 42);
    } else if (titleLower.contains('professional') ||
        titleLower.contains('medical') ||
        titleLower.contains('health')) {
      return SvgIcon(icon: Assets.icons.services.wrench, color: StyleRepo.softWhite, size: 42);
    } else if (titleLower.contains('personal') ||
        titleLower.contains('training') ||
        titleLower.contains('education')) {
      return SvgIcon(icon: Assets.icons.services.certificate, color: StyleRepo.softWhite, size: 42);
    } else if (titleLower.contains('logistical') ||
        titleLower.contains('transport') ||
        titleLower.contains('delivery')) {
      return SvgIcon(icon: Assets.icons.services.truck, color: StyleRepo.softWhite, size: 42);
    } else {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: service.leftEdgeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.category_outlined, color: StyleRepo.softWhite, size: 24),
      );
    }
  }

  Widget _buildLoadingIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
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

  Widget _buildNextButton(JoinAsProviderController controller) {
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
            disabledBackgroundColor: StyleRepo.softWhite.withOpacity(0.5),
            disabledForegroundColor: StyleRepo.deepBlue.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
          ),
          child:
              controller.isLoading.value
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            StyleRepo.deepBlue.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tr(LocaleKeys.join_provider_loading),
                        style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StyleRepo.deepBlue.withOpacity(0.7),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canProceed ? StyleRepo.deepBlue : StyleRepo.deepBlue.withOpacity(0.5),
                    ),
                  ),
        ),
      );
    });
  }
}
