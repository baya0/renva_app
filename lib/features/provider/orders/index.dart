import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:get/get.dart';
import 'package:renva0/core/constants/controllers_tags.dart';
import 'package:renva0/core/services/pagination/options/list_view.dart';
import 'package:renva0/core/style/repo.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import 'controller.dart';
import 'models/provider_model.dart';
import 'widget/provider_order_card.dart';

class ProviderOrdersPage extends StatelessWidget {
  const ProviderOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appBuilder = Get.find<AppBuilder>();
    final bool isRTL = context.locale.languageCode == 'ar';

    if (appBuilder.providerStatus.value != "Approved") {
      return _buildPendingProviderUI(isRTL);
    }

    return _buildNormalProviderOrdersUI(context, isRTL);
  }

  Widget _buildPendingProviderUI(bool isRTL) {
    return Directionality(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: StyleRepo.deepBlue,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [StyleRepo.deepBlue, Color(0xff0048D9)],
            ),
          ),
          child: SafeArea(
            child: Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;

                final horizontalPadding = screenWidth * 0.05;
                final cardPadding = screenWidth * 0.08;
                final titleFontSize = screenWidth * 0.07;
                final bodyFontSize = screenWidth * 0.04;
                final iconSize = screenWidth * 0.20;
                final buttonHeight = screenHeight * 0.07;

                return Stack(
                  children: [
                    // Background logos - adjust positioning for RTL
                    Positioned(
                      top: -117,
                      left: isRTL ? 0 : -262,
                      right: isRTL ? -262 : 0,
                      bottom: MediaQuery.of(context).size.height * 0.5,
                      child: Opacity(
                        opacity: 0.08,
                        child: Assets.images.logo.logo.svg(
                          height: screenHeight * 0.30,
                          colorFilter: ColorFilter.mode(
                            StyleRepo.softWhite.withValues(alpha: 0.8),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.5,
                      left: isRTL ? -400 : 0,
                      right: isRTL ? 0 : -400,
                      bottom: -117,
                      child: Opacity(
                        opacity: 0.08,
                        child: Assets.images.logo.logo.svg(
                          height: screenHeight * 0.30,
                          colorFilter: ColorFilter.mode(
                            StyleRepo.softWhite.withValues(alpha: 0.8),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.05),

                          // Main blurred frosted card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25.8, sigmaY: 25.8),
                              child: Container(
                                padding: EdgeInsets.all(cardPadding),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    colors: [
                                      StyleRepo.softWhite.withValues(alpha: 0.10),
                                      StyleRepo.softWhite.withValues(alpha: 0.80),
                                    ],
                                    begin: isRTL ? Alignment.topRight : Alignment.topLeft,
                                    end: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
                                  ),
                                  color: StyleRepo.softWhite.withValues(alpha: 0.3),
                                ),
                                child: Column(
                                  children: [
                                    // Icon with glow effect
                                    Container(
                                      padding: EdgeInsets.all(screenWidth * 0.05),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: StyleRepo.softWhite.withValues(alpha: 0.1),
                                      ),
                                      child: SizedBox(
                                        child: ShaderMask(
                                          shaderCallback:
                                              (bounds) => LinearGradient(
                                                colors: [
                                                  StyleRepo.softWhite,
                                                  StyleRepo.softWhite.withValues(alpha: 0.1),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ).createShader(bounds),
                                          blendMode: BlendMode.srcIn,
                                          child: Icon(
                                            Icons.hourglass_empty,
                                            color: StyleRepo.softWhite,
                                            size: iconSize,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.04),

                                    // Main title
                                    Text(
                                      tr(LocaleKeys.provider_orders_application_pending),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: titleFontSize.clamp(20.0, 32.0),
                                        fontWeight: FontWeight.bold,
                                        color: StyleRepo.softWhite,
                                        fontFamily: FontFamily.customFont,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.03),

                                    Text(
                                      tr(LocaleKeys.provider_orders_review_description),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: bodyFontSize.clamp(14.0, 18.0),
                                        color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                        fontFamily: FontFamily.customFont,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      tr(LocaleKeys.provider_orders_approval_note),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: bodyFontSize.clamp(14.0, 18.0),
                                        color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                        fontFamily: FontFamily.customFont,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.04),

                                    SizedBox(
                                      width: double.infinity,
                                      height: buttonHeight.clamp(50.0, 65.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.find<AppBuilder>().setProviderMode(false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: StyleRepo.lightdeepblue,
                                          foregroundColor: StyleRepo.deepBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          tr(LocaleKeys.provider_orders_continue_as_customer),
                                          style: TextStyle(
                                            fontSize: bodyFontSize.clamp(14.0, 18.0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),
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
      ),
    );
  }

  Widget _buildNormalProviderOrdersUI(BuildContext context, bool isRTL) {
    final controller = Get.put(
      ProviderOrdersController(),
      tag: ControllersTags.providerOrdersController,
    );

    return Directionality(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(isRTL),
            _buildSearchBar(controller, isRTL),
            const SizedBox(height: 20),
            _buildTabBar(controller, isRTL),
            const SizedBox(height: 16),
            _buildOrdersCount(controller, isRTL),
            const SizedBox(height: 16),
            _buildOrdersList(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRTL) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
          children: [
            Expanded(
              child: Text(
                tr(LocaleKeys.provider_orders_my_orders),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ProviderOrdersController controller, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller.searchController,
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        textAlign: isRTL ? flutter.TextAlign.right : flutter.TextAlign.left,
        decoration: InputDecoration(
          hintText: tr(LocaleKeys.provider_orders_search_orders),
          hintStyle: TextStyle(color: Colors.grey[500]),

          suffixIcon:
              isRTL
                  ? Icon(Icons.search, color: Colors.grey[500])
                  : Obx(
                    () =>
                        controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: controller.clearSearch,
                            )
                            : const SizedBox.shrink(),
                  ),
          // For RTL, put the clear button on the left side
          prefixIcon:
              isRTL
                  ? Obx(
                    () =>
                        controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: controller.clearSearch,
                            )
                            : const SizedBox.shrink(),
                  )
                  : Icon(Icons.search, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabBar(ProviderOrdersController controller, bool isRTL) {
    // Localized tab names
    final localizedTabs = [
      tr(LocaleKeys.provider_orders_pending),
      tr(LocaleKeys.provider_orders_underway),
      tr(LocaleKeys.provider_orders_complete),
      tr(LocaleKeys.provider_orders_cancelled),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        children: List.generate(
          localizedTabs.length,
          (index) => Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTabIndex.value == index
                                ? StyleRepo.deepBlue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    localizedTabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          controller.selectedTabIndex.value == index
                              ? StyleRepo.deepBlue
                              : Colors.grey[500],
                      fontSize: 14,
                      fontWeight:
                          controller.selectedTabIndex.value == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersCount(ProviderOrdersController controller, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        children: [
          Obx(
            () => Text(
              isRTL
                  ? '${tr(LocaleKeys.provider_orders_orders_count)} ${controller.ordersCount}'
                  : '${controller.ordersCount} ${tr(LocaleKeys.provider_orders_orders_count)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(ProviderOrdersController controller) {
    return Expanded(
      child: Obx(() {
        final tabIndex = controller.selectedTabIndex.value;
        final tag = controller.tabTags[tabIndex]!;

        return ListViewPagination<ProviderOrderModel>.builder(
          tag: tag,
          fetchApi: controller.fetchApi,
          fromJson: controller.fromJson,
          itemBuilder: (context, index, order) {
            return ProviderOrderCard(
              order: order,
              controller: controller,
              showCompleteButton: tabIndex == 1, // Underway tab
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hasRefresh: true,
          initialLoading: _buildInitialLoading(),
        );
      }),
    );
  }

  Widget _buildInitialLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: StyleRepo.deepBlue),
          const SizedBox(height: 16),
          Text(
            tr(LocaleKeys.provider_orders_loading_orders),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
