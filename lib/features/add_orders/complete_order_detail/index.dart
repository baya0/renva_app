import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/localization/strings.dart';

import '../../../../../core/style/repo.dart';
import '../../../../../gen/assets.gen.dart';
import 'controller.dart';

class CompleteOrderPage extends StatelessWidget {
  const CompleteOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteOrderController(), permanent: false);
    final isRTL = context.locale.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      body: SafeArea(child: _buildFormView(controller, context, isRTL, size)),
    );
  }

  Widget _buildFormView(
    CompleteOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      children: [
        _buildHeader(controller, context, isRTL, size),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 26),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 600 : size.width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isTablet ? 60 : 50),
                  _buildPriceRangeSection(controller, context, isRTL, size),
                  SizedBox(height: isTablet ? 50 : 40),
                  _buildDescriptionSection(controller, context, isRTL, size),
                  SizedBox(height: isTablet ? 45 : 35),
                  _buildPhotoSection(controller, context, isRTL, size),
                  SizedBox(height: isTablet ? 70 : 55),
                ],
              ),
            ),
          ),
        ),
        _buildDoneButton(controller, context, size),
      ],
    );
  }

  Widget _buildHeader(
    CompleteOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child:
                  isRTL
                      ? Assets.icons.arrows.rightCircle.svg(
                        color: StyleRepo.black,
                        width: isTablet ? 28 : 24,
                        height: isTablet ? 28 : 24,
                      )
                      : Assets.icons.arrows.leftCircle.svg(
                        color: StyleRepo.black,
                        width: isTablet ? 28 : 24,
                        height: isTablet ? 28 : 24,
                      ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Text(
                tr(LocaleKeys.complete_order_title),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection(
    CompleteOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Obx(() {
      double sliderMin = controller.minPrice.toDouble();
      double sliderMax = controller.maxPrice.toDouble();

      double currentStart = controller.priceRange.value.start.clamp(sliderMin, sliderMax);
      double currentEnd = controller.priceRange.value.end.clamp(currentStart + 1, sliderMax);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.complete_order_price_range),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: StyleRepo.black,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          RangeSlider(
            values: RangeValues(currentStart, currentEnd),
            min: sliderMin,
            max: sliderMax,
            divisions: ((sliderMax - sliderMin) / 10).round(),
            labels: RangeLabels('${currentStart.round()}', '${currentEnd.round()}'),
            onChanged: (RangeValues values) {
              controller.updatePriceRange(values);
            },
            activeColor: StyleRepo.deepBlue,
            inactiveColor: StyleRepo.grey.withOpacity(0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sliderMin.round()} ${tr(LocaleKeys.complete_order_syp_currency)}',
                style: TextStyle(color: StyleRepo.grey, fontSize: isTablet ? 16 : 14),
              ),
              Text(
                '${sliderMax.round()} ${tr(LocaleKeys.complete_order_syp_currency)}',
                style: TextStyle(color: StyleRepo.grey, fontSize: isTablet ? 16 : 14),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDescriptionSection(
    CompleteOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.complete_order_description),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.black,
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Form(
          key: controller.descriptionFormKey,
          child: TextFormField(
            controller: controller.descriptionController,
            validator: controller.validateDescription,
            maxLines: isTablet ? 5 : 4,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: tr(LocaleKeys.complete_order_description_placeholder),
              hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: StyleRepo.grey,
                fontSize: isTablet ? 16 : 14,
              ),
              filled: true,
              fillColor: StyleRepo.softWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
            ),
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(
    CompleteOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.complete_order_upload_photos),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: StyleRepo.black,
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Obx(
          () => Column(
            children: [
              if (controller.uploadedPhotos.isNotEmpty) ...[
                SizedBox(
                  height: isTablet ? 100 : 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.uploadedPhotos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: isTablet ? 100 : 80,
                        height: isTablet ? 100 : 80,
                        margin: EdgeInsets.only(
                          right: isRTL ? 0 : (isTablet ? 12 : 8),
                          left: isRTL ? (isTablet ? 12 : 8) : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                          image: DecorationImage(
                            image: FileImage(controller.uploadedPhotos[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: isRTL ? null : 4,
                              left: isRTL ? 4 : null,
                              child: GestureDetector(
                                onTap: () => controller.removePhoto(index),
                                child: Container(
                                  width: isTablet ? 24 : 20,
                                  height: isTablet ? 24 : 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: isTablet ? 16 : 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),
              ],
              if (controller.canAddMorePhotos)
                GestureDetector(
                  onTap: controller.addPhoto,
                  child: Container(
                    width: double.infinity,
                    height: isTablet ? 140 : 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: StyleRepo.grey.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.essentials.uplaod.svg(
                          width: isTablet ? 32 : 24,
                          height: isTablet ? 32 : 24,
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          tr(LocaleKeys.complete_order_upload_photo),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: StyleRepo.grey,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        if (controller.uploadedPhotos.isNotEmpty) ...[
                          SizedBox(height: isTablet ? 8 : 4),
                          Text(
                            controller.photoCountDisplay,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: StyleRepo.grey.withOpacity(0.7),
                            ),
                          ),
                        ],
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

  Widget _buildDoneButton(CompleteOrderController controller, BuildContext context, Size size) {
    final isTablet = size.width > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 400 : size.width),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed:
                  (controller.isFormValid.value && !controller.isSubmitting.value)
                      ? controller.submitOrder
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleRepo.deepBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 44 : 38),
                ),
                disabledBackgroundColor: StyleRepo.grey.withValues(alpha: 0.3),
              ),
              child:
                  controller.isSubmitting.value
                      ? SizedBox(
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(StyleRepo.softWhite),
                        ),
                      )
                      : Text(
                        tr(LocaleKeys.complete_order_done),
                        style: TextStyle(
                          color: StyleRepo.softWhite,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
