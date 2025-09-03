import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/services/state_management/obs.dart';
import '../../../core/widgets/modern_toast.dart';
import '../models/service_categories.dart';

class JoinAsProviderController extends GetxController {
  final ObsList<ServiceCategoryModel> availableServices = ObsList<ServiceCategoryModel>([]);
  final RxList<String> selectedServiceIds = <String>[].obs;
  final ObsVar<String> errorMessage = ObsVar<String>('');
  final RxBool isLoading = false.obs;

  APIService? _apiService;

  @override
  void onInit() {
    super.onInit();
    _initializeAPIService();
    fetchAvailableServices();
    _loadSelectedServices();
  }

  void _initializeAPIService() {
    try {
      _apiService = Get.find<APIService>();
    } catch (e) {
      _apiService = null;
    }
  }

  Future<void> fetchAvailableServices() async {
    try {
      // Reset sets loading state automatically
      availableServices.reset();
      selectedServiceIds.clear();
      errorMessage.reset();

      if (_apiService != null) {
        await _fetchFromAPI();
      } else {
        await _loadFallbackServices();
      }
    } catch (e) {
      //  Setting error automatically updates state
      availableServices.error = e.toString();
      errorMessage.error = e.toString();

      // Fallback to default services on error
      await _loadFallbackServices();
    }
  }

  //  For pull-to-refresh functionality
  Future<void> refreshData() async {
    await fetchAvailableServices();
  }

  Future<void> _fetchFromAPI() async {
    try {
      final response = await _apiService!.request(
        Request(
          endPoint: EndPoints.provider_categories,
          method: RequestMethod.Get,
          fromJson: (json) => json,
        ),
      );

      if (response.success && response.data != null) {
        List<dynamic> categoriesData;

        if (response.data is List) {
          categoriesData = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          categoriesData = responseData['data'] ?? [];
        } else {
          throw Exception('Unexpected response data type: ${response.data.runtimeType}');
        }

        List<ServiceCategoryModel> services =
            categoriesData
                .map((categoryJson) => ServiceCategoryModel.fromJson(categoryJson))
                .toList();

        //  Setting value automatically updates state to hasData
        availableServices.value = services;
        selectedServiceIds.clear();
        errorMessage.value = ''; // Clear any previous errors
      } else {
        throw Exception('API returned error: ${response.message}');
      }
    } catch (e) {
      print('🚨 Error in API fetch: $e');
      rethrow;
    }
  }

  // Fallback services for development/offline
  Future<void> _loadFallbackServices() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      List<ServiceCategoryModel> fallbackServices = [
        ServiceCategoryModel(
          id: 1,
          title: 'Household Services',
          prvCnt: 5,
          keywords: [
            Keyword(title: 'Cleaning'),
            Keyword(title: 'Ironing'),
            Keyword(title: 'Washing'),
          ],
          svg: '',
          minPrice: 50,
          maxPrice: 200,
          subCategories: [],
        ),
        ServiceCategoryModel(
          id: 2,
          title: 'Professional Services',
          prvCnt: 4,
          keywords: [
            Keyword(title: 'Electrical'),
            Keyword(title: 'Plumbing'),
            Keyword(title: 'Painting'),
          ],
          svg: '',
          minPrice: 100,
          maxPrice: 500,
          subCategories: [],
        ),
        ServiceCategoryModel(
          id: 3,
          title: 'Personal Services',
          prvCnt: 2,
          keywords: [Keyword(title: 'Personal Training'), Keyword(title: 'Tutoring')],
          svg: '',
          minPrice: 30,
          maxPrice: 150,
          subCategories: [],
        ),
        ServiceCategoryModel(
          id: 4,
          title: 'Logistical Services',
          prvCnt: 0,
          keywords: [
            Keyword(title: 'Transport'),
            Keyword(title: 'Deliveries'),
            Keyword(title: 'Picking'),
          ],
          svg: '',
          minPrice: 25,
          maxPrice: 300,
          subCategories: [],
        ),
      ];

      availableServices.value = fallbackServices;
      selectedServiceIds.clear();
      errorMessage.value = '';
    } catch (e) {
      availableServices.error = e.toString();
    }
  }

  void selectService(String serviceId) {
    try {
      if (selectedServiceIds.contains(serviceId)) {
        selectedServiceIds.remove(serviceId);
      } else {
        selectedServiceIds.add(serviceId);
      }
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.join_provider_failed_to_select));
    }
  }

  void onNext() {
    if (!hasSelection) {
      PopUpToast.show(tr(LocaleKeys.join_provider_select_at_least_one));
      return;
    }

    if (availableServices.hasError) {
      PopUpToast.show(tr(LocaleKeys.join_provider_failed_to_load_retry));
      return;
    }

    if (!availableServices.hasData) {
      PopUpToast.show(tr(LocaleKeys.join_provider_no_services_available_error));
      return;
    }

    try {
      isLoading.value = true;

      final selectedDetails =
          selectedServiceIds.map((id) {
            final service = availableServices.value!.firstWhereOrNull((s) => s.id.toString() == id);

            return {
              'id': id,
              'name': service?.title ?? tr(LocaleKeys.join_provider_unknown_service),
              'subtitle': service?.subtitle ?? '',
            };
          }).toList();

      Get.toNamed('/join_as_provider_form', arguments: {'selectedServices': selectedDetails});
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.join_provider_failed_to_navigate));
    } finally {
      isLoading.value = false;
    }
  }

  void _loadSelectedServices() {
    try {
      final arguments = Get.arguments;

      if (arguments != null && arguments is Map) {
        final services = arguments['selectedServices'];

        if (services != null && services is List) {
          //  Convert the arguments into our selectedServices list
          selectedServiceIds.value = List<String>.from(
            services.map((service) => Map<String, String>.from(service)),
          );
        }
      }
    } catch (e) {
      selectedServiceIds.value = []; // Fallback to empty list
    }
  }

  void retryFetch() {
    fetchAvailableServices();
  }

  void clearSelection() {
    selectedServiceIds.clear();
  }

  bool isServiceSelected(String serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  bool get hasServices => availableServices.hasData && availableServices.valueLength > 0;
  bool get hasSelection => selectedServiceIds.isNotEmpty;
  bool get isServicesLoading => availableServices.loading;
  bool get hasError => availableServices.hasError || errorMessage.hasError;

  String get statusText {
    if (isServicesLoading) return tr(LocaleKeys.join_provider_loading_services);
    if (hasError) {
      String error =
          availableServices.error ?? errorMessage.error ?? tr(LocaleKeys.errors_unknown_error);
      return '${tr(LocaleKeys.join_provider_error_prefix)}$error';
    }
    if (!hasServices) return tr(LocaleKeys.join_provider_no_services_available);
    return tr(
      LocaleKeys.join_provider_services_available,
    ).replaceAll('{count}', availableServices.valueLength.toString());
  }

  String get selectionStatusText {
    if (!hasSelection) return tr(LocaleKeys.join_provider_no_services_selected);
    return tr(
      LocaleKeys.join_provider_services_selected,
    ).replaceAll('{count}', selectedServiceIds.length.toString());
  }

  bool get canProceed =>
      hasServices && hasSelection && !isServicesLoading && !hasError && !isLoading.value;
}
