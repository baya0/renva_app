import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:renva0/features/add_orders/models/order.dart';

import '../../../core/localization/strings.dart';
import '../../../core/style/repo.dart';
import '../../../core/utils/responsive.dart';
import '../../../gen/assets.gen.dart';
import '../controller.dart';
import '../models/order_model.dart';
import 'rating.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrdersController controller;

  const OrderCard({super.key, required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      constraints: BoxConstraints(
        minHeight: r.value(mobile: 200, tablet: 220, desktop: 240),
        maxHeight: r.value(mobile: 400, tablet: 440, desktop: 480),
        maxWidth: MediaQuery.of(context).size.width - r.space32,
      ),
      margin: EdgeInsets.only(bottom: r.space16),
      decoration: BoxDecoration(
        color: StyleRepo.softGrey.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(r.radius24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          _buildHeader(context),

          // Content Section
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final r = context.responsive;

    return Padding(
      padding: EdgeInsets.fromLTRB(r.space20, 0, r.space20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: Directionality.of(context),
        children: [
          Row(
            textDirection: Directionality.of(context),
            children: [
              Text(
                tr(LocaleKeys.order_card_id_prefix),
                style: TextStyle(
                  fontSize: r.fontSize14,
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.grey,
                ),
              ),
              Text(
                order.id,
                style: TextStyle(
                  fontSize: r.fontSize14,
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              controller.formatDateTime(order),
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: r.fontSize10,
                color: StyleRepo.grey,
              ),
              textAlign: isRTL ? TextAlign.left : TextAlign.right,
            ),
          ),
          _buildOptionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final r = context.responsive;

    return Flexible(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(r.space4 + 2, 0, r.space4 + 2, r.space4 + 3),
        padding: EdgeInsets.all(r.space16),
        decoration: BoxDecoration(
          color: StyleRepo.softWhite,
          borderRadius: BorderRadius.circular(r.radius24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service Info Row
            _buildServiceInfo(context),

            SizedBox(height: r.space8 + 2),
            _buildDivider(context),
            SizedBox(height: r.space8 + 2),

            // Description
            _buildDescription(context),

            SizedBox(height: r.space12 + 1),
            _buildDivider(context),
            SizedBox(height: r.space12),

            // Location Row
            _buildLocation(context),

            // Status-specific content
            _buildStatusSpecificContent(context),

            SizedBox(height: r.space16),

            // Action buttons row
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context) {
    final r = context.responsive;

    return Row(
      children: [
        CircleAvatar(
          radius: r.iconSize20,
          backgroundColor: StyleRepo.deepBlue,
          child: _buildServiceIcon(context),
        ),
        SizedBox(width: r.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.serviceCategory,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: r.fontSize14,
                  color: StyleRepo.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.serviceSubcategory,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: r.fontSize14,
                  color: StyleRepo.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon(BuildContext context) {
    final r = context.responsive;

    if (order.serviceIcon != null && order.serviceIcon!.isNotEmpty) {
      if (order.serviceIcon!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          order.serviceIcon!,
          width: r.iconSize20,
          height: r.iconSize20,
          colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
          placeholderBuilder: (_) => Assets.icons.services.house.svg(
            width: r.iconSize20,
            height: r.iconSize20,
          ),
        );
      } else {
        return ClipOval(
          child: Image.network(
            order.serviceIcon!,
            width: r.iconSize32 + 8,
            height: r.iconSize32 + 8,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Assets.icons.services.house.svg(
              width: r.iconSize20,
              height: r.iconSize20,
            ),
          ),
        );
      }
    }
    return Assets.icons.services.house.svg(width: r.iconSize20, height: r.iconSize20);
  }

  Widget _buildDivider(BuildContext context) {
    final r = context.responsive;
    return Container(
      height: 1,
      width: double.infinity,
      color: StyleRepo.softGrey,
      margin: EdgeInsets.symmetric(horizontal: r.space8),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      order.description,
      style: Theme.of(context).textTheme.labelMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context) {
    final r = context.responsive;

    return Row(
      children: [
        Assets.icons.essentials.locationPin.svg(
          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
          height: r.iconSize16 + 2,
          width: r.iconSize16 + 2,
        ),
        SizedBox(width: r.space4),
        Expanded(
          child: Text(
            order.location,
            style: TextStyle(
              color: StyleRepo.grey,
              fontSize: r.fontSize14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final r = context.responsive;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.viewOfferFromCard(order),
            child: Text(
              (order.offerCount ?? 0) > 0
                  ? LocaleKeys.order_card_view_offer.tr()
                  : LocaleKeys.order_card_view_details.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StyleRepo.deepBlue,
                fontWeight: FontWeight.w500,
                fontSize: r.fontSize14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    final r = context.responsive;

    return PopupMenuButton<String>(
      icon: Assets.icons.essentials.kebabMenu.svg(
        width: r.iconSize16,
        height: r.iconSize16,
        colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius16)),
      onSelected: (value) {
        switch (value) {
          case 'view_details':
            controller.viewOrderDetails(order);
            break;
          case 'cancel_service':
            controller.cancelOrder(order);
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'view_details',
              child: Row(
                textDirection: Directionality.of(context),
                children: [
                  SizedBox(
                    width: r.iconSize20,
                    height: r.iconSize20,
                    child: Assets.icons.essentials.eyeOn.svg(
                      width: r.iconSize16,
                      height: r.iconSize16,
                      colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: r.space12),
                  Text(
                    LocaleKeys.order_card_view_details.tr(),
                    style: TextStyle(
                      color: StyleRepo.black,
                      fontSize: r.fontSize14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (order.status == OrderStatus.pending || order.status == OrderStatus.underway)
              PopupMenuItem<String>(
                value: 'cancel_service',
                child: Row(
                  textDirection: Directionality.of(context),
                  children: [
                    Container(
                      width: r.iconSize20,
                      height: r.iconSize20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(r.radius12),
                        border: Border.all(color: StyleRepo.grey.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Assets.icons.essentials.close.svg(
                          width: r.space12,
                          height: r.space12,
                          colorFilter: ColorFilter.mode(StyleRepo.red, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    SizedBox(width: r.space12),
                    Text(
                      LocaleKeys.order_card_cancel_service.tr(),
                      style: TextStyle(
                        color: StyleRepo.red,
                        fontSize: r.fontSize14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
    );
  }

  Widget _buildStatusSpecificContent(BuildContext context) {
    switch (order.status) {
      case OrderStatus.cancelled:
        return _buildCancelledContent(context);
      case OrderStatus.underway:
        return _buildUnderwayContent(context);
      case OrderStatus.complete:
        return _buildCompleteContent(context);
      case OrderStatus.pending:
      default:
        return _buildPendingContent(context);
    }
  }

  Widget _buildPendingContent(BuildContext context) {
    final r = context.responsive;

    if ((order.offerCount ?? 0) == 0) {
      return SizedBox(height: r.space8);
    }

    final offerCount = order.offerCount ?? 0;
    final offerText =
        offerCount == 1
            ? LocaleKeys.order_card_offers_received_single.tr()
            : LocaleKeys.order_card_offers_received_plural.tr();

    return Column(
      children: [
        SizedBox(height: r.space16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        SizedBox(height: r.space12),
        Row(
          textDirection: Directionality.of(context),
          children: [
            Icon(Icons.local_offer, color: StyleRepo.deepBlue, size: r.iconSize16 + 2),
            SizedBox(width: r.space8),
            Text(
              "$offerCount $offerText",
              style: TextStyle(
                color: StyleRepo.deepBlue,
                fontSize: r.fontSize12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelledContent(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: r.space16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        SizedBox(height: r.space12),
        Row(
          textDirection: Directionality.of(context),
          children: [
            Icon(Icons.cancel, color: StyleRepo.red, size: r.iconSize16),
            SizedBox(width: r.space8),
            Text(
              LocaleKeys.order_card_reason_of_cancellation.tr(),
              style: TextStyle(color: StyleRepo.red, fontSize: r.fontSize12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildProviderAvatar(context),
            SizedBox(width: r.space4),
            Text(
              order.provider?.name ?? LocaleKeys.order_card_unknown_provider.tr(),
              style: TextStyle(color: StyleRepo.grey, fontSize: r.fontSize12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(height: r.space8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.space8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: Directionality.of(context),
            children: [
              Expanded(
                child: Text(
                  order.cancelReason ?? LocaleKeys.order_card_service_provider_cancelled.tr(),
                  style: TextStyle(color: StyleRepo.black, fontSize: r.fontSize12),
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                ),
              ),
              SizedBox(width: r.space8),
              Text(
                controller.formatDateTime(order).toUpperCase(),
                style: TextStyle(color: StyleRepo.red, fontSize: r.fontSize10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnderwayContent(BuildContext context) {
    final r = context.responsive;

    return Column(
      children: [
        SizedBox(height: r.space16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        SizedBox(height: r.space12),
        Row(
          textDirection: Directionality.of(context),
          children: [
            CircleAvatar(
              radius: r.iconSize16,
              backgroundColor: StyleRepo.deepBlue,
              backgroundImage: _getProviderAvatarImage(),
              child: _getProviderAvatarChild(),
            ),
            SizedBox(width: r.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.order_card_service_provider.tr(),
                    style: TextStyle(
                      color: StyleRepo.grey,
                      fontSize: r.fontSize10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    order.provider?.name ?? LocaleKeys.order_card_unknown_provider.tr(),
                    style: TextStyle(
                      color: StyleRepo.black,
                      fontSize: r.fontSize14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget? _getProviderAvatarChild() {
    if (_getProviderAvatarImage() == null) {
      return Assets.icons.essentials.circleUser.svg();
    }
    return null;
  }

  ImageProvider? _getProviderAvatarImage() {
    if (order.provider?.avatar.mediumUrl != null && order.provider!.avatar.mediumUrl.isNotEmpty) {
      return NetworkImage(order.provider!.avatar.mediumUrl);
    }
    return null;
  }

  Widget _buildCompleteContent(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: r.space16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        SizedBox(height: r.space12),
        Row(
          textDirection: Directionality.of(context),
          children: [
            Text(
              LocaleKeys.order_card_rating_and_review.tr(),
              style: TextStyle(color: StyleRepo.black, fontSize: r.fontSize12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildProviderAvatar(context),
            SizedBox(width: r.space4),
            Text(
              order.provider?.name ?? LocaleKeys.order_card_unknown_provider.tr(),
              style: TextStyle(color: StyleRepo.grey, fontSize: r.fontSize12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(height: r.space8),
        _buildRatingContent(context),
      ],
    );
  }

  Widget _buildRatingButton(BuildContext context) {
    final r = context.responsive;

    return GestureDetector(
      onTap: () => _showRatingDialog(context),
      child: Text(
        LocaleKeys.order_card_tap_to_rating.tr(),
        style: TextStyle(
          color: StyleRepo.forestGreen,
          fontSize: r.fontSize12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: StyleRepo.forestGreen,
        ),
      ),
    );
  }

  Widget _buildRatingContent(BuildContext context) {
    // Check if order has been rated
    if (_hasCustomerRating()) {
      // Show completed rating
      return _buildCompletedRating();
    } else {
      // Show rating button
      return _buildRatingButton(context);
    }
  }

  Widget _buildCompletedRating() {
    final rating = _getCustomerRating();
    final reviewText = _getCustomerReviewText();

    return Builder(
      builder: (context) {
        final r = context.responsive;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reviewText, style: TextStyle(color: StyleRepo.black, fontSize: r.fontSize12)),
            const Spacer(flex: 2),
            Row(
              children: List.generate(5, (index) {
                return Assets.icons.essentials.star.svg(
                  width: r.iconSize16,
                  height: r.iconSize16,
                  colorFilter: ColorFilter.mode(
                    index < rating ? Colors.amber : StyleRepo.grey.withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                );
              }),
            ),
          ],
        );
      }
    );
  }

  //Checks if the provider has a valid avatar >>prevents showing a broken image T_T
  Widget _buildProviderAvatar(BuildContext context) {
    final r = context.responsive;
    final hasValidAvatar =
        order.provider?.avatar.mediumUrl != null && order.provider!.avatar.mediumUrl.isNotEmpty;

    return CircleAvatar(
      radius: r.space12,
      backgroundColor: StyleRepo.deepBlue,
      backgroundImage: hasValidAvatar ? NetworkImage(order.provider!.avatar.mediumUrl) : null,
      child: !hasValidAvatar ? Icon(Icons.person, color: Colors.white, size: r.space12) : null,
    );
  }

  // Helper methods using correct field logic
  bool _hasCustomerRating() {
    // Check if we have either a rating text OR a star rating > 0
    bool hasRating =
        (order.customerRating != null && order.customerRating!.isNotEmpty) ||
        (order.customerStarRating != null && order.customerStarRating! > 0);

    return hasRating;
  }

  int _getCustomerRating() {
    final rating = order.customerStarRating ?? 5;

    return rating;
  }

  String _getCustomerReviewText() {
    final text = order.customerRating ?? LocaleKeys.order_card_great_service.tr();
    return text;
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RatingDialog(
          order: order,
          onRatingSubmitted: (rating, reviewText) {
            // Handle the rating submission
            _submitRating(rating, reviewText);
          },
        );
      },
    );
  }

  void _submitRating(int rating, String reviewText) {
    // Call your controller method to submit the rating
    controller.submitOrderRating(order, rating, reviewText);
  }
}
