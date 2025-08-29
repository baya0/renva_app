import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/svg_icon.dart';
import '../../../gen/assets.gen.dart';
import '../../home/models/service_categories.dart';
import 'controller.dart';

class AddSubOrderPage extends StatelessWidget {
  const AddSubOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddSubOrderController(), permanent: false);

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

              Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Assets.icons.arrows.leftCircle.svg(
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              StyleRepo.softWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          tr(LocaleKeys.common_back),
                          style: const TextStyle(
                            color: StyleRepo.softWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Column(
                      children: [
                        // Logo and title
                        _buildCentralIcon(),

                        const SizedBox(height: 15.14),
                        // Title and subtitle
                        _buildTitleSection(context),
                        const SizedBox(height: 30),

                        // Subcategories
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: StyleRepo.softWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(36),
                                topRight: Radius.circular(36),
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.zero,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      controller.categoryTitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: StyleRepo.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Service description points
                                  _buildServiceDescription(context),

                                  const SizedBox(height: 20),

                                  Text(
                                    tr(LocaleKeys.orders_choose_subcategory),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: StyleRepo.deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 19),

                                  Expanded(
                                    child: Obx(() {
                                      // Handle empty state
                                      if (controller.subcategories.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(color: StyleRepo.deepBlue),
                                              SizedBox(height: 16),
                                              Text(
                                                'Loading subcategories...',
                                                style: TextStyle(color: StyleRepo.grey),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                              childAspectRatio: 0.85,
                                            ),
                                        itemCount: controller.subcategories.length,
                                        itemBuilder: (context, index) {
                                          final subcategory = controller.subcategories[index];

                                          return Obx(() {
                                            final isSelected =
                                                controller.selectedSubcategory.value?.id ==
                                                subcategory.id;

                                            return GestureDetector(
                                              onTap: () {
                                                controller.selectSubcategory(subcategory);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 64,
                                                      height: 64,

                                                      child: Center(
                                                        child: _buildSubcategoryIcon(
                                                          subcategory,
                                                          isSelected,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Title
                                                    Text(
                                                      subcategory.title,
                                                      style: TextStyle(
                                                        color:
                                                            isSelected
                                                                ? StyleRepo.deepBlue
                                                                : StyleRepo.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }),
                                  ),

                                  const SizedBox(height: 20),

                                  Obx(() {
                                    final canContinue = controller.canContinue;

                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: canContinue ? controller.onContinue : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: StyleRepo.deepBlue,
                                          disabledBackgroundColor: StyleRepo.grey.withValues(
                                            alpha: 0.3,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(38),
                                          ),
                                        ),
                                        child: Text(
                                          tr(LocaleKeys.common_confirm),
                                          style: TextStyle(
                                            color:
                                                canContinue ? StyleRepo.softWhite : StyleRepo.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDescription(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '• Meet your home cleaning needs from A to Z',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: StyleRepo.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '• Commitment to the required deadline',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: StyleRepo.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '• Ensuring complete safety and confidentiality',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: StyleRepo.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubcategoryIcon(SubCategoryModel subcategory, bool isSelected) {
    final color = isSelected ? StyleRepo.deepBlue : StyleRepo.grey;

    // Try to use API SVG first
    if (subcategory.svg.isNotEmpty) {
      return SvgPicture.network(
        subcategory.svg,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) {
          return SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: color, strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(subcategory.title, color);
        },
      );
    } else {
      // Fallback to local assets based on title
      return _buildFallbackIcon(subcategory.title, color);
    }
  }

  Widget _buildFallbackIcon(String title, Color color) {
    switch (title.toLowerCase()) {
      case 'cleaning':
        return Assets.icons.services.house.svg(
          width: 45,
          height: 58,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'washing':
        return SvgIcon(icon: Assets.icons.services.wrench, color: color, size: 45);
      case 'plant care':
        return Icon(Icons.local_florist_outlined, color: color, size: 45);
      case 'pet care':
        return Icon(Icons.pets_outlined, color: color, size: 45);
      case 'car wash':
      case 'cars clean':
      case 'car cleaning':
        return Assets.icons.services.truck.svg(
          width: 45,
          height: 58,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      default:
        return Icon(Icons.category_outlined, color: color, size: 45);
    }
  }

  Widget _buildCentralIcon() {
    return Center(child: Assets.images.background.addOrder.svg(height: 172.86, width: 170));
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Add Order',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: StyleRepo.softWhite,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 23),
        Text(
          'Select Services Type to completed order',
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
}
