import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/localization/strings.dart';

import '../../../../core/style/repo.dart';
import '../../../../gen/assets.gen.dart';
import 'controller.dart';

class AddOrderDetailsPage extends StatelessWidget {
  const AddOrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddOrderDetailsController(), permanent: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    _buildServiceTypeSection(controller, context),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            _buildContinueButton(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AddOrderDetailsController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Assets.icons.arrows.leftCircle.svg(
                    color: StyleRepo.black,
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  tr(LocaleKeys.common_back),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: StyleRepo.black),
                ),
              ],
            ),
            SizedBox(height: 70),
            Row(
              children: [
                Assets.images.logo.renva.svg(
                  width: double.infinity,
                  height: 90,
                  colorFilter: ColorFilter.mode(
                    StyleRepo.deepBlue.withOpacity(0.1),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSection(AddOrderDetailsController controller, context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Select Service Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: StyleRepo.black),
          ),
          const SizedBox(height: 19),
          const Text(
            'Choose the time and type of service that suits you',
            style: TextStyle(
              fontSize: 16,
              color: StyleRepo.grey,
              fontFamily: 'CustomFont',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 28),
          Obx(
            () => Column(
              children: [
                _buildServiceOption(
                  controller,
                  'As Soon As Possible',
                  controller.selectedServiceType.value == 'As Soon As Possible',
                  context,
                ),
                const SizedBox(height: 16),
                _buildServiceOption(
                  controller,
                  'Specific Date',
                  controller.selectedServiceType.value == 'Specific Date',
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(
    AddOrderDetailsController controller,
    String title,
    bool isSelected,
    context,
  ) {
    return GestureDetector(
      onTap: () => controller.updateServiceType(title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey.withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected ? StyleRepo.deepBlue : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.circle, size: 8, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(AddOrderDetailsController controller, context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed:
              controller.selectedServiceType.value.isNotEmpty
                  ? () => controller.navigateToCompleteOrder()
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleRepo.deepBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
            disabledBackgroundColor: StyleRepo.grey.withValues(alpha: 0.3),
          ),
          child: Text(
            'Continue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: StyleRepo.softWhite,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
