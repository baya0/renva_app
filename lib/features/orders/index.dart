import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/localization/strings.dart';
import 'package:renva0/core/services/pagination/options/list_view.dart';
import 'package:renva0/features/orders/controller.dart';
import 'package:renva0/features/orders/widgets/order_card.dart';

import '../../core/style/repo.dart';
import '../../gen/assets.gen.dart';
import 'models/order_model.dart';
import 'widgets/swipe_to_delete_order_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(controller),
          const SizedBox(height: 16),
          _buildOrdersCount(controller),
          const SizedBox(height: 16),
          _buildOrdersList(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: StyleRepo.softWhite,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Text(
          tr(LocaleKeys.orders_my_orders),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: StyleRepo.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: StyleRepo.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StyleRepo.grey.withValues(alpha: 0.2)),
        ),
        child: TextField(
          controller: Get.find<OrdersController>().searchController,
          decoration: InputDecoration(
            hintText: tr(LocaleKeys.orders_search_placeholder),
            hintStyle: TextStyle(color: StyleRepo.grey, fontSize: 14),
            prefixIcon: SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Assets.icons.essentials.search.svg(
                  colorFilter: ColorFilter.mode(
                    StyleRepo.grey.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(OrdersController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          controller.tabs.length,
          (index) => Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTabIndex.value == index
                                ? StyleRepo.deepBlue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    controller.tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          controller.selectedTabIndex.value == index
                              ? StyleRepo.deepBlue
                              : Colors.grey[500],
                      fontSize: 14,
                      fontWeight:
                          controller.selectedTabIndex.value == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersCount(OrdersController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Obx(
            () => Text(
              '${controller.ordersCount} ${tr(LocaleKeys.orders_orders_count)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrdersController controller) {
    return Expanded(
      child: Obx(
        () => ListViewPagination<OrderModel>.builder(
          tag: 'orders_${controller.selectedTabIndex.value}',
          fetchApi: controller.fetchApi,
          fromJson: controller.fromJson,
          onControllerInit: (paginationController) {
            _updatePaginationController(controller, paginationController);
          },
          itemBuilder: (context, index, order) {
            return SwipeToDeleteOrderCard(
              order: order,
              onDeleted: () {
                controller.currentPaginationController?.refresh();
              },
              child: OrderCard(order: order, controller: controller),
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hasRefresh: true,
          initialLoading: _buildInitialLoading(),
          errorWidget: _buildErrorWidget(),
        ),
      ),
    );
  }

  void _updatePaginationController(OrdersController controller, dynamic paginationController) {
    switch (controller.selectedTabIndex.value) {
      case 0:
        controller.pendingPaginationController = paginationController;
        break;
      case 1:
        controller.underwayPaginationController = paginationController;
        break;
      case 2:
        controller.completePaginationController = paginationController;
        break;
      case 3:
        controller.cancelledPaginationController = paginationController;
        break;
    }
  }

  Widget _buildInitialLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: StyleRepo.deepBlue),
          const SizedBox(height: 16),
          Text(tr(LocaleKeys.orders_loading_orders), style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget Function(String) _buildErrorWidget() {
    return (error) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            tr(LocaleKeys.orders_error_loading_orders),
            style: TextStyle(color: Colors.red[600], fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final ordersController = Get.find<OrdersController>();
              final currentController = ordersController.currentPaginationController;
              if (currentController != null) {
                currentController.refreshData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: StyleRepo.deepBlue),
            child: Text(tr(LocaleKeys.orders_retry), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
