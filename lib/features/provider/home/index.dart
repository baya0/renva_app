import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:get/get.dart';
import 'package:renva0/core/services/pagination/options/list_view.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/pagination/controller.dart';
import '../../../core/services/pagination/widgets/initial_error.dart';
import '../../../core/services/pagination/widgets/initial_loading.dart';
import '../../../core/style/repo.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/image.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../../provider/home/controller.dart';

class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBuilder = Get.find<AppBuilder>();
    final bool isRTL = context.locale.languageCode == 'ar';

    if (appBuilder.providerStatus.value != "Approved") {
      return _buildPendingProviderHomeUI(isRTL);
    }

    return _buildNormalProviderHomePage(context, isRTL);
  }

  Widget _buildPendingProviderHomeUI(bool isRTL) {
    return Directionality(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isRTL ? Alignment.topRight : Alignment.topLeft,
              end: isRTL ? Alignment.bottomRight : Alignment.bottomLeft,
              colors: [Color(0xff002364), Color(0xff002364), StyleRepo.grey.withValues(alpha: 0.2)],
              stops: [0.0, 0.25, 0.33],
            ),
          ),
          child: SafeArea(
            child: Builder(
              builder: (context) {
                final r = context.responsive;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.space24, vertical: r.space64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 30),
                            child: Container(
                              padding: EdgeInsets.all(r.space24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(r.radius24),
                                boxShadow: [
                                  BoxShadow(
                                    color: StyleRepo.grey.withValues(alpha: 0.2),
                                    blurRadius: 40,
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.inner,
                                  ),
                                ],
                                color: StyleRepo.softWhite.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: StyleRepo.grey.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [
                                            StyleRepo.softWhite,
                                            StyleRepo.softWhite.withValues(alpha: 0.7),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ).createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: Text(
                                      tr(LocaleKeys.provider_home_welcome_future_provider),
                                      style: TextStyle(
                                        fontSize: r.fontSize24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontFamily.customFont,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  SizedBox(height: r.space24),

                                  Text(
                                    tr(LocaleKeys.provider_home_review_description),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: r.fontSize14,
                                      color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                      fontFamily: FontFamily.customFont,
                                      height: 1.5,
                                    ),
                                  ),

                                  SizedBox(height: r.space20),

                                  // Status indicator
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(r.radius16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: r.space16,
                                          vertical: r.space12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(r.radius16),
                                          color: StyleRepo.forestGreen.withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: StyleRepo.forestGreen.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          textDirection:
                                              isRTL
                                                  ? flutter.TextDirection.rtl
                                                  : flutter.TextDirection.ltr,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: StyleRepo.forestGreen,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: StyleRepo.forestGreen.withValues(
                                                      alpha: 0.5,
                                                    ),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: r.space8),
                                            Flexible(
                                              child: Text(
                                                tr(LocaleKeys.provider_home_review_in_progress),
                                                style: TextStyle(
                                                  fontSize: r.fontSize12,
                                                  color: StyleRepo.forestGreen,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: FontFamily.customFont,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: r.space16),

                                  Text(
                                    tr(LocaleKeys.provider_home_what_awaits_you),
                                    style: TextStyle(
                                      fontSize: r.fontSize14,
                                      color: StyleRepo.deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.customFont,
                                    ),
                                  ),

                                  SizedBox(height: r.space16),

                                  Row(
                                    textDirection:
                                        isRTL
                                            ? flutter.TextDirection.rtl
                                            : flutter.TextDirection.ltr,
                                    children: [
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.request,
                                          tr(LocaleKeys.provider_home_receive_requests),
                                          r,
                                          isRTL,
                                        ),
                                      ),
                                      SizedBox(width: r.space8),
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.coins,
                                          tr(LocaleKeys.provider_home_earn_money),
                                          r,
                                          isRTL,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: r.space8),
                                  Row(
                                    textDirection:
                                        isRTL
                                            ? flutter.TextDirection.rtl
                                            : flutter.TextDirection.ltr,
                                    children: [
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.reputation,
                                          tr(LocaleKeys.provider_home_build_reputation),
                                          r,
                                          isRTL,
                                        ),
                                      ),
                                      SizedBox(width: r.space8),
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.trend,
                                          tr(LocaleKeys.provider_home_grow_business),
                                          r,
                                          isRTL,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: r.space24),

                                  SizedBox(
                                    width: double.infinity,
                                    height: r.buttonHeightMedium,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.find<AppBuilder>().setProviderMode(false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: StyleRepo.deepBlue,
                                        foregroundColor: StyleRepo.softWhite,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(r.radius16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        tr(LocaleKeys.provider_home_continue_as_customer),
                                        style: TextStyle(
                                          fontSize: r.fontSize12,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: FontFamily.customFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(SvgGenImage iconAsset, String text, Responsive r, bool isRTL) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(r.radius12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: r.space12, horizontal: r.space8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.radius12),
            color: StyleRepo.deepBlue.withValues(alpha: 0.1),
            border: Border.all(color: StyleRepo.deepBlue.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: r.iconSize32,
                height: r.iconSize32,
                child: ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [StyleRepo.deepBlue, StyleRepo.deepBlue.withValues(alpha: 0.3)],
                      ).createShader(bounds),
                  child: iconAsset.svg(
                    colorFilter: ColorFilter.mode(StyleRepo.deepBlue, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(height: r.space4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fontSize10,
                  color: StyleRepo.deepBlue.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.customFont,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalProviderHomePage(BuildContext context, bool isRTL) {
    final controller = Get.put(ProviderHomePageController());
    final r = context.responsive;

    return Directionality(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: StyleRepo.deepBlue,
        body: Stack(
          children: [
            Positioned(
              top: -40,
              left: isRTL ? -60 : 0,
              right: isRTL ? 0 : -60,
              bottom: MediaQuery.of(context).size.width * 1.4,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Assets.images.background.homeProviderBackground.provider(),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        StyleRepo.deepBlue.withValues(alpha: 0.65),
                        BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and notifications row
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isRTL ? r.space20 : r.space24,
                          r.space12,
                          isRTL ? r.space24 : r.space20,
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                          children: [
                            Assets.images.logo.renva.svg(
                              width: r.value(mobile: 75.0, tablet: 85.0, desktop: 95.0),
                              height: r.value(mobile: 20.0, tablet: 22.0, desktop: 25.0),
                              colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                            ),
                            Row(
                              textDirection:
                                  isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                              children: [
                                GestureDetector(
                                  onTap: () => controller.onNotificationTap(),
                                  child: Assets.icons.essentials.search.svg(
                                    width: r.iconSize24,
                                    height: r.iconSize24,
                                    colorFilter: ColorFilter.mode(
                                      StyleRepo.softWhite,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(width: r.space24),
                                GestureDetector(
                                  onTap: () => controller.onNotificationTap(),
                                  child: Assets.icons.messages.notifications.svg(
                                    width: r.iconSize24,
                                    height: r.iconSize24,
                                    colorFilter: ColorFilter.mode(
                                      StyleRepo.softWhite,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: r.space24),

                      _buildProviderInfoSection(controller, isRTL, r),
                      SizedBox(height: r.space32),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StyleRepo.softWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(r.radius24),
                        topRight: Radius.circular(r.radius24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isRTL ? r.space20 : r.space20,
                            r.space24,
                            isRTL ? r.space20 : r.space20,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Row(
                                textDirection:
                                    isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tr(LocaleKeys.provider_latest_orders),
                                      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                                        color: StyleRepo.black,
                                        fontSize: r.fontSize16,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: controller.onFilterOrdersTap,
                                    child: Assets.icons.essentials.searchList.svg(
                                      colorFilter: ColorFilter.mode(
                                        StyleRepo.grey,
                                        BlendMode.srcIn,
                                      ),
                                      height: r.iconSize24,
                                      width: r.iconSize24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: r.space8),
                              Text(
                                tr(LocaleKeys.provider_requests_sent_from_newest_to_oldest),
                                style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                                  color: StyleRepo.grey,
                                  fontSize: r.fontSize12,
                                ),
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ],
                          ),
                        ),

                        // Orders list
                        Expanded(
                          child: ListViewPagination<Map<String, dynamic>>.builder(
                            tag: 'provider_orders_pager',
                            fetchApi: controller.fetchOrdersPage,
                            fromJson: (json) => controller.formatOrderForPager(json),
                            hasRefresh: true,
                            closeToListEnd: 300,
                            padding: EdgeInsets.symmetric(
                              horizontal: r.space20,
                              vertical: r.space20,
                            ),

                            initialLoading: const InitialLoading(),
                            loading: Container(
                              padding: EdgeInsets.all(r.space16),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                textDirection:
                                    isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                                children: [
                                  SizedBox(
                                    width: r.iconSize20,
                                    height: r.iconSize20,
                                    child: CircularProgressIndicator(
                                      color: StyleRepo.deepBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: r.space12),
                                  Text(
                                    tr(LocaleKeys.provider_home_loading_more_orders),
                                    style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey),
                                  ),
                                ],
                              ),
                            ),

                            errorWidget:
                                (error) => InitialError(
                                  error: error,
                                  refresh: () async {
                                    try {
                                      if (Get.isRegistered<
                                        PaginationController<Map<String, dynamic>>
                                      >(tag: 'provider_orders_pager')) {
                                        final paginationController =
                                            Get.find<PaginationController<Map<String, dynamic>>>(
                                              tag: 'provider_orders_pager',
                                            );
                                        await paginationController.refreshData();
                                      }
                                    } catch (e) {
                                      PopUpToast.show(e.toString());
                                    }
                                  },
                                ),

                            itemBuilder: (context, index, order) {
                              return _buildOrderCard(order, index, controller, isRTL, r);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoSection(
    ProviderHomePageController controller,
    bool isRTL,
    Responsive r,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space20),
      child: Obx(() {
        final providerData = controller.providerInfo.value;

        return Row(
          textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
          children: [
            // Provider avatar
            Container(
              width: r.value(mobile: 50.0, tablet: 55.0, desktop: 60.0),
              height: r.value(mobile: 50.0, tablet: 55.0, desktop: 60.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: ClipOval(
                child: _buildAvatarWidget(
                  providerData?['avatar'],
                  controller.isLoadingProviderInfo.value,
                  r,
                ),
              ),
            ),
            SizedBox(width: r.space16),

            // Provider details
            Expanded(
              child: Column(
                crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(
                    providerData?['name'] ?? tr(LocaleKeys.provider_home_provider_name_fallback),
                    style: TextStyle(
                      fontSize: r.fontSize14,
                      color: StyleRepo.softWhite,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.space4),
                  Row(
                    textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                    children: [
                      // Category
                      Flexible(
                        child: Text(
                          providerData?['category'] ??
                              tr(LocaleKeys.provider_home_service_provider_fallback),
                          style: TextStyle(
                            color: StyleRepo.softWhite,
                            fontSize: r.fontSize11,
                            fontFamily: FontFamily.customFont,
                            decoration: TextDecoration.underline,
                            decorationColor: StyleRepo.softWhite,
                            decorationThickness: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: r.space12),

                      // Rating stars
                      Row(
                        textDirection: flutter.TextDirection.ltr,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            final rating = providerData?['rating']?.toDouble() ?? 0.0;
                            return Icon(
                              index < rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: r.iconSize14,
                            );
                          }),
                          SizedBox(width: r.space4),
                          Text(
                            "${providerData?['rating']?.toStringAsFixed(1) ?? '0.0'}",
                            style: TextStyle(
                              fontSize: r.fontSize12,
                              color: Colors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    int index,
    ProviderHomePageController controller,
    bool isRTL,
    Responsive r,
  ) {
    if (order.isEmpty) {
      return Container(
        margin: EdgeInsets.only(bottom: r.space12),
        padding: EdgeInsets.all(r.space16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(r.radius12),
        ),
        child: Center(
          child: Text(
            tr(LocaleKeys.provider_home_invalid_order_data),
            style: TextStyle(color: Colors.grey.shade600, fontSize: r.fontSize14),
          ),
        ),
      );
    }

    final orderId = order['id']?.toString() ?? 'unknown';
    final requesterName =
        order['requesterName']?.toString() ?? tr(LocaleKeys.provider_home_unknown_customer);
    final location =
        order['location']?.toString() ?? tr(LocaleKeys.provider_home_location_not_specified);
    final date = order['date']?.toString() ?? '--';
    final time = order['time']?.toString() ?? '--';
    final duration = order['duration']?.toString() ?? '20 min';
    final hasCloseButton = order['hasCloseButton'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: r.space12),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Pages.view_order_detail.value, arguments: order);
        },
        child: Container(
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: r.value(mobile: 6.0, tablet: 8.0, desktop: 10.0),
                offset: Offset(0, r.value(mobile: 1.0, tablet: 2.0, desktop: 2.0)),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card content with left-edge color
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.radius12),
                  border:
                      isRTL
                          ? Border(
                            right: BorderSide(
                              color: StyleRepo.deepBlue,
                              width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                            ),
                          )
                          : Border(
                            left: BorderSide(
                              color: StyleRepo.deepBlue,
                              width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                            ),
                          ),
                ),
                padding: EdgeInsets.all(r.space16),
                child: Column(
                  crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    // Requester Name
                    Row(
                      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                      children: [
                        Assets.icons.essentials.circleUser.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                          width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                        ),
                        SizedBox(width: r.space8),
                        Expanded(
                          child: Text(
                            requesterName,
                            style: Get.textTheme.labelLarge?.copyWith(
                              color: StyleRepo.black,
                              fontSize: r.fontSize14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space16),

                    // Location
                    Row(
                      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                      children: [
                        Assets.icons.essentials.locationPin.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                          width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                        ),
                        SizedBox(width: r.space16),
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                              color: StyleRepo.grey,
                              fontSize: r.fontSize12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space16),

                    // Date
                    Row(
                      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                      children: [
                        Assets.icons.document.calendar.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                          width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                        ),
                        SizedBox(width: r.space16),
                        Text(
                          date,
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: StyleRepo.grey,
                            fontSize: r.fontSize12,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: r.space16),

                    // Time + Duration
                    Row(
                      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                      children: [
                        Assets.icons.document.timerAlt.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                          width: r.value(mobile: 16.0, tablet: 18.0, desktop: 20.0),
                        ),
                        SizedBox(width: r.space16),
                        Text(
                          time,
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: StyleRepo.grey,
                            fontSize: r.fontSize12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: r.space8, vertical: r.space4),
                          decoration: BoxDecoration(
                            color: StyleRepo.deepBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(r.radius12),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: r.fontSize12,
                              color: StyleRepo.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close Button
              if (hasCloseButton)
                Positioned(
                  top: r.space16,
                  right: isRTL ? null : r.value(mobile: 18.0, tablet: 20.0, desktop: 21.0),
                  left: isRTL ? r.value(mobile: 18.0, tablet: 20.0, desktop: 21.0) : null,
                  child: GestureDetector(
                    onTap: () => PopUpToast.show(tr(LocaleKeys.provider_home_close_button_tapped)),
                    child: Container(
                      padding: EdgeInsets.all(r.value(mobile: 1.0, tablet: 1.5, desktop: 1.5)),
                      width: r.value(mobile: 12.0, tablet: 14.0, desktop: 14.0),
                      height: r.value(mobile: 12.0, tablet: 14.0, desktop: 14.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: StyleRepo.grey, width: 1),
                      ),
                      child: Center(
                        child: Assets.icons.essentials.close.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.red, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(String? avatarUrl, bool isLoading, Responsive r) {
    if (isLoading) {
      return Container(
        color: StyleRepo.softWhite.withValues(alpha: 0.3),
        child: Center(
          child: SizedBox(
            width: r.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
            height: r.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
            child: CircularProgressIndicator(color: StyleRepo.softWhite, strokeWidth: 2),
          ),
        ),
      );
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AppImage(
        path: avatarUrl,
        type: ImageType.CachedNetwork,
        fit: BoxFit.cover,
        loadingWidget: Container(
          color: StyleRepo.softWhite.withOpacity(0.3),
          child: Center(
            child: SizedBox(
              width: r.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
              height: r.value(mobile: 18.0, tablet: 20.0, desktop: 22.0),
              child: CircularProgressIndicator(color: StyleRepo.softWhite, strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: _buildDefaultAvatar(r),
      );
    } else {
      return _buildDefaultAvatar(r);
    }
  }

  Widget _buildDefaultAvatar(Responsive r) {
    final avatarSize = r.value(mobile: 45.0, tablet: 50.0, desktop: 55.0);
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: StyleRepo.softWhite.withValues(alpha: 0.3),
      ),
      child: Assets.icons.essentials.circleUser.svg(),
    );
  }
}
