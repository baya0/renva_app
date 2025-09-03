import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:get/get.dart';

import '../../../../../core/localization/strings.dart';
import '../../../../../core/style/repo.dart';
import '../../../../../gen/assets.gen.dart';
import 'controller.dart';

class ReviewCompletedOrderPage extends StatelessWidget {
  const ReviewCompletedOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewCompletedOrderController(), permanent: false);
    final isRTL = context.locale.languageCode == 'ar';
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller, context, isRTL, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                child: Column(
                  crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: isTablet ? 40 : 30),
                    _buildCategorySection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildPicturesSection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildServiceTypeSection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildDateTimeSection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildDescriptionSection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildPriceRangeSection(controller, context, isRTL, size),
                    SizedBox(height: isTablet ? 50 : 40),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(controller, context, isRTL, size),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ReviewCompletedOrderController controller,
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
              onTap: controller.goBack,
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
                tr(LocaleKeys.orders_view_my_order),
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
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

  Widget _buildCategorySection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.orders_Category),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Text(
          controller.categoryDisplay,
          style: TextStyle(fontSize: isTablet ? 16 : 14, color: StyleRepo.grey),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildPicturesSection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.offer_details_pictures),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 16 : 12),
        if (controller.uploadedPhotos.isNotEmpty)
          SizedBox(
            height: isTablet ? 100 : 80,
            child: ListView.builder(
              scrollDirection: isRTL ? Axis.horizontal : Axis.horizontal,
              reverse: isRTL,
              itemCount:
                  controller.uploadedPhotos.length > 3 ? 3 : controller.uploadedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: isRTL ? 0 : 12, left: isRTL ? 12 : 0),
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
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
                          child: Icon(Icons.image, color: StyleRepo.grey, size: isTablet ? 40 : 30),
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
            height: isTablet ? 100 : 80,
            width: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: StyleRepo.grey.withOpacity(0.1),
            ),
            child: Icon(Icons.image, color: StyleRepo.grey, size: isTablet ? 40 : 30),
          ),
        if (controller.uploadedPhotos.length > 3)
          Padding(
            padding: EdgeInsets.only(top: isTablet ? 10 : 8),
            child: Text(
              controller.photoCountDisplay,
              style: TextStyle(fontSize: isTablet ? 14 : 12, color: StyleRepo.grey),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
      ],
    );
  }

  Widget _buildServiceTypeSection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.orders_services_type),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Text(
          controller.serviceTypeDisplay,
          style: TextStyle(fontSize: isTablet ? 16 : 14, color: StyleRepo.grey),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.offer_details_date_and_time),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: StyleRepo.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                children: [
                  Icon(Icons.calendar_today, size: isTablet ? 20 : 16, color: StyleRepo.grey),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    controller.dateTimeDisplay,
                    style: TextStyle(fontSize: isTablet ? 16 : 14, color: StyleRepo.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.orders_description),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Text(
          controller.descriptionDisplay,
          style: TextStyle(fontSize: isTablet ? 16 : 14, color: StyleRepo.grey, height: 1.4),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.offer_details_price_range),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.black,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Text(
          controller.priceRangeDisplay,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: StyleRepo.deepBlue,
          ),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
    ReviewCompletedOrderController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        children: [
          Expanded(
            child: SizedBox(
              height: isTablet ? 56 : 48,
              child: OutlinedButton(
                onPressed: controller.cancelOrder,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: StyleRepo.grey.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                  ),
                ),
                child: Text(
                  tr(LocaleKeys.common_cancel),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: StyleRepo.grey,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Obx(
              () => SizedBox(
                height: isTablet ? 56 : 48,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StyleRepo.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 28 : 25),
                    ),
                    disabledBackgroundColor: StyleRepo.grey.withOpacity(0.3),
                  ),
                  child:
                      controller.isSubmitting.value
                          ? SizedBox(
                            width: isTablet ? 24 : 20,
                            height: isTablet ? 24 : 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : Text(
                            tr(LocaleKeys.common_confirm),
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
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
