import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:get/get.dart';
import 'package:renva0/features/orders/models/order_model.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../../gen/assets.gen.dart';
import '../models/offer_model.dart';

class OfferDetailsPage extends StatelessWidget {
  const OfferDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isRTL = context.locale.languageCode == 'ar';

    // Get the offer and order data passed from navigation
    final dynamic offerData = Get.arguments['offer'] ?? Get.arguments;
    final OrderModel? order = Get.arguments['order'];

    late OfferModel offer;

    // Handle different data types
    if (offerData is OfferModel) {
      offer = offerData;
    } else if (offerData is Map<String, dynamic>) {
      offer = OfferModel.fromJson(offerData);
    } else {
      // Handle the case where data comes from API response
      final List<dynamic> offers = Get.arguments['offers'] ?? [];
      if (offers.isNotEmpty) {
        offer = OfferModel.fromJson(offers.first);
      } else {
        // Fallback - go back if no data
        Get.back();
        return Container();
      }
    }

    return Directionality(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Transform.flip(
              flipX: isRTL,
              child: Assets.icons.arrows.leftCircle.svg(
                colorFilter: ColorFilter.mode(StyleRepo.black, BlendMode.srcIn),
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            tr(LocaleKeys.offer_details_view_offer),
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // Provider Info Section
              _buildProviderInfo(offer, isRTL),
              const SizedBox(height: 24),

              // Pictures Section
              _buildPicturesSection(offer, isRTL),
              const SizedBox(height: 24),

              // Description Section
              _buildDescriptionSection(offer, isRTL),
              const SizedBox(height: 24),

              // Price Range Section
              _buildPriceSection(offer, isRTL),
              const SizedBox(height: 24),

              // Date & Time Section
              _buildDateTimeSection(offer, isRTL),

              const Spacer(),

              // Action Buttons
              _buildActionButtons(offer, order, isRTL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfo(OfferModel offer, bool isRTL) {
    return Row(
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      children: [
        // Provider Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: StyleRepo.deepBlue,
          backgroundImage:
              offer.providerImage != null && offer.providerImage!.isNotEmpty
                  ? NetworkImage(offer.providerImage!)
                  : null,
          child:
              offer.providerImage == null || offer.providerImage!.isEmpty
                  ? Icon(Icons.person, color: Colors.white, size: 24)
                  : null,
        ),
        const SizedBox(width: 12),

        // Provider Details
        Expanded(
          child: Column(
            crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                children: [
                  Text(
                    offer.providerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatOfferCreatedAt(offer.createdAt, isRTL),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                children: [
                  // Star Rating (always LTR)
                  Row(
                    textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color:
                            index < offer.providerRating.floor()
                                ? StyleRepo.amber
                                : StyleRepo.grey.withValues(alpha: 0.5),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRTL
                        ? '${tr(LocaleKeys.offer_details_reviews)} ${offer.reviewCount}'
                        : '${offer.reviewCount} ${tr(LocaleKeys.offer_details_reviews)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPicturesSection(OfferModel offer, bool isRTL) {
    List<String> imageUrls = offer.images ?? [];

    // If no images, don't show the section at all
    if (imageUrls.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.offer_details_pictures),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: isRTL, // Reverse scroll direction for RTL
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return GestureDetector(
                onTap: () => _showImageFullScreen(context, imageUrl, isRTL),
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(right: isRTL ? 0 : 12, left: isRTL ? 12 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey.shade400, size: 32);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showImageFullScreen(BuildContext context, String imageUrl, bool isRTL) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.9), // خلفية شفافة
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Stack(
            children: [
              Center(
                child: Hero(
                  // Hero Animation modern
                  tag: imageUrl,
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: isRTL ? null : 20,
                left: isRTL ? 20 : null,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  tooltip: "Close",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection(OfferModel offer, bool isRTL) {
    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.offer_details_description),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          offer.description.isNotEmpty
              ? offer.description
              : tr(LocaleKeys.offer_details_default_description),
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildPriceSection(OfferModel offer, bool isRTL) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
      children: [
        Text(
          tr(LocaleKeys.offer_details_price_range),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        Text(
          isRTL
              ? '${tr(LocaleKeys.offer_details_currency_sek)} ${offer.price.toStringAsFixed(0)}'
              : '${offer.price.toStringAsFixed(0)} ${tr(LocaleKeys.offer_details_currency_sek)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.deepBlue),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(OfferModel offer, bool isRTL) {
    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          tr(LocaleKeys.offer_details_date_and_time),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 12),
        Row(
          textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              _formatDate(offer.createdAt, isRTL),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              _formatTime(offer.createdAt, isRTL),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(OfferModel offer, OrderModel? order, bool isRTL) {
    return Column(
      children: [
        Row(
          textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
          children: [
            // Delete Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _declineOffer(offer, order!, isRTL),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    tr(LocaleKeys.offer_details_delete),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Accept Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _acceptOffer(offer, order, isRTL),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    tr(LocaleKeys.offer_details_accept),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for formatting dates and times
  String _formatDate(DateTime dateTime, bool isRTL) {
    // Use localized date formatting if possible
    return DateFormat('dd - MMM - yyyy', isRTL ? 'ar' : 'en').format(dateTime);
  }

  String _formatTime(DateTime dateTime, bool isRTL) {
    return DateFormat('HH : mm a', isRTL ? 'ar' : 'en').format(dateTime);
  }

  // Format when the offer was created (for next to rating)
  String _formatOfferCreatedAt(DateTime createdAt, bool isRTL) {
    final formattedDate = DateFormat('dd MMM', isRTL ? 'ar' : 'en').format(createdAt);
    final formattedTime = DateFormat('hh:mm a', isRTL ? 'ar' : 'en').format(createdAt);

    return isRTL
        ? '$formattedTime ${tr(LocaleKeys.offer_details_created_at)} $formattedDate'
        : '$formattedDate ${tr(LocaleKeys.offer_details_created_at)} $formattedTime';
  }

  void _acceptOffer(OfferModel offer, OrderModel? order, bool isRTL) {
    Get.dialog(
      Directionality(
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            tr(LocaleKeys.offer_details_accept_offer),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          content: Text(
            tr(
              LocaleKeys.offer_details_accept_offer_confirmation,
              namedArgs: {"providerName": offer.providerName},
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          actions: [
            Row(
              textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    tr(LocaleKeys.offer_details_cancel),
                    style: TextStyle(color: StyleRepo.lavender),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to orders page
                    _performAcceptOffer(offer, order);
                  },
                  child: Text(
                    tr(LocaleKeys.offer_details_accept),
                    style: TextStyle(color: StyleRepo.forestGreen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _declineOffer(OfferModel offer, OrderModel order, bool isRTL) {
    Get.dialog(
      Directionality(
        textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
        child: AlertDialog(
          title: Text(
            tr(LocaleKeys.offer_details_delete_offer),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          content: Text(
            tr(LocaleKeys.offer_details_delete_offer_confirmation),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          actions: [
            Row(
              textDirection: isRTL ? flutter.TextDirection.rtl : flutter.TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    tr(LocaleKeys.offer_details_cancel),
                    style: TextStyle(color: StyleRepo.lavender),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Close bottom sheet
                    _performDeletOffer(offer, order);
                  },
                  child: Text(
                    tr(LocaleKeys.offer_details_delete),
                    style: TextStyle(color: StyleRepo.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add the missing _performDeletOffer method
void _performDeletOffer(OfferModel offer, OrderModel order) {
  _performDeclineOffer(offer, order);
}

// API call for accepting offer
Future<void> _performAcceptOffer(OfferModel offer, OrderModel? order) async {
  try {
    PopUpToast.show(tr(LocaleKeys.offer_details_accepting_offer));

    final response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.accept_offer,
        method: RequestMethod.Post,
        body: {'offer_id': offer.id, 'order_id': order?.id},
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success) {
      String successMessage =
          response.message.isNotEmpty
              ? response.message
              : tr(LocaleKeys.offer_details_accept_success);

      PopUpToast.show(successMessage);

      // Go back to orders page with success
      Get.back();
    } else {
      String errorMessage =
          response.message.isNotEmpty
              ? response.message
              : tr(LocaleKeys.offer_details_accept_failed);

      PopUpToast.show(errorMessage);
    }
  } catch (e) {
    print('Error accepting offer: $e');
    PopUpToast.show(tr(LocaleKeys.offer_details_network_error));
  }
}

// API call for declining offer
Future<void> _performDeclineOffer(OfferModel offer, OrderModel? order) async {
  try {
    PopUpToast.show(tr(LocaleKeys.offer_details_declining_offer));

    final response = await APIService.instance.request(
      Request(
        endPoint: EndPoints.decline_offer,
        method: RequestMethod.Post,
        body: {'offer_id': offer.id, 'order_id': order?.id},
        copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    if (response.success) {
      String successMessage =
          response.message.isNotEmpty
              ? response.message
              : tr(LocaleKeys.offer_details_decline_success);

      PopUpToast.show(successMessage);

      // Go back to orders page
      Get.back();
    } else {
      String errorMessage =
          response.message.isNotEmpty
              ? response.message
              : tr(LocaleKeys.offer_details_decline_failed);

      PopUpToast.show(errorMessage);
    }
  } catch (e) {
    print('Error declining offer: $e');
    PopUpToast.show(tr(LocaleKeys.offer_details_network_error));
  }
}
