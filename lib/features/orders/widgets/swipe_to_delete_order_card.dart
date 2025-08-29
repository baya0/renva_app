import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/gen/assets.gen.dart';

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
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, size: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),

            // Icon in center
            Assets.icons.essentials.trashGroup.svg(width: 100, height: 100),
            const SizedBox(height: 16),

            // Text
            Text(
              'Are You Sure you want to delete the Request ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: StyleRepo.black),
            ),
            const SizedBox(height: 24),

            // Buttons
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
                      _showDeleteReasonBottomSheet();
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
      barrierDismissible: false, // prevent closing by tapping outside
    );
  }

  void _showDeleteReasonBottomSheet() {
    int selectedReasonId = 0;
    String customReason = '';
    final TextEditingController customReasonController = TextEditingController();

    final Map<String, int> predefinedReasons = {
      'Change my mind': 1,
      'I no longer need the service': 2,
      'The service provider did not respond to messages': 3,
      'Service provider prices are high': 4,
    };

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reason for Delete',
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
                  'Please specify the reason for deleting the order',
                  style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                ),
                const SizedBox(height: 24),

                ...predefinedReasons.entries.map((entry) {
                  String reasonText = entry.key;
                  int reasonId = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                            width: 20,
                            height: 20,
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
                                    ? Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reasonText,
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

                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReasonId = 5;
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
                              color: selectedReasonId == 5 ? StyleRepo.deepBlue : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: selectedReasonId == 5 ? StyleRepo.deepBlue : Colors.transparent,
                          ),
                          child:
                              selectedReasonId == 5
                                  ? Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Another reason',
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
                ),

                if (selectedReasonId == 5) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: customReasonController,
                      decoration: InputDecoration(
                        hintText: 'Add Another Reason For Deletion',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      onChanged: (value) {
                        customReason = value;
                      },
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedReasonId == 0) {
                        PopUpToast.show('Please select a deletion reason');
                        return;
                      }
                      if (selectedReasonId == 5 && customReason.trim().isEmpty) {
                        PopUpToast.show('Please provide a custom reason');
                        return;
                      }
                      Get.back();
                      _performDeleteOrderWithReason(selectedReasonId, customReason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.deepBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
      PopUpToast.show('Deleting order...');

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
        PopUpToast.show('Order deleted successfully');
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
      PopUpToast.show('Network error. Please check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: _handleDeleteTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                            decoration: BoxDecoration(
                              color: StyleRepo.softRed,
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(color: StyleRepo.red),
                              boxShadow: [
                                BoxShadow(
                                  color: StyleRepo.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.essentials.trashGroupCircular.svg(
                                  width: 38,
                                  height: 38,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Delete Order',
                                  style: TextStyle(
                                    color: StyleRepo.red,
                                    fontSize: 14,
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
