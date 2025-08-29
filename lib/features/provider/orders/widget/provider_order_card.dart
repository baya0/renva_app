// widgets/provider_order_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/features/provider/orders/controller.dart';
import 'package:renva0/features/provider/orders/models/provider_model.dart';
import 'package:renva0/gen/assets.gen.dart';

import '../../../../core/widgets/modern_toast.dart';

class ProviderOrderCard extends StatelessWidget {
  final ProviderOrderModel order;
  final ProviderOrdersController controller;
  final bool showCompleteButton;

  const ProviderOrderCard({
    super.key,
    required this.order,
    required this.controller,
    this.showCompleteButton = false,
  });

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
        children: [_buildHeader(context), _buildContent(context)],
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
                '${order.id}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StyleRepo.black,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              _formatDate(order.date, order.startAt),
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
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StyleRepo.softWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCustomerInfo(context),
            const SizedBox(height: 10),
            _buildDivider(),
            const SizedBox(height: 10),
            _buildDescription(context),
            const SizedBox(height: 13),
            _buildDivider(),
            const SizedBox(height: 12),
            _buildLocation(context),
            _buildStatusSpecificContent(context),
            _buildActionButton(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: StyleRepo.deepBlue,
          backgroundImage:
              order.customer['avatar'] != null && order.customer['avatar']['original_url'] != null
                  ? NetworkImage(order.customer['avatar']['original_url'])
                  : null,
          child:
              order.customer['avatar'] == null
                  ? Icon(Icons.person, color: StyleRepo.softWhite, size: 20)
                  : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${order.customer['first_name'] ?? ''} ${order.customer['last_name'] ?? ''}'.trim(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: StyleRepo.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.category['title'] ?? 'Services',
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
            order.address['title'] ?? 'No address',
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

  Widget _buildActionButton(BuildContext context, ProviderOrderModel order) {
    final actionText = _getMainActionText(order);

    if (actionText.isEmpty) {
      return const SizedBox.shrink(); // no button if not pending
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _handleMainAction(order, controller),
            child: Text(
              actionText,
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

  // ✅ UPDATED _buildOptionsMenu method in provider_order_card.dart

  Widget _buildOptionsMenu(BuildContext context) {
    // ✅ Get current tab to show different menu options
    final currentTab = controller.selectedTabIndex.value;

    return PopupMenuButton<String>(
      icon: Assets.icons.essentials.kebabMenu.svg(height: 16, width: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'details') {
          controller.viewOrderDetails(order);
        } else if (value == 'delete') {
          _showDeleteOfferConfirmation(order); // Delete offer (Pending tab)
        } else if (value == 'cancel') {
          _showCancelOfferConfirmation(order); // Cancel offer (Underway tab)
        }
      },
      itemBuilder: (context) {
        List<PopupMenuItem<String>> items = [];

        // ✅ Always show "View Details"
        items.add(
          PopupMenuItem(
            value: 'details',
            child: Row(
              children: [
                Assets.icons.essentials.eyeOn.svg(
                  colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                  height: 14,
                  width: 14,
                ),
                SizedBox(width: 8),
                Text(
                  'View details',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: StyleRepo.black,
                  ),
                ),
              ],
            ),
          ),
        );

        // ✅ Show different options based on current tab
        switch (currentTab) {
          case 0: // Pending tab - show "Delete Offer"
            items.add(
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Assets.icons.essentials.trashAlt.svg(
                      colorFilter: ColorFilter.mode(StyleRepo.red, BlendMode.srcIn),
                      height: 18,
                      width: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete offer',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: StyleRepo.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
            break;

          case 1: // Underway tab - show "Cancel Offer"
            items.add(
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Assets.icons.essentials.close.svg(
                      colorFilter: ColorFilter.mode(StyleRepo.red, BlendMode.srcIn),
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cancel offer',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: StyleRepo.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
            break;

          // Complete and Cancelled tabs - only show details (no actions)
          case 2:
          case 3:
          default:
            break;
        }

        return items;
      },
    );
  }

  // ✅ Separate methods for delete vs cancel

  void _showDeleteOfferConfirmation(ProviderOrderModel order) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Assets.icons.essentials.close.svg(
                  colorBlendMode: BlendMode.srcIn,
                  color: StyleRepo.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Assets.icons.essentials.trashGroup.svg(width: 100, height: 100),
            const SizedBox(height: 16),
            Text(
              'Delete Offer?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            const SizedBox(height: 8),
            Text(
              'This will permanently remove your offer from this order.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: StyleRepo.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: StyleRepo.paleLavender,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StyleRepo.lavender,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteOffer(order.providerOffer!.id); // Delete offer directly
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.softRed,
                      side: BorderSide(color: StyleRepo.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCancelOfferConfirmation(ProviderOrderModel order) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Assets.icons.essentials.close.svg(
                  colorBlendMode: BlendMode.srcIn,
                  color: StyleRepo.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Assets.icons.essentials.close.svg(width: 100, height: 100, color: StyleRepo.red),
            const SizedBox(height: 16),
            Text(
              'Cancel Offer?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to provide a reason for cancelling this offer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: StyleRepo.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: StyleRepo.paleLavender,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Keep Offer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StyleRepo.lavender,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showCancelReasonBottomSheet(order); // Show cancel reasons from API
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.softRed,
                      side: BorderSide(color: StyleRepo.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel Offer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Status-specific content methods
  Widget _buildStatusSpecificContent(BuildContext context) {
    // ✅ Use the controller's selected tab to determine which content to show
    // This ensures content matches the tab the user is viewing
    switch (controller.selectedTabIndex.value) {
      case 0: // Pending tab
        return _buildPendingContent();
      case 1: // Underway tab
        return _buildUnderwayContent();
      case 2: // Complete tab
        return _buildCompleteContent();
      case 3: // Cancelled tab
        return _buildCancelledContent();
      default:
        return _buildPendingContent();
    }
  }

  Widget _buildPendingContent() {
    if (order.providerOffer == null) {
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
            Expanded(
              child: Text(
                'Your offer: \$${order.providerOffer!.price} • ${_getOfferStatusText(order.providerOffer!.status)}',
                style: TextStyle(
                  color: StyleRepo.deepBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelledContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),
        Row(
          children: [
            Assets.icons.essentials.close.svg(width: 16, height: 16),
            const SizedBox(width: 8),
            Text(
              "Order cancelled",
              style: TextStyle(color: StyleRepo.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 12,
              backgroundColor: StyleRepo.deepBlue,
              child: Icon(Icons.person, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 4),
            Text("Customer", style: TextStyle(color: StyleRepo.grey, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Order was cancelled by customer",
          style: TextStyle(color: StyleRepo.black, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUnderwayContent() {
    return Column(children: [if (order.canComplete) _buildCompleteButton()]);
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () => ElevatedButton(
            onPressed:
                controller.isOrderCompleting(order.id)
                    ? null
                    : () => controller.completeOrder(order),
            child:
                controller.isOrderCompleting(order.id)
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Complete Order'),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(height: 1, width: double.infinity, color: StyleRepo.softGrey),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              "Order Completed",
              style: TextStyle(color: StyleRepo.black, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 4),
            Text("Success", style: TextStyle(color: StyleRepo.grey, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Order completed successfully",
          style: TextStyle(color: StyleRepo.black, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(Icons.star, color: Colors.amber, size: 16);
          }),
        ),
      ],
    );
  }

  // Helper methods
  String _formatDate(String date, String? time) {
    try {
      final dateTime = DateTime.parse(date);
      final formattedDate = DateFormat('dd MMM').format(dateTime);

      if (time != null && time.isNotEmpty) {
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$formattedDate ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      }

      return formattedDate;
    } catch (e) {
      return date;
    }
  }

  String _getMainActionText(ProviderOrderModel order) {
    return order.getProviderOrderStatus() == 'pending' ? "View Offers" : "";
  }

  void _handleMainAction(ProviderOrderModel order, ProviderOrdersController controller) {
    controller.viewOrderDetails(order);
  }

  String _getOfferStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Pending';
      case 'declined':
        return 'Declined';
      default:
        return status;
    }
  }

  void deleteOffer(ProviderOrderModel order) {
    showDeleteConfirmationDialog(order);
  }

  void showDeleteConfirmationDialog(ProviderOrderModel order) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Assets.icons.essentials.close.svg(
                  colorBlendMode: BlendMode.srcIn,
                  color: StyleRepo.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Assets.icons.essentials.trashGroup.svg(width: 100, height: 100),
            const SizedBox(height: 16),
            Text(
              'Are You Sure you want to Delete this Offer ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: StyleRepo.paleLavender,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StyleRepo.lavender,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showCancelReasonBottomSheet(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.softRed,
                      side: BorderSide(color: StyleRepo.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showCancelReasonBottomSheet(ProviderOrderModel order) {
    // ✅ Fetch cancel reasons from API when bottom sheet opens
    controller.fetchCancelReasons();

    int selectedReasonId = 0;
    String customReason = '';
    final TextEditingController customReasonController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reason for Cancellation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                        child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Please specify the reason for cancelling this offer',
                  style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                ),
                const SizedBox(height: 24),

                // ✅ Dynamic reasons from API with better error handling
                Obx(() {
                  if (controller.isLoadingReasons.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: StyleRepo.deepBlue),
                            SizedBox(height: 16),
                            Text(
                              'Loading cancel reasons...',
                              style: TextStyle(color: StyleRepo.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.cancelReasons.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No cancel reasons available',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please contact support or try again later.',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () => controller.fetchCancelReasons(),
                              child: Text('Retry', style: TextStyle(color: StyleRepo.deepBlue)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // ✅ Show reasons from API with correct field names
                      ...controller.cancelReasons.map((reason) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedReasonId = reason.id;
                                customReason = '';
                                customReasonController.clear();
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          selectedReasonId == reason.id
                                              ? StyleRepo.deepBlue
                                              : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color:
                                        selectedReasonId == reason.id
                                            ? StyleRepo.deepBlue
                                            : Colors.transparent,
                                  ),
                                  child:
                                      selectedReasonId == reason.id
                                          ? Icon(Icons.check, size: 14, color: Colors.white)
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason.reasonText, // ✅ Use reasonText instead of title
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: StyleRepo.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // ✅ Add "Other reason" option manually
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedReasonId = -1; // Use -1 for custom reason
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedReasonId == -1
                                                ? StyleRepo.deepBlue
                                                : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color:
                                          selectedReasonId == -1
                                              ? StyleRepo.deepBlue
                                              : Colors.transparent,
                                    ),
                                    child:
                                        selectedReasonId == -1
                                            ? Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Other reason',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: StyleRepo.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ✅ Custom reason text field
                            if (selectedReasonId == -1)
                              Container(
                                margin: const EdgeInsets.only(top: 12, left: 32),
                                child: TextField(
                                  controller: customReasonController,
                                  onChanged: (value) {
                                    customReason = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Please specify your reason...',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: StyleRepo.deepBlue),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  maxLines: 3,
                                  maxLength: 200,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // ✅ Submit button with better validation
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isLoadingReasons.value
                              ? null
                              : () {
                                if (selectedReasonId == 0) {
                                  PopUpToast.show('Please select a cancellation reason');
                                  return;
                                }

                                // ✅ Check if custom reason is selected but not provided
                                if (selectedReasonId == -1 && customReason.trim().isEmpty) {
                                  PopUpToast.show('Please provide a custom reason');
                                  return;
                                }

                                Get.back();

                                // ✅ Use the first available reason ID for custom reasons
                                int finalReasonId = selectedReasonId;
                                if (selectedReasonId == -1 && controller.cancelReasons.isNotEmpty) {
                                  finalReasonId =
                                      controller.cancelReasons.first.id; // Use first reason ID
                                }

                                controller.performCancelOrderWithReason(
                                  order,
                                  finalReasonId,
                                  selectedReasonId == -1
                                      ? customReason
                                      : '', // Only send custom reason if selected
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StyleRepo.deepBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel Offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
}
