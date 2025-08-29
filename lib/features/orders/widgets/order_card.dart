// order_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:renva0/features/add_orders/models/order.dart';

import '../../../core/style/repo.dart';
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
    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: 400,
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StyleRepo.softGrey.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "ID ",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.grey,
                ),
              ),
              Text(
                order.id,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              controller.formatDateTime(order),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 10,
                color: StyleRepo.grey,
              ),
            ),
          ),
          _buildOptionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Flexible(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StyleRepo.softWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service Info Row
            _buildServiceInfo(context),

            const SizedBox(height: 10),
            _buildDivider(),
            const SizedBox(height: 10),

            // Description
            _buildDescription(context),

            const SizedBox(height: 13),
            _buildDivider(),
            const SizedBox(height: 12),

            // Location Row
            _buildLocation(context),

            // Status-specific content
            _buildStatusSpecificContent(context),

            const SizedBox(height: 16),

            // Action buttons row
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20, backgroundColor: StyleRepo.deepBlue, child: _buildServiceIcon()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.serviceCategory,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: StyleRepo.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.serviceSubcategory,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
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

  Widget _buildServiceIcon() {
    if (order.serviceIcon != null && order.serviceIcon!.isNotEmpty) {
      if (order.serviceIcon!.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          order.serviceIcon!,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(StyleRepo.softWhite, BlendMode.srcIn),
          placeholderBuilder: (_) => Assets.icons.services.house.svg(width: 20, height: 20),
        );
      } else {
        return ClipOval(
          child: Image.network(
            order.serviceIcon!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Assets.icons.services.house.svg(width: 20, height: 20),
          ),
        );
      }
    }
    return Assets.icons.services.house.svg(width: 20, height: 20);
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: StyleRepo.softGrey,
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
    return Row(
      children: [
        Assets.icons.essentials.locationPin.svg(
          colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
          height: 18,
          width: 18,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            order.location,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: StyleRepo.grey,
              fontSize: 14,
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
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => controller.viewOrderDetails(order),
            child: Text(
              (order.offerCount ?? 0) > 0 ? "View Offer" : "View Details",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: StyleRepo.deepBlue,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Assets.icons.essentials.kebabMenu.svg(
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    width: 20,
                    height: 20,
                    child: Assets.icons.essentials.eyeOn.svg(
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'View details',
                    style: TextStyle(
                      color: StyleRepo.black,
                      fontSize: 14,
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
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StyleRepo.grey.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Assets.icons.essentials.close.svg(
                          width: 12,
                          height: 12,
                          colorFilter: ColorFilter.mode(StyleRepo.red, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cancel service',
                      style: TextStyle(
                        color: StyleRepo.red,
                        fontSize: 14,
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
    if ((order.offerCount ?? 0) == 0) {
      return const SizedBox(height: 8);
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.local_offer, color: StyleRepo.deepBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              "${order.offerCount} offer${(order.offerCount ?? 0) != 1 ? 's' : ''} received",
              style: TextStyle(
                color: StyleRepo.deepBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelledContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.cancel, color: StyleRepo.red, size: 16),
            const SizedBox(width: 8),
            Text(
              "Reason of cancellation",
              style: TextStyle(color: StyleRepo.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildProviderAvatar(),
            const SizedBox(width: 4),
            Text(
              order.provider?.name ?? "Unknown Provider",
              style: TextStyle(color: StyleRepo.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.cancelReason ?? "The service provider cancelled the order",
                style: TextStyle(color: StyleRepo.black, fontSize: 12),
              ),

              Text(
                controller.formatDateTime(order).toUpperCase(),
                style: TextStyle(color: StyleRepo.red, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnderwayContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),

        // Provider Info Row
        Row(
          children: [
            // Provider Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: StyleRepo.deepBlue,
              backgroundImage: _getProviderAvatarImage(),
              child: _getProviderAvatarChild(),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Service Provider",
                    style: TextStyle(
                      color: StyleRepo.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    order.provider?.name ?? "Unknown Provider",
                    style: TextStyle(
                      color: StyleRepo.black,
                      fontSize: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),

        // Header Row
        Row(
          children: [
            Text(
              "Rating & Review",
              style: TextStyle(color: StyleRepo.black, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _buildProviderAvatar(),
            const SizedBox(width: 4),
            Text(
              order.provider?.name ?? "Unknown Provider",
              style: TextStyle(color: StyleRepo.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dynamic Content :D Show rating interface OR completed rating
        _buildRatingContent(context),
      ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(reviewText, style: TextStyle(color: StyleRepo.black, fontSize: 12)),
        Spacer(flex: 2),
        Row(
          children: List.generate(5, (index) {
            return Assets.icons.essentials.star.svg(
              width: 16,
              height: 16,
              color: index < rating ? Colors.amber : StyleRepo.grey.withOpacity(0.3),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRatingButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRatingDialog(context),
      child: Text(
        "Top to rating please",
        style: TextStyle(
          color: StyleRepo.forestGreen,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: StyleRepo.forestGreen,
        ),
      ),
    );
  }

  //Checks if the provider has a valid avatar >>prevents showing a broken image T_T
  Widget _buildProviderAvatar() {
    final hasValidAvatar =
        order.provider?.avatar.mediumUrl != null && order.provider!.avatar.mediumUrl.isNotEmpty;

    return CircleAvatar(
      radius: 12,
      backgroundColor: StyleRepo.deepBlue,
      backgroundImage: hasValidAvatar ? NetworkImage(order.provider!.avatar.mediumUrl) : null,
      child: !hasValidAvatar ? Icon(Icons.person, color: Colors.white, size: 12) : null,
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
    final text = order.customerRating ?? "Great service!";
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
