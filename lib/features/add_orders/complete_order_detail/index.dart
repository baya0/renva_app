// features/add_orders/sub_orders/add_order_detail/complete_order/index.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/style/repo.dart';
import '../../../../../gen/assets.gen.dart';
import 'controller.dart';

class CompleteOrderPage extends StatelessWidget {
  const CompleteOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteOrderController(), permanent: false);

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      body: SafeArea(child: _buildFormView(controller, context)),
    );
  }

  Widget _buildFormView(CompleteOrderController controller, BuildContext context) {
    return Column(
      children: [
        _buildHeader(controller, context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _buildPriceRangeSection(controller, context),
                const SizedBox(height: 40),
                _buildDescriptionSection(controller, context),
                const SizedBox(height: 35),
                _buildPhotoSection(controller, context),
                const SizedBox(height: 55),
              ],
            ),
          ),
        ),
        _buildDoneButton(controller, context),
      ],
    );
  }

  Widget _buildHeader(CompleteOrderController controller, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Assets.icons.arrows.leftCircle.svg(
                color: StyleRepo.black,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete Your Order',
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection(CompleteOrderController controller, BuildContext context) {
    return Obx(() {
      //  Use subcategory's actual price range as bounds
      double sliderMin = controller.minPrice.toDouble();
      double sliderMax = controller.maxPrice.toDouble();

      // Get current range values
      double currentStart = controller.priceRange.value.start.clamp(sliderMin, sliderMax);
      double currentEnd = controller.priceRange.value.end.clamp(currentStart + 1, sliderMax);

      return Column(
        children: [
          RangeSlider(
            values: RangeValues(currentStart, currentEnd),
            min: sliderMin,
            max: sliderMax,
            divisions: ((sliderMax - sliderMin) / 10).round(),
            labels: RangeLabels('${currentStart.round()}', '${currentEnd.round()}'),
            onChanged: (RangeValues values) {
              controller.updatePriceRange(values);
            },
          ),
          // Show the actual bounds
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('${sliderMin.round()} SYP'), Text('${sliderMax.round()} SYP')],
          ),
        ],
      );
    });
  }

  Widget _buildDescriptionSection(CompleteOrderController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 12),
        Form(
          key: controller.descriptionFormKey,
          child: TextFormField(
            controller: controller.descriptionController,
            validator: controller.validateDescription,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add Description',
              hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: StyleRepo.grey),
              filled: true,
              fillColor: StyleRepo.softWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: StyleRepo.deepBlue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(CompleteOrderController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              if (controller.uploadedPhotos.isNotEmpty) ...[
                //This avoids building an empty ListView when there are no photos.    ? [WidgetA(), WidgetB()] : [],
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.uploadedPhotos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(controller.uploadedPhotos[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removePhoto(index),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (controller.canAddMorePhotos)
                GestureDetector(
                  onTap: controller.addPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: StyleRepo.grey.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.essentials.uplaod.svg(),
                        const SizedBox(width: 8),
                        Text(
                          'Upload Photo',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: StyleRepo.grey, fontSize: 14),
                        ),
                        if (controller.uploadedPhotos.isNotEmpty)
                          Text(
                            '${controller.uploadedPhotos.length}/5 photos',
                            style: TextStyle(fontSize: 12, color: StyleRepo.grey.withOpacity(0.7)),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton(CompleteOrderController controller, context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                (controller.isFormValid.value && !controller.isSubmitting.value)
                    ? controller.submitOrder
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleRepo.deepBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
              disabledBackgroundColor: StyleRepo.grey.withValues(alpha: 0.3),
            ),
            child:
                controller.isSubmitting.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
                      ),
                    )
                    : Text(
                      'Done',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StyleRepo.softWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
