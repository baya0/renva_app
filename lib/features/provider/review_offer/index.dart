import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/style/repo.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class ReviewOfferPage extends StatelessWidget {
  const ReviewOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewOfferController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Assets.icons.arrows.rightCircle.svg(
            colorBlendMode: BlendMode.srcIn,
            color: StyleRepo.black,
          ),
          onPressed: controller.goBack,
        ),
        title: Text(
          controller.isViewMode ? 'View Offer' : 'Review Offer', // Dynamic title
          style: const TextStyle(color: StyleRepo.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Picture Section
            _buildPictureSection(controller, context),
            const SizedBox(height: 24),

            // Description Section
            _buildDescriptionSection(controller, context),
            const SizedBox(height: 24),

            // Price Range Section
            _buildPriceRangeSection(controller, context),
            const SizedBox(height: 24),

            // Date & Time Section
            _buildDateTimeSection(controller, context),
            const SizedBox(height: 40),

            // Action Buttons - conditional rendering
            if (controller.shouldShowActionButton) _buildActionButtons(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildPictureSection(ReviewOfferController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            // Conditionally show Edit button
            if (controller.showEditButtons)
              GestureDetector(
                onTap: controller.editOffer,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Gallery Images
        if (controller.hasImages)
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    controller.galleryImages.asMap().entries.map((entry) {
                      final image = entry.value;

                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      );
                    }).toList(),
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: Row(
              children: [
                // Default plant images as shown in the original design
                _buildDefaultImage('assets/images/plant1.png'),
                const SizedBox(width: 12),
                _buildDefaultImage('assets/images/plant2.png'),
                const SizedBox(width: 12),
                _buildDefaultImage('assets/images/plant3.png'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultImage(String assetPath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: StyleRepo.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StyleRepo.grey.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: StyleRepo.grey.withValues(alpha: 0.2),
          child: Icon(Icons.image, color: StyleRepo.deepBlue, size: 32),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ReviewOfferController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            // Conditionally show Edit button
            if (controller.showEditButtons)
              GestureDetector(
                onTap: controller.editOffer,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          controller.offerDescription.isNotEmpty ? controller.offerDescription : 'Description',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(ReviewOfferController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            // Conditionally show Edit button
            if (controller.showEditButtons)
              GestureDetector(
                onTap: controller.editOffer,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          controller.formattedPrice,
          style: const TextStyle(
            fontSize: 18,
            color: StyleRepo.deepBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(ReviewOfferController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date & Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            // Conditionally show Edit button
            if (controller.showEditButtons)
              GestureDetector(
                onTap: controller.editOffer,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: StyleRepo.deepBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Date Row
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(controller.orderDate, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 12),

        // Time Row
        Row(
          children: [
            Icon(Icons.access_time_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(controller.orderTime, style: TextStyle(fontSize: 14, color: StyleRepo.grey)),
          ],
        ),
        const SizedBox(height: 12),

        // Execution Time Row
        Row(
          children: [
            Icon(Icons.schedule_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Execution time: ${controller.formattedExecutionTime}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ReviewOfferController controller, BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isSubmitting.value ? null : controller.handleActionButton,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isViewMode ? StyleRepo.deepBlue : const Color(0xFF1E3A8A),
            foregroundColor: StyleRepo.softWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child:
              controller.isSubmitting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: StyleRepo.softWhite, strokeWidth: 2),
                  )
                  : Text(
                    controller.actionButtonText, // Dynamic button text
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ),
    );
  }
}
