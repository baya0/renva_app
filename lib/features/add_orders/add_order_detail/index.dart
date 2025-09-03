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
    final isRTL = context.locale.languageCode == 'ar';
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller, isRTL, size),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isTablet ? 60 : 40),
                      _buildServiceTypeSection(controller, context, isRTL, size),
                      SizedBox(height: isTablet ? 80 : 60),
                    ],
                  ),
                ),
              ),
            ),
            _buildContinueButton(controller, context, size),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AddOrderDetailsController controller,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24, vertical: 16),
        child: Column(
          children: [
            Row(
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
                SizedBox(width: isTablet ? 16 : 10),
                Text(
                  tr(LocaleKeys.common_back),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: StyleRepo.black,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 80 : 50),
            // Responsive logo
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isTablet ? 120 : 90,
                maxWidth: size.width * 0.8,
              ),
              child: Assets.images.logo.renva.svg(
                height: isTablet ? 120 : 90,
                colorFilter: ColorFilter.mode(StyleRepo.deepBlue.withOpacity(0.1), BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSection(
    AddOrderDetailsController controller,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;
    final isSmallScreen = size.height < 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 500 : size.width),
        child: Column(
          children: [
            // Responsive title
            Text(
              tr(LocaleKeys.add_order_details_select_service_type),
              style: TextStyle(
                fontSize: isTablet ? 28 : (isSmallScreen ? 18 : 20),
                fontWeight: FontWeight.w700,
                color: StyleRepo.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : (isSmallScreen ? 12 : 19)),

            // Responsive subtitle
            Text(
              tr(LocaleKeys.add_order_details_service_type_subtitle),
              style: TextStyle(
                fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                color: StyleRepo.grey,
                fontFamily: 'CustomFont',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 40 : (isSmallScreen ? 20 : 28)),

            // Service options
            Obx(
              () => Column(
                children: [
                  _buildServiceOption(
                    controller,
                    tr(LocaleKeys.add_order_details_as_soon_as_possible),
                    controller.selectedServiceType.value ==
                        tr(LocaleKeys.add_order_details_as_soon_as_possible),
                    context,
                    isRTL,
                    size,
                  ),
                  SizedBox(height: isTablet ? 20 : (isSmallScreen ? 12 : 16)),
                  _buildServiceOption(
                    controller,
                    tr(LocaleKeys.add_order_details_specific_date),
                    controller.selectedServiceType.value ==
                        tr(LocaleKeys.add_order_details_specific_date),
                    context,
                    isRTL,
                    size,
                  ),

                  // Show selected date/time when specific date is chosen
                  if (controller.selectedServiceType.value ==
                          tr(LocaleKeys.add_order_details_specific_date) &&
                      controller.selectedDate.value != null)
                    _buildSelectedDateDisplay(controller, context, size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDisplay(
    AddOrderDetailsController controller,
    BuildContext context,
    Size size,
  ) {
    final isTablet = size.width > 600;
    final isSmallScreen = size.height < 600;

    return Obx(
      () => Container(
        margin: EdgeInsets.only(top: isTablet ? 20 : (isSmallScreen ? 12 : 16)),
        padding: EdgeInsets.all(isTablet ? 20 : (isSmallScreen ? 14 : 16)),
        decoration: BoxDecoration(
          color: StyleRepo.deepBlue.withValues(alpha: 0.05),
          border: Border.all(color: StyleRepo.deepBlue.withValues(alpha: 0.2), width: 1),
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: StyleRepo.deepBlue,
              size: isTablet ? 20 : (isSmallScreen ? 16 : 18),
            ),
            SizedBox(width: isTablet ? 12 : (isSmallScreen ? 8 : 10)),
            Expanded(
              child: Text(
                controller.dateTimeDisplay,
                style: TextStyle(
                  fontSize: isTablet ? 16 : (isSmallScreen ? 13 : 14),
                  fontWeight: FontWeight.w500,
                  color: StyleRepo.deepBlue,
                ),
              ),
            ),
            // edit button to change the date
            GestureDetector(
              onTap:
                  () =>
                      controller.updateServiceType(tr(LocaleKeys.add_order_details_specific_date)),
              child: Icon(
                Icons.edit,
                color: StyleRepo.deepBlue.withOpacity(0.7),
                size: isTablet ? 18 : (isSmallScreen ? 14 : 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(
    AddOrderDetailsController controller,
    String title,
    bool isSelected,
    BuildContext context,
    bool isRTL,
    Size size,
  ) {
    final isTablet = size.width > 600;
    final isSmallScreen = size.height < 600;

    return GestureDetector(
      onTap: () => controller.updateServiceType(title),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: isTablet ? 500 : size.width),
        padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 16 : 20)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(isTablet ? 28 : 22),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 24 : (isSmallScreen ? 18 : 20),
              height: isTablet ? 24 : (isSmallScreen ? 18 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey.withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected ? StyleRepo.deepBlue : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(
                        Icons.circle,
                        size: isTablet ? 10 : (isSmallScreen ? 6 : 8),
                        color: Colors.white,
                      )
                      : null,
            ),
            SizedBox(width: isTablet ? 20 : (isSmallScreen ? 12 : 16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                  fontWeight: FontWeight.w400,
                  color: isSelected ? StyleRepo.deepBlue : StyleRepo.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    AddOrderDetailsController controller,
    BuildContext context,
    Size size,
  ) {
    final isTablet = size.width > 600;
    final isSmallScreen = size.height < 600;

    return Obx(
      () => Container(
        padding: EdgeInsets.all(isTablet ? 32 : (isSmallScreen ? 16 : 24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 400 : size.width),
          child: SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : (isSmallScreen ? 45 : 50),
            child: ElevatedButton(
              onPressed:
                  controller.selectedServiceType.value.isNotEmpty
                      ? () => controller.navigateToCompleteOrder()
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleRepo.deepBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 44 : 38),
                ),
                disabledBackgroundColor: StyleRepo.grey.withValues(alpha: 0.3),
              ),
              child: Text(
                tr(LocaleKeys.common_continue),
                style: TextStyle(
                  color:
                      controller.selectedServiceType.value.isNotEmpty
                          ? StyleRepo.softWhite
                          : StyleRepo.grey,
                  fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
