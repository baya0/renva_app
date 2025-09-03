import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import '../../../core/localization/strings.dart';
import '../../../core/services/rest_api/rest_api.dart';
import '../../../core/widgets/modern_toast.dart';
import '../home/models/service_categories.dart';

class AddOrderPageController extends GetxController {
  final RxString currentlyTappedId = ''.obs;

  Future<ResponseModel> fetchData(int page, CancelToken cancel) async {
    try {
      ResponseModel response = await APIService.instance.request(
        Request(
          endPoint: EndPoints.provider_categories,
          method: RequestMethod.Get,
          params: {'page': page.toString(), 'per_page': '10'},
          cancelToken: cancel,
        ),
      );

      if (response.success) {
        return response;
      } else {
        throw Exception('API failed');
      }
    } catch (e) {
      return _getFallbackData(page);
    }
  }

  ResponseModel _getFallbackData(int page) {
    final allServices = [
      {
        'id': 1,
        'title': tr(LocaleKeys.add_orders_household_services), // Use tr() function instead of .tr()
        'svg': '',
        'min_price': 50,
        'max_price': 200,
        'prv_cnt': 5,
        'description': [tr(LocaleKeys.add_orders_cleaning), tr(LocaleKeys.add_orders_washing)],
        'keywords': [
          {'title': tr(LocaleKeys.add_orders_cleaning)},
          {'title': tr(LocaleKeys.add_orders_washing)},
        ],
        'subCategories': [
          {
            'id': 1,
            'title': tr(LocaleKeys.add_orders_cleaning),
            'svg': '',
            'min_price': 50,
            'max_price': 150,
            'prv_cnt': 3,
            'description': [],
            'keywords': [],
          },
        ],
      },
      {
        'id': 2,
        'title': tr(LocaleKeys.add_orders_professional_services),
        'svg': '',
        'min_price': 100,
        'max_price': 500,
        'prv_cnt': 4,
        'description': [
          tr(LocaleKeys.add_orders_electrical_work),
          tr(LocaleKeys.add_orders_plumbing),
          tr(LocaleKeys.add_orders_painting),
        ],
        'keywords': [
          {'title': tr(LocaleKeys.add_orders_electrical_work)},
          {'title': tr(LocaleKeys.add_orders_plumbing)},
          {'title': tr(LocaleKeys.add_orders_painting)},
        ],
        'subCategories': [
          {
            'id': 2,
            'title': tr(LocaleKeys.add_orders_electrical_work),
            'svg': '',
            'min_price': 100,
            'max_price': 300,
            'prv_cnt': 2,
            'description': [],
            'keywords': [],
          },
        ],
      },
      {
        'id': 3,
        'title': tr(LocaleKeys.add_orders_personal_services),
        'svg': '',
        'min_price': 30,
        'max_price': 150,
        'prv_cnt': 2,
        'description': [
          tr(LocaleKeys.add_orders_personal_training),
          tr(LocaleKeys.add_orders_tutoring),
        ],
        'keywords': [
          {'title': tr(LocaleKeys.add_orders_personal_training)},
          {'title': tr(LocaleKeys.add_orders_tutoring)},
        ],
        'subCategories': [
          {
            'id': 3,
            'title': tr(LocaleKeys.add_orders_personal_training),
            'svg': '',
            'min_price': 30,
            'max_price': 100,
            'prv_cnt': 1,
            'description': [],
            'keywords': [],
          },
        ],
      },
      {
        'id': 4,
        'title': tr(LocaleKeys.add_orders_logistical_services),
        'svg': '',
        'min_price': 20,
        'max_price': 100,
        'prv_cnt': 3,
        'description': [
          tr(LocaleKeys.add_orders_package_delivery),
          tr(LocaleKeys.add_orders_moving),
          tr(LocaleKeys.add_orders_transportation),
        ],
        'keywords': [
          {'title': tr(LocaleKeys.add_orders_package_delivery)},
          {'title': tr(LocaleKeys.add_orders_moving)},
          {'title': tr(LocaleKeys.add_orders_transportation)},
        ],
        'subCategories': [
          {
            'id': 4,
            'title': tr(LocaleKeys.add_orders_package_delivery),
            'svg': '',
            'min_price': 20,
            'max_price': 50,
            'prv_cnt': 2,
            'description': [],
            'keywords': [],
          },
        ],
      },
    ];

    List<Map<String, dynamic>> pageData;
    if (page == 1) {
      pageData = allServices;
    } else {
      pageData = []; // No more data after page 1
    }

    return ResponseModel(success: true, data: pageData, message: 'Success');
  }

  void selectServiceCategory(ServiceCategoryModel service) {
    currentlyTappedId.value = service.id.toString();

    try {
      if (!service.hasSubcategories) {
        PopUpToast.show(
          tr(LocaleKeys.add_orders_no_subcategories, namedArgs: {'service': service.title}),
        );
        return;
      }

      final serviceData = {
        'categoryId': service.id,
        'categoryTitle': service.title,
        'categorySvg': service.svg,
        'subcategoriesData': service.subCategories,
        'minPrice': service.minPrice,
        'maxPrice': service.maxPrice,
      };

      Get.toNamed('/add_order_subcategory', arguments: serviceData);
    } catch (e) {
      PopUpToast.show(tr(LocaleKeys.common_error));
    } finally {
      Future.delayed(Duration(milliseconds: 200), () {
        currentlyTappedId.value = '';
      });
    }
  }

  bool isServiceTapped(String serviceId) {
    return currentlyTappedId.value == serviceId;
  }

  String get statusText => tr(LocaleKeys.add_orders_select_services_type);
}
