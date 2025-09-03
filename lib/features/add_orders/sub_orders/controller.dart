import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/widgets/modern_toast.dart';
import '../../home/models/service_categories.dart';

class AddSubOrderController extends GetxController {
  String categoryTitle = '';
  int categoryId = 0;
  int minPrice = 0;
  int maxPrice = 0;
  String serviceSvg = '';

  final RxList<SubCategoryModel> subcategories = <SubCategoryModel>[].obs;
  final Rx<SubCategoryModel?> selectedSubcategory = Rx<SubCategoryModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isDataLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgumentsFromPreviousPage();
    _fetchSubcategoriesFromAPI();
  }

  void _loadArgumentsFromPreviousPage() {
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final args = Get.arguments as Map<String, dynamic>;

        // Load basic data
        categoryId = args['categoryId'] ?? 0;
        categoryTitle = args['categoryTitle'] ?? tr('orders.services');
        minPrice = args['minPrice'] ?? 0;
        maxPrice = args['maxPrice'] ?? 0;
        serviceSvg = args['categorySvg'] ?? '';
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      _loadFallbackData();
    }
  }

  Future<void> _fetchSubcategoriesFromAPI() async {
    if (categoryId == 0) {
      _loadFallbackData();
      return;
    }

    try {
      isLoading.value = true;

      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: '${EndPoints.service_sub_categories}/$categoryId',
          method: RequestMethod.Get,
        ),
      );

      if (response.success && response.data != null) {
        List<dynamic> subcategoriesData = response.data;
        List<SubCategoryModel> subcategoriesList =
            subcategoriesData.map((json) => SubCategoryModel.fromJson(json)).toList();

        if (subcategoriesList.isNotEmpty) {
          _setSubcategoriesData(subcategoriesList);

          // Update price range based on first subcategory if available
          if (subcategoriesList.first.minPrice > 0) {
            minPrice = subcategoriesList.first.minPrice;
            maxPrice = subcategoriesList.first.maxPrice;
          }
        } else {
          _loadFallbackData();
        }
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      _loadFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  void _setSubcategoriesData(List<SubCategoryModel> data) {
    subcategories.assignAll(data);
    isDataLoaded.value = true;
  }

  void _loadFallbackData() {
    categoryTitle = 'Household Services';

    final newData = [
      SubCategoryModel(id: 1, title: 'Cleaning', svg: '', minPrice: 50, maxPrice: 200, prvCnt: 15),
      SubCategoryModel(id: 2, title: 'Washing', svg: '', minPrice: 30, maxPrice: 150, prvCnt: 12),
      SubCategoryModel(id: 3, title: 'Plant Care', svg: '', minPrice: 25, maxPrice: 100, prvCnt: 8),
      SubCategoryModel(id: 4, title: 'Pet Care', svg: '', minPrice: 40, maxPrice: 180, prvCnt: 10),
      SubCategoryModel(id: 5, title: 'Car Wash', svg: '', minPrice: 60, maxPrice: 250, prvCnt: 20),
    ];

    _setSubcategoriesData(newData);
    minPrice = 50;
    maxPrice = 200;
  }

  void selectSubcategory(SubCategoryModel subcategory) {
    try {
      selectedSubcategory.value = subcategory;
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.common_error));
    }
  }

  void onContinue() {
    if (!canContinue) {
      PopUpToast.show(tr('orders.please_select_subcategory'));
      return;
    }
    try {
      isLoading.value = true;
      final orderData = {
        'categoryId': categoryId, // Main category ID (from provider_categories)
        'subcategoryId': selectedSubcategory.value!.id, // Sub category ID (from sub_categories API)
        'categoryTitle': categoryTitle, // Main category title
        'subcategoryTitle': selectedSubcategory.value!.title, // Sub category title
        'minPrice': selectedSubcategory.value!.minPrice, // Use subcategory's price range
        'maxPrice': selectedSubcategory.value!.maxPrice,
        'serviceSvg': selectedSubcategory.value!.svg,
      };

      orderData.forEach((key, value) {});

      Get.toNamed('/add_order_details', arguments: orderData);
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.common_error));
    } finally {
      isLoading.value = false;
    }
  }

  bool get canContinue => selectedSubcategory.value != null && !isLoading.value;

  int get subcategoryCount => subcategories.length;

  bool isSubcategorySelected(SubCategoryModel subcategory) {
    return selectedSubcategory.value?.id == subcategory.id;
  }

  void clearSelection() {
    selectedSubcategory.value = null;
  }

  // Add refresh method
  Future<void> refreshSubcategories() async {
    await _fetchSubcategoriesFromAPI();
  }
}
