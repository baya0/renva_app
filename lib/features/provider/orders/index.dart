import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/constants/controllers_tags.dart';
import 'package:renva0/core/services/pagination/options/list_view.dart';
import 'package:renva0/core/style/repo.dart';

import '../../../core/config/app_builder.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/fonts.gen.dart';
import 'controller.dart';
import 'models/provider_model.dart';
import 'widget/provider_order_card.dart';

class ProviderOrdersPage extends StatelessWidget {
  const ProviderOrdersPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final appBuilder = Get.find<AppBuilder>();

    if (appBuilder.providerStatus.value != "Approved") {
      return _buildPendingProviderUI();
    }

    return _buildNormalProviderOrdersUI(context);
  }

  Widget _buildPendingProviderUI() {
    return Scaffold(
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

              final horizontalPadding = screenWidth * 0.05; // 5% of screen width
              final cardPadding = screenWidth * 0.08; // 8% of screen width
              final titleFontSize = screenWidth * 0.07; // 7% of screen width
              final bodyFontSize = screenWidth * 0.04; // 4% of screen width
              final iconSize = screenWidth * 0.20; // 20% of screen width
              final buttonHeight = screenHeight * 0.07; // 7% of screen height

              return Stack(
                children: [
                  Positioned(
                    top: -117,
                    left: -262,
                    right: 0,
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
                    left: 0,
                    right: -400,
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
                        //  some space to push content slightly down :p
                        SizedBox(height: screenHeight * 0.05),

                        // Main blurred frosted card :D
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
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                color: StyleRepo.softWhite.withValues(alpha: 0.3),
                              ),
                              child: Column(
                                children: [
                                  // Icon with glow effect w_W
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
                                    "Provider Application Pending...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: titleFontSize.clamp(20.0, 32.0), // Min 20, Max 32
                                      fontWeight: FontWeight.bold,
                                      color: StyleRepo.softWhite,
                                      fontFamily: FontFamily.customFont,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.03),

                                  Text(
                                    "Your provider application is currently under review by our team.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: bodyFontSize.clamp(14.0, 18.0), // Min 14, Max 18
                                      color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                      fontFamily: FontFamily.customFont,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    "You'll be able to receive orders once approved ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: bodyFontSize.clamp(14.0, 18.0), // Min 14, Max 18
                                      color: StyleRepo.softWhite.withValues(alpha: 0.9),
                                      fontFamily: FontFamily.customFont,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.04),

                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight.clamp(50.0, 65.0), // Min 50, Max 65
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
                                        "Continue as Customer",
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

                        // Bottom spacer to keep it centered/slightly down :D
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

  Widget _buildNormalProviderOrdersUI(BuildContext context) {
    final controller = Get.put(
      ProviderOrdersController(),
      tag: ControllersTags.providerOrdersController,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(controller),
          const SizedBox(height: 20),
          _buildTabBar(controller),
          const SizedBox(height: 16),
          _buildOrdersCount(controller),
          const SizedBox(height: 16),
          _buildOrdersList(controller),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'My Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: StyleRepo.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ProviderOrdersController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search orders...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[500]),
                      onPressed: controller.clearSearch,
                    )
                    : const SizedBox.shrink(),
          ),
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

  Widget _buildTabBar(ProviderOrdersController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          controller.tabs.length,
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
                    controller.tabs[index],
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

  Widget _buildOrdersCount(ProviderOrdersController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Obx(
            () => Text(
              '${controller.ordersCount} Orders',
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: StyleRepo.deepBlue),
          SizedBox(height: 16),
          Text('Loading orders...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
