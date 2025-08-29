import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_builder.dart';
import '../../../core/localization/strings.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/svg_icon.dart';
import '../../../gen/assets.gen.dart';
import '../controller.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainPageController>();
    final appBuilder = Get.find<AppBuilder>();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Obx(() {
      final isProviderMode = appBuilder.isProviderMode.value;
      final isProvider = appBuilder.isProvider.value;

      return Positioned(
        left: 28,
        right: 28,
        bottom: 28 + bottom / 2,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: StyleRepo.darkwhite,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavItems(controller, isProvider, isProviderMode),
          ),
        ),
      );
    });
  }

  List<Widget> _buildNavItems(MainPageController controller, bool isProvider, bool isProviderMode) {
    if (isProvider && isProviderMode) {
      // Provider mode: 4 navigation items
      return [
        _buildNavItem(
          icon: Assets.images.logo.logo,
          label: tr(LocaleKeys.navigation_home),
          isSelected: controller.currentPage.value == 0,
          onTap: () => controller.changePage(0),
        ),
        _buildNavItem(
          icon: Assets.icons.essentials.boxStack,
          label: tr(LocaleKeys.navigation_orders),
          isSelected: controller.currentPage.value == 1,
          onTap: () => controller.changePage(1),
        ),
        _buildNavItem(
          icon: Assets.icons.messages.chat,
          label: tr(LocaleKeys.navigation_chat),
          isSelected: controller.currentPage.value == 2,
          onTap: () => controller.changePage(2),
        ),
        _buildNavItem(
          icon: Assets.icons.essentials.circleUser,
          label: tr(LocaleKeys.navigation_profile),
          isSelected: controller.currentPage.value == 3,
          onTap: () => controller.changePage(3),
        ),
      ];
    } else {
      // User mode: 5 navigation items
      return [
        _buildNavItem(
          icon: Assets.images.logo.logo,
          label: tr(LocaleKeys.navigation_home),
          isSelected: controller.currentPage.value == 0,
          onTap: () => controller.changePage(0),
        ),
        _buildNavItem(
          icon: Assets.icons.essentials.boxStack,
          label: tr(LocaleKeys.navigation_orders),
          isSelected: controller.currentPage.value == 1,
          onTap: () => controller.changePage(1),
        ),
        _buildNavItem(
          icon: Assets.icons.essentials.plus,
          label: tr(LocaleKeys.navigation_services),
          isSelected: controller.currentPage.value == 2,
          onTap: () => controller.changePage(2),
        ),
        _buildNavItem(
          icon: Assets.icons.messages.chat,
          label: tr(LocaleKeys.navigation_chat),
          isSelected: controller.currentPage.value == 3,
          onTap: () => controller.changePage(3),
        ),
        _buildNavItem(
          icon: Assets.icons.essentials.circleUser,
          label: tr(LocaleKeys.navigation_profile),
          isSelected: controller.currentPage.value == 4,
          onTap: () => controller.changePage(4),
        ),
      ];
    }
  }

  Widget _buildNavItem({
    required SvgGenImage icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color iconColor = isSelected ? StyleRepo.deepBlue : StyleRepo.grey;
    final Color textColor = isSelected ? StyleRepo.deepBlue : StyleRepo.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(icon: icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }
}
