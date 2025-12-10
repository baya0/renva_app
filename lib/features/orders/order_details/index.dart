import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:renva0/core/localization/strings.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/core/utils/responsive.dart';
import 'package:renva0/features/add_orders/models/order.dart';
import 'package:renva0/features/orders/controller.dart';
import 'package:renva0/features/orders/models/order_model.dart';
import 'package:renva0/gen/assets.gen.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      appBar: AppBar(
        backgroundColor: StyleRepo.softWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: StyleRepo.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr(LocaleKeys.orders_order_details),
          style: TextStyle(color: StyleRepo.black, fontSize: r.fontSize20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(r.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and Date
            _buildOrderHeader(context),
            SizedBox(height: r.space24),

            // Service Category & Subcategory
            _buildServiceInfo(context),
            SizedBox(height: r.space24),

            // Description
            _buildDescriptionSection(context),
            SizedBox(height: r.space24),

            // Location
            _buildLocationSection(context),
            SizedBox(height: r.space24),

            // Date & Time
            _buildDateTimeSection(context),
            SizedBox(height: r.space24),

            // Price Range (if available)
            if (order.minPrice != null && order.maxPrice != null) _buildPriceSection(context),

            // Status
            _buildStatusSection(context),
            SizedBox(height: r.space24),

            // Offer Count (for pending orders)
            if (order.status == OrderStatus.pending && order.offerCount != null)
              _buildOfferCountSection(context),

            // Service Provider Info (for underway/complete orders)
            if (order.status != OrderStatus.pending && order.provider != null)
              _buildProviderSection(context),

            // Cancel Reason (for cancelled orders)
            if (order.status == OrderStatus.cancelled && order.cancelReason != null)
              _buildCancelReasonSection(context),

            SizedBox(height: r.space32),

            // Action Buttons
            _buildActionButtons(context),
            SizedBox(height: r.space20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final r = context.responsive;

    return Container(
      padding: EdgeInsets.all(r.space16),
      decoration: BoxDecoration(
        color: StyleRepo.softGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(r.radius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr(LocaleKeys.orders_order_id)}: #${order.id}',
                style: TextStyle(
                  fontSize: r.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: StyleRepo.deepBlue,
                ),
              ),
              SizedBox(height: r.space4),
              Text(
                _formatDateTime(order.dateTime),
                style: TextStyle(fontSize: r.fontSize12, color: StyleRepo.grey),
              ),
            ],
          ),
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final r = context.responsive;
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = StyleRepo.amber;
        statusText = tr(LocaleKeys.orders_pending);
        break;
      case OrderStatus.underway:
        statusColor = StyleRepo.deepBlue;
        statusText = tr(LocaleKeys.orders_underway);
        break;
      case OrderStatus.complete:
        statusColor = StyleRepo.forestGreen;
        statusText = tr(LocaleKeys.orders_complete);
        break;
      case OrderStatus.cancelled:
        statusColor = StyleRepo.red;
        statusText = tr(LocaleKeys.orders_cancelled);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.space12, vertical: r.space4 + 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(r.radius20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: statusColor, fontSize: r.fontSize12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.orders_service),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Row(
            children: [
              if (order.serviceIcon != null && order.serviceIcon!.isNotEmpty)
                Container(
                  width: r.iconSize48,
                  height: r.iconSize48,
                  padding: EdgeInsets.all(r.space12),
                  decoration: BoxDecoration(
                    color: StyleRepo.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(r.radius12),
                  ),
                  child: SvgPicture.string(
                    order.serviceIcon!,
                    colorFilter: ColorFilter.mode(StyleRepo.deepBlue, BlendMode.srcIn),
                  ),
                ),
              SizedBox(width: r.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.serviceCategory,
                      style: TextStyle(
                        fontSize: r.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                    ),
                    SizedBox(height: r.space4),
                    Text(
                      order.serviceSubcategory,
                      style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.orders_description),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Text(
            order.description,
            style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.black, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.orders_location),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: StyleRepo.deepBlue, size: r.iconSize20),
              SizedBox(width: r.space8),
              Expanded(
                child: Text(order.location, style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.black)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.orders_order_date),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: StyleRepo.deepBlue, size: r.iconSize20),
              SizedBox(width: r.space8),
              Text(
                _formatDateTime(order.dateTime),
                style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.offer_details_price_range),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Row(
            children: [
              Assets.icons.services.coins.svg(
                width: r.iconSize20,
                height: r.iconSize20,
                colorFilter: ColorFilter.mode(StyleRepo.deepBlue, BlendMode.srcIn),
              ),
              SizedBox(width: r.space8),
              Text(
                '${order.minPrice} - ${order.maxPrice} ${tr(LocaleKeys.complete_order_syp_currency)}',
                style: TextStyle(
                  fontSize: r.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: StyleRepo.deepBlue,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.space24),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.orders_status),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildOfferCountSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: r.space16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.deepBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.deepBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: StyleRepo.deepBlue, size: r.iconSize24),
              SizedBox(width: r.space12),
              Expanded(
                child: Text(
                  order.offerCount == 1
                      ? tr(
                        LocaleKeys.order_card_offers_received_single,
                      ).replaceAll('{count}', '${order.offerCount}')
                      : tr(
                        LocaleKeys.order_card_offers_received_plural,
                      ).replaceAll('{count}', '${order.offerCount}'),
                  style: TextStyle(
                    fontSize: r.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: StyleRepo.deepBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    final r = context.responsive;
    final provider = order.provider!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: r.space16),
        Text(
          tr(LocaleKeys.orders_service_provider),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.softWhite,
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.softGrey),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: r.iconSize24,
                backgroundImage:
                    provider.avatar.mediumUrl.isNotEmpty
                        ? NetworkImage(provider.avatar.mediumUrl)
                        : null,
                child:
                    provider.avatar.mediumUrl.isEmpty
                        ? Icon(Icons.person, color: StyleRepo.grey)
                        : null,
              ),
              SizedBox(width: r.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: TextStyle(
                        fontSize: r.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: StyleRepo.amber, size: r.iconSize16),
                        SizedBox(width: r.space4),
                        Text(
                          '${provider.rate}',
                          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelReasonSection(BuildContext context) {
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: r.space16),
        Text(
          tr(LocaleKeys.order_card_reason_of_cancellation),
          style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: r.space8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.space16),
          decoration: BoxDecoration(
            color: StyleRepo.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(r.radius12),
            border: Border.all(color: StyleRepo.red.withValues(alpha: 0.3)),
          ),
          child: Text(order.cancelReason!, style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.red)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final r = context.responsive;

    return Column(
      children: [
        // View Offers Button (for pending orders with offers)
        if (order.status == OrderStatus.pending &&
            order.offerCount != null &&
            order.offerCount! > 0)
          SizedBox(
            width: double.infinity,
            height: r.buttonHeightLarge - 6,
            child: ElevatedButton(
              onPressed: () {
                // Get the orders controller and show offers dialog
                final controller = Get.find<OrdersController>();
                controller.showOffersDialog(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleRepo.forestGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius12)),
              ),
              child: Text(
                '${tr(LocaleKeys.orders_offers)} (${order.offerCount})',
                style: TextStyle(
                  fontSize: r.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: StyleRepo.darkwhite,
                ),
              ),
            ),
          ),

        // Cancel Order Button (for pending/underway orders)
        if (order.status == OrderStatus.pending || order.status == OrderStatus.underway) ...[
          if (order.status == OrderStatus.pending &&
              order.offerCount != null &&
              order.offerCount! > 0)
            SizedBox(height: r.space12),
          SizedBox(
            width: double.infinity,
            height: r.buttonHeightLarge - 6,
            child: OutlinedButton(
              onPressed: () {
                // Get the orders controller and cancel the order
                final controller = Get.find<OrdersController>();
                Get.back(); // Go back first
                controller.cancelOrder(order);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: StyleRepo.red, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius12)),
              ),
              child: Text(
                tr(LocaleKeys.orders_cancel_order),
                style: TextStyle(fontSize: r.fontSize16, fontWeight: FontWeight.w600, color: StyleRepo.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('HH:mm');
    final timeString = timeFormat.format(dateTime);

    if (dateToCheck == today) {
      return '${tr(LocaleKeys.orders_today_at)} $timeString';
    } else if (dateToCheck == yesterday) {
      return '${tr(LocaleKeys.orders_yesterday_at)} $timeString';
    } else {
      final dateFormat = DateFormat('dd/MM/yyyy');
      return '${dateFormat.format(dateTime)} $timeString';
    }
  }
}
