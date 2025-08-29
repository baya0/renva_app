import 'package:get/get.dart';

import '../../core/config/app_builder.dart';

class SplashScreenController extends GetxController {
  /// Must not be more than 4 seconds
  loadData() async {
    print(' Splash screen showing...');

    //  Show splash screen for 2 seconds
    await 2.seconds.delay();

    //  After splash delay, let AppBuilder handle everything
    await Get.find<AppBuilder>().init();
  }

  @override
  void onInit() {
    loadData(); // Start the process when controller initializes
    super.onInit();
  }
}
