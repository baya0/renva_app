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
        'title': 'Household Services',
        'svg': '',
        'min_price': 50,
        'max_price': 200,
        'prv_cnt': 5,
        'description': ['Cleaning', 'Ironing', 'Washing'],
        'keywords': [
          {'title': 'Cleaning'},
          {'title': 'Ironing'},
          {'title': 'Washing'},
        ],
        'subCategories': [
          {
            'id': 1,
            'title': 'House Cleaning',
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
        'title': 'Professional Services',
        'svg': '',
        'min_price': 100,
        'max_price': 500,
        'prv_cnt': 4,
        'description': ['Electrical', 'Plumbing', 'Painting'],
        'keywords': [
          {'title': 'Electrical'},
          {'title': 'Plumbing'},
          {'title': 'Painting'},
        ],
        'subCategories': [
          {
            'id': 2,
            'title': 'Electrical Work',
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
        'title': 'Personal Services',
        'svg': '',
        'min_price': 30,
        'max_price': 150,
        'prv_cnt': 2,
        'description': ['Personal Training', 'Tutoring'],
        'keywords': [
          {'title': 'Personal Training'},
          {'title': 'Tutoring'},
        ],
        'subCategories': [
          {
            'id': 3,
            'title': 'Personal Training',
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
        'title': 'Logistical Services',
        'svg': '',
        'min_price': 20,
        'max_price': 100,
        'prv_cnt': 3,
        'description': ['Delivery', 'Moving', 'Transportation'],
        'keywords': [
          {'title': 'Delivery'},
          {'title': 'Moving'},
          {'title': 'Transportation'},
        ],
        'subCategories': [
          {
            'id': 4,
            'title': 'Package Delivery',
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
        PopUpToast.show('No subcategories available for ${service.title}');
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

  String get statusText => tr('orders.select_services_type');
}
