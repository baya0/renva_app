import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renva0/features/orders/models/order_model.dart';

import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/style/repo.dart';
import '../../../core/widgets/modern_toast.dart';
import '../models/offer_model.dart';

class OfferDetailsPage extends StatelessWidget {
  const OfferDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'View Offer',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Info Section
            _buildProviderInfo(offer),
            const SizedBox(height: 24),

            // Pictures Section
            _buildPicturesSection(offer),
            const SizedBox(height: 24),

            // Description Section
            _buildDescriptionSection(offer),
            const SizedBox(height: 24),

            // Price Range Section
            _buildPriceSection(offer),
            const SizedBox(height: 24),

            // Date & Time Section
            _buildDateTimeSection(offer),

            const Spacer(),

            // Action Buttons
            _buildActionButtons(offer, order),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo(OfferModel offer) {
    return Row(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    _formatOfferCreatedAt(offer.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Star Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color:
                            index < offer.providerRating.floor()
                                ? Colors.amber
                                : Colors.grey.shade300,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    offer.reviewCount.toString(),
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

  // Simple _buildPicturesSection - replace your existing one
  Widget _buildPicturesSection(OfferModel offer) {
    List<String> imageUrls = offer.images ?? [];

    // If no images, don't show the section at all
    if (imageUrls.isEmpty) {
      return SizedBox.shrink(); // This returns an empty widget
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pictures',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return GestureDetector(
                onTap: () => _showImageFullScreen(imageUrl), // Add tap to view
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
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
                        // If image fails to load, show simple icon
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

  // Add this method to show image full screen when tapped
  void _showImageFullScreen(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.network(imageUrl, fit: BoxFit.contain))),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Text(
          offer.description.isNotEmpty
              ? offer.description
              : 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit, Sed Do Eiusmod Tempor Incididunt Ut Labore Et Dolore Magna Aliqua. Ut Enim Ad Minim Veniam, Quis Nostrud Exercitation',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPriceSection(OfferModel offer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Price Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        Text(
          '${offer.price.toStringAsFixed(0)} SEK',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.deepBlue),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              _formatDate(offer.createdAt),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              _formatTime(offer.createdAt),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(OfferModel offer, OrderModel? order) {
    return Column(
      children: [
        Row(
          children: [
            // Delete Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _declineOffer(offer, order!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    'Delete',
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
                  onPressed: () => _acceptOffer(offer, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    'Accept',
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
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd - MMM - yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH : mm a').format(dateTime);
  }

  // Format when the offer was created (for next to rating)
  String _formatOfferCreatedAt(DateTime createdAt) {
    return DateFormat('dd MMM \'at\' hh:mm a').format(createdAt).toUpperCase();
  }

  void _acceptOffer(OfferModel offer, OrderModel? order) {
    Get.dialog(
      AlertDialog(
        title: Text('Accept Offer'),
        content: Text('Are you sure you want to accept this offer from ${offer.providerName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: StyleRepo.lavender)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to orders page
              _performAcceptOffer(offer, order);
            },
            child: Text('Accept', style: TextStyle(color: StyleRepo.forestGreen)),
          ),
        ],
      ),
    );
  }

  void _declineOffer(OfferModel offer, OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Offer'),
        content: Text('Are you sure you want to delete this offer?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: StyleRepo.lavender)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close bottom sheet
              _performDeletOffer(offer, order);
            },
            child: Text('Delete', style: TextStyle(color: StyleRepo.red)),
          ),
        ],
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
    PopUpToast.show('Accepting offer...');

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
          response.message.isNotEmpty ? response.message : 'Offer accepted successfully!';

      PopUpToast.show(successMessage);

      // Go back to orders page with success
      Get.back(); // Go back to orders page

      // Optional: You can also trigger a refresh of the orders list
      // if you have access to the OrdersController
    } else {
      String errorMessage =
          response.message.isNotEmpty
              ? response.message
              : 'Failed to accept offer. Please try again.';

      PopUpToast.show(errorMessage);
    }
  } catch (e) {
    print('Error accepting offer: $e');
    PopUpToast.show('Network error. Please check your connection.');
  }
}

// API call for declining offer
Future<void> _performDeclineOffer(OfferModel offer, OrderModel? order) async {
  try {
    PopUpToast.show('Declining offer...');

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
          response.message.isNotEmpty ? response.message : 'Offer declined successfully!';

      PopUpToast.show(successMessage);

      // Go back to orders page
      Get.back();
    } else {
      String errorMessage =
          response.message.isNotEmpty
              ? response.message
              : 'Failed to decline offer. Please try again.';

      PopUpToast.show(errorMessage);
    }
  } catch (e) {
    print('Error declining offer: $e');
    PopUpToast.show('Network error. Please check your connection.');
  }
}
