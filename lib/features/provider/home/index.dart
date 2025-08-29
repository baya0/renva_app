import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/services/pagination/options/list_view.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/pagination/controller.dart';
import '../../../core/services/pagination/widgets/initial_error.dart';
import '../../../core/services/pagination/widgets/initial_loading.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/image.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import 'controller.dart';

class ProviderHomePage extends StatelessWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBuilder = Get.find<AppBuilder>();

    if (appBuilder.providerStatus.value != "Approved") {
      return _buildPendingProviderHomeUI();
    }

    return _buildNormalProviderHomePage(context);
  }

  Widget _buildPendingProviderHomeUI() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [Color(0xff002364), Color(0xff002364), StyleRepo.grey.withValues(alpha: 0.2)],
            stops: [0.0, 0.25, 0.33],
          ),
        ),
        child: SafeArea(
          child: Builder(
            builder: (context) {
              // Get screen dimensions T_T
              final screenHeight = MediaQuery.of(context).size.height;
              final screenWidth = MediaQuery.of(context).size.width;

              final horizontalPadding = screenWidth * 0.05; // 5% of screen width
              final cardPadding = screenWidth * 0.08; // 8% of screen width
              final titleFontSize = screenWidth * 0.065; // 6.5% of screen width
              final bodyFontSize = screenWidth * 0.04; // 4% of screen width
              final buttonHeight = screenHeight * 0.07; // 7% of screen height

              return Column(
                children: [
                  // Main content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 30),
                            child: Container(
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
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
                                      'Welcome Future Provider!',
                                      style: TextStyle(
                                        fontSize: titleFontSize.clamp(25.0, 32.0),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontFamily.customFont,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.04),

                                  Text(
                                    "We're reviewing your provider application to ensure the best quality service for our customers.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: bodyFontSize.clamp(14.0, 18.0),
                                      color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                      fontFamily: FontFamily.customFont,
                                      height: 1.5,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.03),

                                  // Status indicator
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                          vertical: screenHeight * 0.015,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          color: StyleRepo.forestGreen.withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: StyleRepo.forestGreen.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
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
                                            SizedBox(width: 10),
                                            Text(
                                              "Review in progress • 1-3 days",
                                              style: TextStyle(
                                                fontSize: bodyFontSize.clamp(12.0, 16.0),
                                                color: StyleRepo.forestGreen,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: FontFamily.customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.02),

                                  Text(
                                    "What awaits you:",
                                    style: TextStyle(
                                      fontSize: bodyFontSize.clamp(14.0, 18.0),
                                      color: StyleRepo.deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.customFont,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.02),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.request,
                                          "Receive\nRequests",
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.coins,
                                          "Earn\nMoney",
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.reputation,
                                          "Build\nReputation",
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _buildFeatureCard(
                                          Assets.icons.services.trend,
                                          "Grow\nBusiness",
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: screenHeight * 0.04),

                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight.clamp(45.0, 55.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.find<AppBuilder>().setProviderMode(false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: StyleRepo.deepBlue,
                                        foregroundColor: StyleRepo.softWhite,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        "Continue as Customer",
                                        style: TextStyle(
                                          fontSize: bodyFontSize.clamp(14.0, 18.0),
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

                        // Bottom spacer
                        SizedBox(height: screenHeight * 0.1),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    SvgGenImage iconAsset,
    String text,
    double screenWidth,
    double screenHeight,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: StyleRepo.deepBlue.withValues(alpha: 0.1),
            border: Border.all(color: StyleRepo.deepBlue.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              SizedBox(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
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
              SizedBox(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (screenWidth * 0.028).clamp(10.0, 14.0),
                  color: StyleRepo.deepBlue.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.customFont,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------------------------------------------------------------///

  Widget _buildNormalProviderHomePage(BuildContext context) {
    final controller = Get.put(ProviderHomePageController());

    return Scaffold(
      backgroundColor: StyleRepo.deepBlue,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            left: 0,
            right: -60,
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
                      padding: const EdgeInsets.fromLTRB(23, 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Assets.images.logo.renva.svg(
                            width: 85,
                            height: 22,
                            colorFilter: ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.onNotificationTap(),
                                child: Assets.icons.essentials.search.svg(
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    StyleRepo.softWhite,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 26),
                              GestureDetector(
                                onTap: () => controller.onNotificationTap(),
                                child: Assets.icons.messages.notifications.svg(
                                  width: 24,
                                  height: 24,
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
                    const SizedBox(height: 25),

                    _buildProviderInfoSection(controller),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: StyleRepo.softWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(19, 23, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tr(LocaleKeys.provider_latest_orders),
                                  style: Theme.of(
                                    Get.context!,
                                  ).textTheme.titleMedium?.copyWith(color: StyleRepo.black),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: controller.onFilterOrdersTap,
                                  child: Assets.icons.essentials.searchList.svg(
                                    colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            Text(
                              tr(LocaleKeys.provider_requests_sent_from_newest_to_oldest),
                              style: Theme.of(
                                Get.context!,
                              ).textTheme.labelSmall?.copyWith(color: StyleRepo.grey),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

                          initialLoading: const InitialLoading(),
                          loading: Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: StyleRepo.deepBlue,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Loading more orders...',
                                  style: TextStyle(fontSize: 14, color: StyleRepo.grey),
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
                            return _buildOrderCard(order, index, controller);
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
    );
  }

  Widget _buildProviderInfoSection(ProviderHomePageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final providerData = controller.providerInfo.value;

        return Row(
          children: [
            // Provider avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: ClipOval(
                child: _buildAvatarWidget(
                  providerData?['avatar'],
                  controller.isLoadingProviderInfo.value,
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Provider details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerData?['name'] ?? 'Provider Name',
                    style: const TextStyle(
                      fontSize: 14,
                      color: StyleRepo.softWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Category
                      Text(
                        providerData?['category'] ?? 'Service Provider',
                        style: TextStyle(
                          color: StyleRepo.softWhite,
                          fontSize: 11,
                          fontFamily: FontFamily.customFont,
                          decoration: TextDecoration.underline,
                          decorationColor: StyleRepo.softWhite,
                          decorationThickness: 1.2,
                        ),
                      ),
                      SizedBox(width: 12),

                      // Rating stars
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final rating = providerData?['rating']?.toDouble() ?? 0.0;
                            return Icon(
                              index < rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            "${providerData?['rating']?.toStringAsFixed(1) ?? '0.0'}",
                            style: const TextStyle(
                              fontSize: 12,
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
  ) {
    if (order.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('Invalid order data', style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }

    final orderId = order['id']?.toString() ?? 'unknown';
    final requesterName = order['requesterName']?.toString() ?? 'Unknown Customer';
    final location = order['location']?.toString() ?? 'Location not specified';
    final date = order['date']?.toString() ?? '--';
    final time = order['time']?.toString() ?? '--';
    final duration = order['duration']?.toString() ?? '20 min';
    final hasCloseButton = order['hasCloseButton'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Pages.view_order_detail.value, arguments: order);
        },
        child: Container(
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StyleRepo.softGrey, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card content with left-edge color
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: StyleRepo.deepBlue, width: 20)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Requester Name
                    Row(
                      children: [
                        Assets.icons.essentials.circleUser.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            requesterName,
                            style: Get.textTheme.labelLarge?.copyWith(color: StyleRepo.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Location
                    Row(
                      children: [
                        Assets.icons.essentials.locationPin.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(
                              Get.context!,
                            ).textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Date
                    Row(
                      children: [
                        Assets.icons.document.calendar.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          date,
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Time + Duration
                    Row(
                      children: [
                        Assets.icons.document.timerAlt.svg(
                          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          time,
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.bodyMedium?.copyWith(color: StyleRepo.grey),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: StyleRepo.deepBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: 12,
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
                  top: 16,
                  right: 21,
                  child: GestureDetector(
                    onTap: () => PopUpToast.show('Close button tapped'),
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      width: 14,
                      height: 14,
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

  Widget _buildAvatarWidget(String? avatarUrl, bool isLoading) {
    if (isLoading) {
      return Container(
        color: StyleRepo.softWhite.withValues(alpha: 0.3),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
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
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: StyleRepo.softWhite, strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: _buildDefaultAvatar(),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: StyleRepo.softWhite.withValues(alpha: 0.3),
      ),
      child: Assets.icons.essentials.circleUser.svg(),
    );
  }
}
