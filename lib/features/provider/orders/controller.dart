import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/config/app_builder.dart';
import 'package:renva0/core/constants/controllers_tags.dart';
import 'package:renva0/core/routes/routes.dart';
import 'package:renva0/core/services/pagination/controller.dart';
import 'package:renva0/core/services/rest_api/rest_api.dart';
import 'package:renva0/core/widgets/modern_toast.dart';

import '../../orders/models/order_model.dart';
import 'models/provider_model.dart';

class ProviderOrdersController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxSet<int> completingOrderIds = <int>{}.obs;
  final TextEditingController searchController = TextEditingController();
  final RxList<CancelReasonModel> cancelReasons = <CancelReasonModel>[].obs;
  final RxBool isLoadingReasons = false.obs;
  final AppBuilder appBuilder = Get.find<AppBuilder>();
  bool get isProviderMode => appBuilder.isProviderMode.value;
  final List<String> tabs = ['Pending', 'Underway', 'Complete', 'Cancelled'];

  // Tag mapping for each tab
  final Map<int, String> tabTags = {
    0: ControllersTags.providerOrdersPending,
    1: ControllersTags.providerOrdersUnderway,
    2: ControllersTags.providerOrdersCompleted,
    3: ControllersTags.providerOrdersCancelled,
  };

  // Get current tab's tag
  String get currentTag => tabTags[selectedTabIndex.value]!;

  bool isOrderCompleting(int orderId) {
    return completingOrderIds.contains(orderId);
  }

  // Get current pagination controller using the tag
  PaginationController<ProviderOrderModel>? get currentPaginationController {
    try {
      if (Get.isRegistered<PaginationController<ProviderOrderModel>>(tag: currentTag)) {
        return Get.find<PaginationController<ProviderOrderModel>>(tag: currentTag);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get orders count for display
  int get ordersCount {
    final controller = currentPaginationController;
    return controller?.data.valueLength ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      refreshCurrentTab();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Get pagination controller for specific tab
  PaginationController<ProviderOrderModel>? getPaginationControllerForTab(int tabIndex) {
    final tag = tabTags[tabIndex]!;
    try {
      if (Get.isRegistered<PaginationController<ProviderOrderModel>>(tag: tag)) {
        return Get.find<PaginationController<ProviderOrderModel>>(tag: tag);
      }
      return null;
    } catch (e) {
      print('Error finding pagination controller for tab $tabIndex: $e');
      return null;
    }
  }

  void refreshTab(int tabIndex) {
    final controller = getPaginationControllerForTab(tabIndex);
    controller?.refresh();
  }

  void refreshCurrentTab() {
    final currentTabIndex = selectedTabIndex.value;
    refreshTab(currentTabIndex);
  }

  void refreshMultipleTabs(List<int> tabIndexes) {
    for (int tabIndex in tabIndexes) {
      refreshTab(tabIndex);
    }
  }

  Future<ResponseModel> fetchApi(int page, CancelToken cancelToken) async {
    try {
      Map<String, String> params = {'page': page.toString(), 'per_page': '10'};

      // API statuses: waiting, processing, cancelled, completed
      String apiStatus;
      switch (selectedTabIndex.value) {
        case 0: // Pending tab
          apiStatus = 'waiting'; //  pending orders
          break;
        case 1: // Underway tab
          apiStatus = 'processing'; //  in-progress orders
          break;
        case 2: // Complete tab
          apiStatus = 'completed'; //  completed orders
          break;
        case 3: // Cancelled tab
          apiStatus = 'cancelled'; // cancelled orders
          break;
        default:
          apiStatus = 'waiting';
      }

      params['status'] = apiStatus; //  Adding status parameter to API call

      final response = await APIService.instance.request(
        Request(endPoint: EndPoints.providerOrders, method: RequestMethod.Get, params: params),
      );

      if (response.success && response.data != null) {
        List ordersData;

        if (response.data is List) {
          ordersData = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          ordersData = data['data'] as List? ?? [];
        } else {
          ordersData = [];
        }

        List filteredOrders =
            ordersData.where((orderJson) {
              final order = ProviderOrderModel.fromJson(orderJson);

              ///// Only show orders where provider has made an offer
              //// API should already filter this, but adding as safety check :P
              return order.providerOffer != null;
            }).toList();

        return ResponseModel(
          statusCode: 200,
          success: true,
          data: filteredOrders,
          message: response.message,
        );
      }

      return response;
    } catch (e) {
      print('Error fetching provider orders page $page: $e');
      rethrow;
    }
  }

  ProviderOrderModel fromJson(Map<String, dynamic> orderJson) {
    return ProviderOrderModel.fromJson(orderJson);
  }

  // Navigate to order details
  void viewOrderDetails(ProviderOrderModel order) {
    try {
      final orderData = {
        'id': order.id.toString(),
        'requesterName':
            '${order.customer['first_name'] ?? ''} ${order.customer['last_name'] ?? ''}'.trim(),
        'categoryTitle': order.category['title'] ?? 'Service Request',
        'description': order.description,
        'date': order.date,
        'time': order.startAt ?? '09:00:00',
        'status': order.status,
        'apiData': order.toJson(),
      };

      Get.toNamed(Pages.view_order_detail.value, arguments: orderData);
    } catch (e) {
      PopUpToast.show('Error viewing order details');
      print('Error navigating to order details: $e');
    }
  }

  Future<void> completeOrder(ProviderOrderModel order) async {
    if (completingOrderIds.contains(order.id)) return;

    try {
      completingOrderIds.add(order.id);

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.provider_complete_order,
          method: RequestMethod.Post,
          body: {'order_id': order.id},
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show('Order completed successfully!');
        refreshCurrentTab(); // Refresh the current tab data (underway tab :D)
        refreshTab(2); //2 is complete order
      } else {
        PopUpToast.show('Failed to complete order. Please try again.');
      }
    } catch (e) {
      PopUpToast.show('Network error. Please check your connection.');
    } finally {
      //  Remove this specific order ID from the completing set
      completingOrderIds.remove(order.id);
    }
  }

  Future<void> fetchCancelReasons() async {
    try {
      isLoadingReasons.value = true;

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.cancel_order_reasons,
          method: RequestMethod.Get,
          copyHeader: {'Accept': 'application/json'},
          params: {'type': isProviderMode ? 'provider' : 'customer'},
        ),
      );

      if (response.success && response.data != null) {
        List reasonsData;

        if (response.data is List) {
          reasonsData = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          reasonsData = data['data'] as List? ?? [];
        } else {
          reasonsData = [];
          print(' Unexpected data type, using empty list');
        }

        //  Convert all reasons with detailed logging
        List<CancelReasonModel> allReasons = [];
        for (var reasonJson in reasonsData) {
          try {
            final reason = CancelReasonModel.fromJson(reasonJson);
            allReasons.add(reason);
          } catch (e) {
            print('  Error parsing reason: $e');
          }
        }

        cancelReasons.value = allReasons;
        print(' Final result: ${allReasons.length} cancel reasons loaded');

        for (var reason in allReasons) {
          print('    Reason ${reason.id}: "${reason.reasonText}"');
        }
      } else {
        PopUpToast.show('Failed to load cancel reasons: ${response.message}');
      }
    } catch (e) {
      PopUpToast.show('Network error while loading reasons');
    } finally {
      isLoadingReasons.value = false;
    }
  }

  Future<void> performCancelOrderWithReason(
    ProviderOrderModel order,
    int reasonId,
    String customReason,
  ) async {
    try {
      PopUpToast.show('Cancelling offer...');

      Map<String, dynamic> requestBody = {'order_id': order.id, 'order_cancel_reason_id': reasonId};

      if (customReason.isNotEmpty) {
        requestBody['custom_reason'] = customReason.trim();
      }

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.provider_cancel_order,
          method: RequestMethod.Post,
          body: requestBody,
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show('Offer cancelled successfully');

        refreshCurrentTab(); // Remove from Underway
        refreshTab(3); // Add to Cancelled :D
      } else {
        String errorMsg = 'Failed to cancel offer. Please try again.';
        if (response.message.isNotEmpty) {
          errorMsg = response.message;
        }
        PopUpToast.show(errorMsg);
      }
    } catch (e) {
      print(' Error cancelling offer: $e');
      PopUpToast.show('Network error. Please check your connection.');
    }
  }

  Future<void> deleteOffer(int offerId) async {
    try {
      final response = await APIService.instance.request(
        Request(
          endPoint: '${EndPoints.offers}/$offerId',
          method: RequestMethod.Delete,
          copyHeader: {'Accept': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show('Offer deleted successfully!');

        refreshCurrentTab(); // Remove from current tab
        refreshTab(3); // Refresh Cancelled tab
      } else {
        PopUpToast.show('Failed to cancel offer.');
      }
    } catch (e) {
      PopUpToast.show('Network error.');
    }
  }
}
