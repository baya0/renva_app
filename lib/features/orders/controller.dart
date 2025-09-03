// controllers/orders_controller.dart
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:renva0/core/services/pagination/controller.dart';
import 'package:renva0/core/style/repo.dart';
import 'package:renva0/features/provider/review_offer/index.dart';

import '../../core/config/app_builder.dart';
import '../../core/localization/strings.dart';
import '../../core/services/pagination/options/list_view.dart';
import '../../core/services/rest_api/rest_api.dart';
import '../../core/widgets/modern_toast.dart';
import '../../gen/assets.gen.dart';
import '../add_orders/models/order.dart';
import 'models/offer_model.dart';
import 'models/order_model.dart';
import 'offer_details/index.dart';

class OrdersController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isAcceptingOffer = false.obs;
  final RxBool isCancellingOrder = false.obs; // Add loading state for cancellation
  final RxBool isLoadingCancelReasons = false.obs; // Add loading state for fetching reasons
  final TextEditingController searchController = TextEditingController();

  // Cancellation reasons cache
  final RxList<CancelReasonModel> cancelReasons = <CancelReasonModel>[].obs;

  // Pagination controllers - these will be set by ListViewPagination's onControllerInit
  PaginationController<OrderModel>? pendingPaginationController;
  PaginationController<OrderModel>? underwayPaginationController;
  PaginationController<OrderModel>? completePaginationController;
  PaginationController<OrderModel>? cancelledPaginationController;

  List<String> get tabs => [
    tr(LocaleKeys.orders_pending),
    tr(LocaleKeys.orders_underway),
    tr(LocaleKeys.orders_complete),
    tr(LocaleKeys.orders_cancelled),
  ];

  OrderStatus get currentStatus => OrderStatus.values[selectedTabIndex.value];

  final AppBuilder appBuilder = Get.find<AppBuilder>();
  final RxBool isCompletingOrder = false.obs; // For provider complete button
  bool get isProviderMode => appBuilder.isProviderMode.value;

  // Get current pagination controller based on selected tab
  PaginationController<OrderModel>? get currentPaginationController {
    switch (selectedTabIndex.value) {
      case 0:
        return pendingPaginationController;
      case 1:
        return underwayPaginationController;
      case 2:
        return completePaginationController;
      case 3:
        return cancelledPaginationController;
      default:
        return pendingPaginationController;
    }
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _refreshCurrentTab();
    });

    // Fetch cancellation reasons on init
    _fetchCancellationReasons();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Fetch cancellation reasons from API
  Future<void> _fetchCancellationReasons() async {
    if (cancelReasons.isNotEmpty) return; // Don't fetch if already loaded

    try {
      isLoadingCancelReasons.value = true;

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.cancel_order_reasons,
          method: RequestMethod.Get,
          params: {'type': 'customer'},
          copyHeader: {'Accept': 'application/json'},
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
        }

        // Parse the cancellation reasons using your existing model
        final reasons =
            reasonsData.map((reasonJson) => CancelReasonModel.fromJson(reasonJson)).toList();

        cancelReasons.assignAll(reasons);
      } else {
        print('Failed to fetch cancellation reasons: ${response.message}');
      }
    } catch (e) {
      print('Error fetching cancellation reasons: $e');
    } finally {
      isLoadingCancelReasons.value = false;
    }
  }

  // This method will be called by ListViewPagination for fetchApi
  Future<ResponseModel> fetchApi(int page, CancelToken cancelToken) async {
    try {
      Map<String, String> params = {
        'status': currentStatus.apiStatus,
        'page': page.toString(),
        'per_page': '10',
      };

      // Add search query if exists
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }

      final response = await APIService.instance.request(
        Request(endPoint: EndPoints.customerOrders, method: RequestMethod.Get, params: params),
      );

      if (response.success && response.data != null) {
        // Handle different response structures
        List ordersData;

        if (response.data is List) {
          // Data is already a list of orders
          ordersData = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          // Data is wrapped in a map with 'data' field
          final data = response.data as Map<String, dynamic>;
          ordersData = data['data'] as List? ?? [];
        } else {
          // Fallback to empty list
          ordersData = [];
        }

        return ResponseModel(
          statusCode: 200,
          success: true,
          data: ordersData,
          message: response.message,
        );
      }

      print('API Response failed: ${response.message}'); // Debug log
      return response;
    } catch (e) {
      print('Error fetching orders page $page: $e');
      rethrow;
    }
  }

  OrderModel fromJson(Map<String, dynamic> orderJson) {
    DateTime dateTime = DateTime.tryParse(orderJson['created_at']) ?? DateTime.now();

    // Handle cancel_reason
    String? cancelReason;
    if (orderJson['cancel_reason'] != null) {
      if (orderJson['cancel_reason'] is String) {
        cancelReason = orderJson['cancel_reason'];
      } else if (orderJson['cancel_reason'] is Map) {
        cancelReason = orderJson['cancel_reason']['reason_text'];
      }
    }

    // Parse provider
    ProviderModel? provider;
    try {
      if (orderJson['provider'] != null) {
        provider = ProviderModel.fromJson(orderJson['provider']);
        print(' Provider parsed: ${provider.name}');
      }
    } catch (e) {
      print(' Provider parsing failed: $e');
      provider = null;
    }

    String? customerRating;
    int? customerStarRating;
    String? providerRating;
    int? providerStarRating;
    if (orderJson['review'] != null) {
      if (orderJson['review'] is String) {
        customerRating = orderJson['review'];
      } else if (orderJson['review'] is Map) {
        final review = orderJson['review'] as Map<String, dynamic>;
        customerRating = review['comment']?.toString() ?? review['review']?.toString();
      }
    }

    // Customer star rating - using 'rate' field from  API
    if (orderJson['rate'] != null && orderJson['rate'] != 0) {
      customerStarRating = (orderJson['rate'] as num).round();
    }

    // Provider review/rating - using 'provider_review' field
    if (orderJson['provider_review'] != null) {
      if (orderJson['provider_review'] is String) {
        providerRating = orderJson['provider_review'];
      } else if (orderJson['provider_review'] is Map) {
        final review = orderJson['provider_review'] as Map<String, dynamic>;
        providerRating = review['comment']?.toString() ?? review['review']?.toString();
        providerStarRating = review['rating']?.round() ?? review['rate']?.round();
      }
    }

    final orderModel = OrderModel(
      id: orderJson['id'].toString(),
      serviceCategory: orderJson['mainCategory']?['title'] ?? 'Unknown Service',
      serviceSubcategory: orderJson['category']?['title'] ?? 'Unknown Subcategory',
      description: orderJson['description'] ?? 'No description',
      location: orderJson['address']?['title'] ?? 'Unknown Location',
      dateTime: dateTime,
      status: OrderStatus.fromString(orderJson['status']),
      serviceIcon: orderJson['mainCategory']?['svg'],
      cancelReason: cancelReason,
      deleteReason: orderJson['delete_reason'],
      offerCount: orderJson['offer_cnt'],
      viewerCount: orderJson['viewer_cnt'],
      minPrice: orderJson['min_price']?.toString(),
      maxPrice: orderJson['max_price']?.toString(),
      provider: provider,

      customerRating: customerRating,
      customerStarRating: customerStarRating,
      providerRating: providerRating,
      providerStarRating: providerStarRating,
    );

    return orderModel;
  }

  // Change tab and trigger data load for new tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
    // The ListViewPagination will automatically handle loading when the tag changes
  }

  // Refresh current tab
  Future<void> _refreshCurrentTab() async {
    final controller = currentPaginationController;
    if (controller != null) {
      await controller.refreshData();
    }
  }

  // Get orders count for current tab
  int get ordersCount {
    final controller = currentPaginationController;
    return controller?.data.valueLength ?? 0;
  }

  String formatDateTime(OrderModel order) {
    final now = DateTime.now();
    final difference = now.difference(order.dateTime);

    if (difference.inDays == 0) {
      return '${tr(LocaleKeys.orders_today_at)} at ${DateFormat('HH:mm').format(order.dateTime)}';
    } else if (difference.inDays == 1) {
      return '${tr(LocaleKeys.orders_yesterday_at)} at ${DateFormat('HH:mm').format(order.dateTime)}';
    } else {
      return DateFormat('d MMM at HH:mm').format(order.dateTime).toUpperCase();
    }
  }

  // View order details with  offer handling
  void viewOrderDetails(OrderModel order) {
    if (order.status == OrderStatus.pending) {
      if ((order.offerCount ?? 0) > 0) {
        _showOffersDialog(order);
      } else {
        _showOrderDetailsDialog(order);
      }
    } else {
      // For underway/complete orders, navigate to ReviewOfferPage
      navigateToReviewOffer(order);
    }
  }

  void _showOffersDialog(OrderModel order) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75, // 75% of screen height
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      tr(LocaleKeys.orders_available_offers),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: StyleRepo.deepBlue,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: StyleRepo.grey.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        child: Center(
                          child: Assets.icons.essentials.close.svg(
                            color: StyleRepo.grey,
                            width: 10,
                            height: 10,
                          ),
                        ),
                        onTap: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            //  OFFERS LIST WITH PAGINATION CONTROLLER (instead of FutureBuilder ##remember this T__t)
            Expanded(
              child: ListViewPagination<OfferModel>.builder(
                tag: 'offers_${order.id}', // Unique tag for each order
                fetchApi:
                    (int page, CancelToken cancelToken) =>
                        _fetchOffersApi(order.id, page, cancelToken),
                fromJson: (Map<String, dynamic> json) => OfferModel.fromJson(json),
                onControllerInit: (paginationController) {
                  // Store reference if needed for cleanup later
                  // You can access this controller for manual refresh, etc.
                },
                itemBuilder: (context, index, offer) {
                  return buildOfferCard(offer, order);
                },
                padding: const EdgeInsets.symmetric(horizontal: 20),
                hasRefresh: true,

                // Loading widget
                loading: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: StyleRepo.deepBlue, strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tr(LocaleKeys.orders_loading_more_offers),
                        style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                      ),
                    ],
                  ),
                ),

                // Initial loading widget
                initialLoading: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: StyleRepo.deepBlue),
                      const SizedBox(height: 16),
                      Text(
                        tr(LocaleKeys.orders_loading_offers),
                        style: TextStyle(color: StyleRepo.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      // Delete the pagination controller when bottom sheet closes
      Get.delete<PaginationController<OfferModel>>(tag: 'offers_${order.id}');
    });
  }

  Future<ResponseModel> _fetchOffersApi(String orderId, int page, CancelToken cancelToken) async {
    try {
      Map<String, String> params = {'page': page.toString(), 'per_page': '10'};

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.getOrderOffers(orderId),
          method: RequestMethod.Get,
          params: params,
          cancelToken: cancelToken,
        ),
      );

      if (response.success && response.data != null) {
        List offersData;

        if (response.data is List) {
          offersData = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          offersData = data['data'] as List? ?? [];
        } else {
          offersData = [];
        }

        return ResponseModel(
          statusCode: 200,
          success: true,
          data: offersData,
          message: response.message,
        );
      }

      return response;
    } catch (e) {
      print('Error fetching offers: $e');
      rethrow;
    }
  }

  Widget buildOfferCard(OfferModel offer, OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 0),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StyleRepo.softWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Provider Info and Price
            Row(
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
                          ? Assets.icons.essentials.circleUser.svg()
                          : null,
                ),
                const SizedBox(width: 12),

                // Provider Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.providerName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Star Rating
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color:
                                index < offer.providerRating.floor()
                                    ? Colors.amber
                                    : Colors.grey[300],
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // Price Tag
                Text(
                  '${offer.price.toInt()} SEK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: StyleRepo.deepBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Location Row
            Row(
              children: [
                Assets.icons.essentials.locationPin.svg(
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(StyleRepo.grey, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Syria - Damascus',
                    style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Action Buttons Row
            Row(
              children: [
                // Details Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewSpecificOffer(offer, order),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.fromLTRB(26, 9, 26, 9),
                      backgroundColor: StyleRepo.paleLavender,
                    ),
                    child: Text(
                      tr(LocaleKeys.orders_details),
                      style: TextStyle(
                        color: StyleRepo.lavender,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Accept Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOfferFromCard(offer, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StyleRepo.forestGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      tr(LocaleKeys.orders_accept),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptOfferFromCard(OfferModel offer, OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.orders_accept_offer)),
        content: Text(
          tr(
            LocaleKeys.orders_accept_offer_confirmation,
            namedArgs: {"providerName": offer.providerName},
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_cancel))),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close bottom sheet
              _performAcceptOffer(offer, order);
            },
            child: Text(
              tr(LocaleKeys.orders_accept),
              style: TextStyle(color: StyleRepo.forestGreen),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performAcceptOffer(OfferModel offer, OrderModel order) async {
    if (isAcceptingOffer.value) return; // Prevent multiple calls

    isAcceptingOffer.value = true;

    try {
      // Show loading toast
      PopUpToast.show(tr(LocaleKeys.orders_accepting_offer));

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.accept_offer,
          method: RequestMethod.Post,
          body: {'offer_id': offer.id, 'order_id': order.id},
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        await _handleSuccessfulOfferAcceptance(offer, order, response);
      } else {
        _handleOfferAcceptanceError(response);
      }
    } catch (e) {
      print('Error accepting offer: $e');
      PopUpToast.show(tr(LocaleKeys.orders_network_error));
    } finally {
      isAcceptingOffer.value = false;
    }
  }

  Future<void> _handleSuccessfulOfferAcceptance(
    OfferModel offer,
    OrderModel order,
    ResponseModel response,
  ) async {
    try {
      PopUpToast.show(tr(LocaleKeys.orders_offer_accepted_successfully));

      // Refresh the current tab to reflect the updated order status
      await _refreshCurrentTab();
    } catch (e) {
      print('Error handling successful offer acceptance: $e');
      PopUpToast.show(tr(LocaleKeys.orders_failed_to_accept_offer));
    }
  }

  // Handle offer acceptance error
  void _handleOfferAcceptanceError(ResponseModel response) {
    String errorMsg = 'Failed to accept offer. Please try again.';

    // Try to extract more specific error message from response
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
    print('Accept offer API error: ${response.statusCode} - $errorMsg');
  }

  void _viewSpecificOffer(OfferModel offer, OrderModel order) {
    Get.back(); // Close bottom sheet

    Get.to(() => OfferDetailsPage(), arguments: {'offer': offer, 'order': order});
  }

  void _showOrderDetailsDialog(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: Text(tr(LocaleKeys.orders_order_details)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr(LocaleKeys.orders_order_id)}: ${order.id}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${tr(LocaleKeys.orders_service)}: ${order.serviceCategory}'),
            const SizedBox(height: 8),
            Text('${tr(LocaleKeys.orders_Subcategory)}: ${order.serviceSubcategory}'),
            const SizedBox(height: 8),
            Text('${tr(LocaleKeys.orders_location)}: ${order.location}'),
            const SizedBox(height: 8),
            Text('${tr(LocaleKeys.orders_status)}: ${order.status.name}'),
            const SizedBox(height: 8),
            if ((order.offerCount ?? 0) > 0)
              Text('${tr(LocaleKeys.orders_offers)}: ${order.offerCount}'),
            const SizedBox(height: 8),
            Text('${tr(LocaleKeys.orders_description)}: ${order.description}'),
            if (order.cancelReason != null && order.cancelReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${tr(LocaleKeys.orders_cancel_reason)}: ${order.cancelReason}',
                style: TextStyle(color: StyleRepo.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(tr(LocaleKeys.common_close))),
          if (order.status == OrderStatus.pending)
            TextButton(
              onPressed: () {
                Get.back();
                _editOrder(order);
              },
              child: Text(tr(LocaleKeys.orders_edit_order)),
            ),
        ],
      ),
    );
  }

  // Navigate to ReviewOfferPage with proper data
  void navigateToReviewOffer(OrderModel order) {
    // Prepare arguments for ReviewOfferPage
    Map<String, dynamic> arguments = {
      'orderId': order.id,
      'orderData': {
        'apiData': {
          'date': DateFormat('yyyy-MM-dd').format(order.dateTime),
          'start_at': DateFormat('HH:mm').format(order.dateTime),
        },
      },
      'requesterName': 'Customer',
      'categoryTitle': order.serviceCategory,
      'orderDescription': order.description,
      'isFromOrdersPage': true,
    };

    // Add offer/provider data if available
    if ((order.offerCount ?? 0) > 0) {
      arguments.addAll({
        'offerDescription': 'Service assigned',
        'price': order.minPrice ?? '0',
        'executionTime': '1',
        'timeUnit': 'day',
        'galleryImages': [],
        'priceRange': '${order.minPrice ?? 0} - ${order.maxPrice ?? 0} SEK',
      });
    }

    Get.to(() => ReviewOfferPage(), arguments: arguments);
  }

  void cancelOrder(OrderModel order) {
    _showCancellationReasonBottomSheet(order);
  }

  void _showCancellationReasonBottomSheet(OrderModel order) {
    int selectedReasonId = 0;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        tr(LocaleKeys.orders_reason_for_cancellation),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: StyleRepo.deepBlue,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(LocaleKeys.orders_specify_cancellation_reason),
                    style: TextStyle(fontSize: 14, color: StyleRepo.grey),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic content based on loading state
                  Obx(() {
                    if (isLoadingCancelReasons.value) {
                      return Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: StyleRepo.deepBlue),
                            const SizedBox(height: 16),
                            Text(
                              tr(LocaleKeys.orders_loading_cancellation_reasons),
                              style: TextStyle(color: StyleRepo.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    if (cancelReasons.isEmpty) {
                      return Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            tr(LocaleKeys.orders_failed_to_load_cancel_reasons),
                            style: TextStyle(color: Colors.red[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchCancellationReasons,
                            style: ElevatedButton.styleFrom(backgroundColor: StyleRepo.deepBlue),
                            child: Text(
                              tr(LocaleKeys.orders_retry),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }

                    // Display dynamic cancellation reasons
                    return Column(
                      children: [
                        ...cancelReasons.map((reason) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedReasonId = reason.id;
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
                                      reason.reasonText,
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
                      ],
                    );
                  }),

                  const SizedBox(height: 32),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isCancellingOrder.value
                                ? null
                                : () {
                                  if (selectedReasonId == 0) {
                                    PopUpToast.show(
                                      tr(LocaleKeys.orders_select_cancellation_reason),
                                    );
                                    return;
                                  }
                                  Get.back();
                                  _performCancelOrderWithReasonId(order, selectedReasonId);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StyleRepo.deepBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child:
                            isCancellingOrder.value
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  tr(LocaleKeys.orders_send),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Future<void> _performCancelOrderWithReasonId(OrderModel order, int reasonId) async {
    if (isCancellingOrder.value) return; // Prevent multiple calls

    isCancellingOrder.value = true;

    try {
      PopUpToast.show(tr(LocaleKeys.orders_cancelling_order));

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.cancel_order,
          method: RequestMethod.Post,
          body: {'order_id': order.id, 'order_cancel_reason_id': reasonId},
          copyHeader: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        ),
      );

      if (response.success) {
        PopUpToast.show(tr(LocaleKeys.orders_order_cancelled_successfully));
        await _refreshCurrentTab();
      } else {
        String errorMsg = 'Failed to cancel order. Please try again.';

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
        print('Cancel order API error: ${response.statusCode} - $errorMsg');
      }
    } catch (e) {
      print('Error cancelling order: $e');
      PopUpToast.show(tr(LocaleKeys.orders_network_error));
    } finally {
      isCancellingOrder.value = false;
    }
  }

  void _editOrder(OrderModel order) {
    PopUpToast.show('Edit functionality will be added here soon hehe maybe later :D');
  }

  Future<void> submitOrderRating(OrderModel order, int rating, String reviewText) async {
    try {
      // Show loading state
      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final formData = FormData.fromMap({
        'order_id': order.id,
        'rate': rating.toString(),
        'review': reviewText.isNotEmpty ? reviewText : '',
      });

      final response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.customer_review,
          method: RequestMethod.Post,
          body: formData,
          fromJson: (json) => json,
        ),
      );

      // Hide loading dialog
      Get.back();

      // Check for success - backend returns data as array: ["Review Created successfully"]
      if (response.success || (response.data != null && response.data is List)) {
        String successMessage = 'Thank you for your feedback!';

        // Try to get message from response data
        if (response.data is List && (response.data as List).isNotEmpty) {
          successMessage = (response.data as List).first.toString();
        }

        PopUpToast.show(successMessage);

        await _refreshCurrentTab();
      } else {
        PopUpToast.show(response.message);
      }
    } catch (e) {
      // Hide loading dialog if still showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Error submitting rating: $e');
      PopUpToast.show(tr(LocaleKeys.orders_error_submitting_rating));
    }
  }
}
