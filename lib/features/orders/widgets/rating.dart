import 'package:flutter/material.dart';

import '../../../core/style/repo.dart';
import '../../../gen/assets.gen.dart';
import '../models/order_model.dart';

class RatingDialog extends StatefulWidget {
  final OrderModel order;
  final Function(int rating, String reviewText) onRatingSubmitted;

  const RatingDialog({super.key, required this.order, required this.onRatingSubmitted});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              "Rate & Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StyleRepo.black),
            ),
            const SizedBox(height: 8),
            Text(
              "How was your experience with the service?",
              style: TextStyle(fontSize: 14, color: StyleRepo.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Provider Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: StyleRepo.deepBlue,
                  backgroundImage: _getProviderAvatar(),
                  child:
                      _getProviderAvatar() == null
                          ? Icon(Icons.person, color: Colors.white, size: 20)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.provider?.name ?? "Service Provider",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: StyleRepo.black,
                        ),
                      ),
                      Text(
                        widget.order.serviceCategory,
                        style: TextStyle(fontSize: 12, color: StyleRepo.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Assets.icons.essentials.star.svg(
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        index < selectedRating
                            ? StyleRepo.amber
                            : StyleRepo.grey.withValues(alpha: 0.3),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Review Text Field
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write your review here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: StyleRepo.grey.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: StyleRepo.grey.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: StyleRepo.deepBlue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: StyleRepo.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Text("Cancel", style: TextStyle(color: StyleRepo.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedRating > 0 ? _submitRating : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.deepBlue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProviderAvatar() {
    if (widget.order.provider?.avatar.mediumUrl != null &&
        widget.order.provider!.avatar.mediumUrl.isNotEmpty) {
      return NetworkImage(widget.order.provider!.avatar.mediumUrl);
    }
    return null;
  }

  void _submitRating() {
    if (selectedRating > 0) {
      widget.onRatingSubmitted(selectedRating, reviewController.text.trim());
      Navigator.of(context).pop();
    }
  }
}
