import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class ReviewOfferPage extends StatelessWidget {
  const ReviewOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewOfferController>(
      init: ReviewOfferController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: controller.goBack,
            ),
            title: const Text(
              'View Offer',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
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

                // Action Buttons
                _buildActionButtons(controller, context),
              ],
            ),
          ),
        );
      },
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            GestureDetector(
              onTap: controller.editOffer,
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.grey.shade200,
          child: Icon(Icons.image, color: Colors.grey.shade400, size: 32),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            GestureDetector(
              onTap: controller.editOffer,
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          controller.offerDescription.isNotEmpty
              ? controller.offerDescription
              : 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit, Sed Do Eiusmod Tempor Incididunt Ut Labore Et Dolore Magna Aliqua. Ut Enim Ad Minim Veniam, Quis Nostrud Exercitation',
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            GestureDetector(
              onTap: controller.editOffer,
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          controller.formattedPrice,
          style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w600),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            GestureDetector(
              onTap: controller.editOffer,
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
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
            Text(controller.orderTime, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
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
          onPressed: controller.isSubmitting.value ? null : controller.submitOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            elevation: 0,
          ),
          child:
              controller.isSubmitting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                  : const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
