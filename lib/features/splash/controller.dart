import 'package:get/get.dart';

import '../../core/config/app_builder.dart';
import '../main/routescontroller.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  loadData() async {
    await 5.seconds.delay();
    Get.find<AppBuilder>();
    final routeController = Get.put(
      routesController(),
      tag: 'route_controller',
      permanent: true,
    );
    routeController.onReady();
  }
}
