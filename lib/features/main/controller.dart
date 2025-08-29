import 'package:get/get.dart';

import '../../core/config/app_builder.dart';

class MainPageController extends GetxController {
  final currentPage = 0.obs;
  final lastProviderPage = 0.obs;
  final lastUserPage = 0.obs;
  final AppBuilder appBuilder = Get.find<AppBuilder>();

  void changePage(int index) {
    currentPage.value = index;

    // Save the last page for current mode
    if (appBuilder.isProviderMode.value) {
      lastProviderPage.value = index;
    } else {
      lastUserPage.value = index;
    }
  }

  void handleModeSwitch(bool isProviderMode) {
    // When switching mode, set currentPage to the last page of that mode
    currentPage.value = isProviderMode ? lastProviderPage.value : lastUserPage.value;

    // Make sure the page index is valid for the new mode
    final maxIndex = isProviderMode ? 4 : 5; // Provider has 4 pages (0-3), User has 5 pages (0-4)
    if (currentPage.value >= maxIndex) {
      currentPage.value = 0; // Go to home page if invalid
    }
  }
}
