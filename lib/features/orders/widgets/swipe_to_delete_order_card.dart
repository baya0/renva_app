import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/core/utils/responsive.dart';
import 'package:renva0/gen/assets.gen.dart';

import '../../../../core/localization/strings.dart';
import '../../../../core/services/rest_api/rest_api.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../add_orders/models/order.dart';
import '../models/order_model.dart';

class SwipeToDeleteOrderCard extends StatefulWidget {
  final Widget child;
  final OrderModel order;
  final VoidCallback? onDeleted;

  const SwipeToDeleteOrderCard({
    super.key,
    required this.child,
    required this.order,
    this.onDeleted,
  });

  @override
  State<SwipeToDeleteOrderCard> createState() => _SwipeToDeleteOrderCardState();
}

class _SwipeToDeleteOrderCardState extends State<SwipeToDeleteOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showDeleteOverlay = false;
  Offset? _startPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    if (widget.order.status != OrderStatus.pending) return;
    _startPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.order.status != OrderStatus.pending || _startPosition == null) return;

    final velocity = details.velocity.pixelsPerSecond.dx.abs();

    //When user swipes fast (velocity > 300), it toggles the delete overlay.
    if (velocity > 300) {
      if (!_showDeleteOverlay) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }

    _startPosition = null;
  }

  void _showOverlay() {
    setState(() => _showDeleteOverlay = true);
    _animationController.forward();
  }

  void _hideOverlay() {
    setState(() => _showDeleteOverlay = false);
    _animationController.reverse();
  }

  void _handleDeleteTap() {
    _showDeleteConfirmationDialog();
  }

  void _showDeleteConfirmationDialog() {
    final r = Responsive(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius20)),
        insetPadding: EdgeInsets.symmetric(horizontal: r.space20),
        contentPadding: EdgeInsets.all(r.space20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: r.iconSize20, color: Colors.grey),
              ),
            ),
            SizedBox(height: r.space8),

            // Icon in center
            Assets.icons.essentials.trashGroup.svg(
              width: r.value(mobile: 100, tablet: 110, desktop: 120),
              height: r.value(mobile: 100, tablet: 110, desktop: 120),
            ),
            SizedBox(height: r.space16),

            // Text
            Text(
              tr(LocaleKeys.dialogs_delete_order_confirm),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.fontSize18, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            SizedBox(height: r.space24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius24)),
                      backgroundColor: StyleRepo.paleLavender,
                      padding: EdgeInsets.symmetric(vertical: r.space12),
                    ),
                    child: Text(
                      tr(LocaleKeys.common_cancel),
                      style: TextStyle(
                        fontSize: r.fontSize14,
                        fontWeight: FontWeight.w500,
                        color: StyleRepo.lavender,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: r.space12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showDeleteReasonBottomSheet();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.softRed,
                      side: BorderSide(color: StyleRepo.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius24)),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: r.space12),
                    ),
                    child: Text(
                      tr(LocaleKeys.common_delete),
                      style: TextStyle(
                        fontSize: r.fontSize14,
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
      barrierDismissible: false, // prevent closing by tapping outside
    );
  }

  void _showDeleteReasonBottomSheet() {
    int selectedReasonId = 0;
    String customReason = '';
    final TextEditingController customReasonController = TextEditingController();

    final Map<String, int> predefinedReasons = {
      tr(LocaleKeys.deletion_reasons_change_mind): 1,
      tr(LocaleKeys.deletion_reasons_no_longer_need): 2,
      tr(LocaleKeys.deletion_reasons_provider_no_response): 3,
      tr(LocaleKeys.deletion_reasons_high_prices): 4,
    };

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final r = context.responsive;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius20)),
            ),
            padding: EdgeInsets.all(r.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr(LocaleKeys.dialogs_reason_for_delete),
                      style: TextStyle(
                        fontSize: r.fontSize18,
                        fontWeight: FontWeight.w600,
                        color: StyleRepo.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: r.iconSize32,
                        height: r.iconSize32,
                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                        child: Icon(Icons.close, size: r.iconSize20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.space16),
                Text(
                  tr(LocaleKeys.dialogs_reason_for_delete_subtitle),
                  style: TextStyle(fontSize: r.fontSize14, color: StyleRepo.grey),
                ),
                SizedBox(height: r.space24),

                ...predefinedReasons.entries.map((entry) {
                  String reasonText = entry.key;
                  int reasonId = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: r.space16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedReasonId = reasonId;
                          customReason = '';
                          customReasonController.clear();
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: r.iconSize20,
                            height: r.iconSize20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    selectedReasonId == reasonId
                                        ? StyleRepo.deepBlue
                                        : Colors.grey[400]!,
                                width: 2,
                              ),
                              color:
                                  selectedReasonId == reasonId
                                      ? StyleRepo.deepBlue
                                      : Colors.transparent,
                            ),
                            child:
                                selectedReasonId == reasonId
                                    ? Icon(Icons.check, size: r.fontSize14, color: Colors.white)
                                    : null,
                          ),
                          SizedBox(width: r.space12),
                          Expanded(
                            child: Text(
                              reasonText,
                              style: TextStyle(
                                fontSize: r.fontSize14,
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

                Container(
                  margin: EdgeInsets.only(bottom: r.space16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReasonId = 5;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: r.iconSize20,
                          height: r.iconSize20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedReasonId == 5 ? StyleRepo.deepBlue : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: selectedReasonId == 5 ? StyleRepo.deepBlue : Colors.transparent,
                          ),
                          child:
                              selectedReasonId == 5
                                  ? Icon(Icons.check, size: r.fontSize14, color: Colors.white)
                                  : null,
                        ),
                        SizedBox(width: r.space12),
                        Expanded(
                          child: Text(
                            tr(LocaleKeys.dialogs_another_reason),
                            style: TextStyle(
                              fontSize: r.fontSize14,
                              color: StyleRepo.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (selectedReasonId == 5) ...[
                  SizedBox(height: r.space8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: r.space16, vertical: r.space12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(r.radius8),
                    ),
                    child: TextField(
                      controller: customReasonController,
                      decoration: InputDecoration(
                        hintText: tr(LocaleKeys.hints_add_deletion_reason),
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: r.fontSize14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(r.space12),
                      ),
                      onChanged: (value) {
                        customReason = value;
                      },
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ],

                SizedBox(height: r.space32),

                SizedBox(
                  width: double.infinity,
                  height: r.buttonHeightMedium,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedReasonId == 0) {
                        PopUpToast.show(tr(LocaleKeys.dialogs_select_deletion_reason));
                        return;
                      }
                      if (selectedReasonId == 5 && customReason.trim().isEmpty) {
                        PopUpToast.show(tr(LocaleKeys.dialogs_provide_custom_deletion_reason));
                        return;
                      }
                      Get.back();
                      _performDeleteOrderWithReason(selectedReasonId, customReason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.deepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius12)),
                      elevation: 0,
                    ),
                    child: Text(
                      tr(LocaleKeys.common_send),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Future<void> _performDeleteOrderWithReason(int reasonId, String customReason) async {
    try {
      PopUpToast.show(tr(LocaleKeys.errors_deleting_order));

      Map<String, dynamic> requestBody = {
        'order_id': widget.order.id,
        'order_delete_reason_id': reasonId,
      };

      if (reasonId == 5 && customReason.isNotEmpty) {
        requestBody['custom_reason'] = customReason.trim();
      }

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.deleteOrder(widget.order.id),
          method: RequestMethod.Delete,
          body: requestBody,
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show(tr(LocaleKeys.success_order_deleted_successfully));
        _hideOverlay();
        widget.onDeleted?.call();
      } else {
        String errorMsg = 'Failed to delete order. Please try again.';

        if (response.message.isNotEmpty) {
          errorMsg = response.message;
        } else if (response.data != null && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['message'] != null) {
            errorMsg = data['message'].toString();
          } else if (data['error'] != null) {
            errorMsg = data['error'].toString();
          }
        }

        PopUpToast.show(errorMsg);
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.errors_network_error_check_connection));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: [
          widget.child,

          if (widget.order.status == OrderStatus.pending && _showDeleteOverlay)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StyleRepo.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(r.radius24),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: _handleDeleteTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.space24,
                              vertical: r.space4,
                            ),
                            decoration: BoxDecoration(
                              color: StyleRepo.softRed,
                              borderRadius: BorderRadius.circular(r.value(mobile: 38, tablet: 42, desktop: 46)),
                              border: Border.all(color: StyleRepo.red),
                              boxShadow: [
                                BoxShadow(
                                  color: StyleRepo.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.essentials.trashGroupCircular.svg(
                                  width: r.iconSize32,
                                  height: r.iconSize32,
                                ),
                                SizedBox(width: r.space12),
                                Text(
                                  tr(LocaleKeys.orders_cancel_order),
                                  style: TextStyle(
                                    color: StyleRepo.red,
                                    fontSize: r.fontSize14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
