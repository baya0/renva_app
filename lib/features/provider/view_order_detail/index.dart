import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/style/repo.dart';
import '../../../gen/assets.gen.dart';
import 'controller.dart';

class ViewOrderDetail extends StatelessWidget {
  const ViewOrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ViewOrderDetailController());

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      appBar: AppBar(
        backgroundColor: StyleRepo.softWhite,
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Assets.icons.arrows.leftCircle.svg(
              colorFilter: ColorFilter.mode(StyleRepo.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(
          'Order Detail',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: StyleRepo.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            // Order Detail Card
            Column(
              children: [
                // User Info Section
                _buildUserInfoSection(controller),

                // Divider
                Container(
                  height: 1,
                  color: StyleRepo.softGrey.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),

                // Order Pictures Section
                if (controller.orderPhotos.isNotEmpty) _buildPicturesSection(controller),
                // Divider
                Container(
                  height: 1,
                  color: StyleRepo.softGrey.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                // Description Section
                _buildDescriptionSection(controller),
                // Divider
                Container(
                  height: 1,
                  color: StyleRepo.softGrey.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                // Date & Time Section
                _buildDateTimeSection(controller),
              ],
            ),

            // Add Offer Button
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.addOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StyleRepo.deepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: Text(
                    'add offer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: StyleRepo.softWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(ViewOrderDetailController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 71,
            height: 71,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StyleRepo.softGrey.withValues(alpha: 0.3),
              border: Border.all(color: StyleRepo.softGrey.withValues(alpha: 0.5), width: 1),
            ),
            child: ClipOval(
              child:
                  controller.userAvatar != null
                      ? Image.network(
                        controller.userAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                      )
                      : _buildDefaultAvatar(),
            ),
          ),

          const SizedBox(width: 15),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.requesterName,
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    color: StyleRepo.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.categoryTitle,
                  style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: StyleRepo.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: StyleRepo.softGrey.withOpacity(0.2)),
      child: Assets.icons.essentials.circleUser.svg(
        colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildPicturesSection(ViewOrderDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pictures',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.orderPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StyleRepo.softGrey.withOpacity(0.5), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.orderPhotos[index],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: StyleRepo.softGrey.withOpacity(0.2),
                            child: const Icon(Icons.image, color: StyleRepo.grey),
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

  Widget _buildDescriptionSection(ViewOrderDetailController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
          ),
          const SizedBox(height: 12),
          Text(
            controller.orderData['description'] ?? 'No description available',
            style: TextStyle(fontSize: 14, color: StyleRepo.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(ViewOrderDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date & Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: StyleRepo.black),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: StyleRepo.grey),
                  const SizedBox(width: 8),
                  Text(
                    controller.orderData['date'] ?? 'Date not specified',
                    style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Icon(Icons.access_time_outlined, size: 18, color: StyleRepo.grey),
                  const SizedBox(width: 8),
                  Text(
                    controller.orderData['time'] ?? 'Time not specified',
                    style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
