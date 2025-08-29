import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/style/repo.dart';
import '../../../../../gen/assets.gen.dart';
import 'controller.dart';

class ReviewCompletedOrderPage extends StatelessWidget {
  const ReviewCompletedOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewCompletedOrderController(), permanent: false);

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller, context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildCategorySection(controller),
                    const SizedBox(height: 24),
                    _buildPicturesSection(controller),
                    const SizedBox(height: 24),
                    _buildServiceTypeSection(controller),
                    const SizedBox(height: 24),
                    _buildDateTimeSection(controller),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(controller),
                    const SizedBox(height: 24),
                    _buildPriceRangeSection(controller),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReviewCompletedOrderController controller, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.goBack,
              child: Assets.icons.arrows.leftCircle.svg(
                color: StyleRepo.black,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'View Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: StyleRepo.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        Text(
          controller.subcategoryTitle.isNotEmpty
              ? controller.subcategoryTitle
              : controller.categoryTitle,
          style: const TextStyle(fontSize: 14, color: StyleRepo.grey),
        ),
      ],
    );
  }

  Widget _buildPicturesSection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Picture',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 12),
        if (controller.uploadedPhotos.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.uploadedPhotos.length > 3 ? 3 : controller.uploadedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: StyleRepo.grey.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      controller.uploadedPhotos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: StyleRepo.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image, color: StyleRepo.grey, size: 30),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: StyleRepo.grey.withOpacity(0.1),
            ),
            child: const Icon(Icons.image, color: StyleRepo.grey, size: 30),
          ),
      ],
    );
  }

  Widget _buildServiceTypeSection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        Text(
          controller.serviceTypeDisplay,
          style: const TextStyle(fontSize: 14, color: StyleRepo.grey),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: StyleRepo.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: StyleRepo.grey),
                  const SizedBox(width: 8),
                  Text(
                    controller.dateTimeDisplay,
                    style: const TextStyle(fontSize: 14, color: StyleRepo.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        Text(
          controller.description.isNotEmpty ? controller.description : 'No description provided',
          style: const TextStyle(fontSize: 14, color: StyleRepo.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(ReviewCompletedOrderController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
        ),
        const SizedBox(height: 8),
        Text(
          '${controller.priceRange.start.round()} - ${controller.priceRange.end.round()} SEK',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.deepBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(ReviewCompletedOrderController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),

      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: controller.cancelOrder,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: StyleRepo.grey.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StyleRepo.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StyleRepo.forestGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    disabledBackgroundColor: StyleRepo.grey.withValues(alpha: 0.3),
                  ),
                  child:
                      controller.isSubmitting.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
