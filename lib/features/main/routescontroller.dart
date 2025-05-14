import 'package:get/get.dart';

import '../../core/config/app_builder.dart';
import '../../core/config/role.dart';
import '../../core/routes/routes.dart';

class routesController extends GetxController {
  // Flag to prevent multiple navigations
  bool _hasNavigated = false;

  @override
  void onReady() {
    super.onReady();

    // Wait for one frame to ensure GetMaterialApp is ready
    // Add a slightly longer delay to ensure everything is initialized
    Future.delayed(const Duration(milliseconds: 300), _handleNavigation);
  }

  void _handleNavigation() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final appBuilder = Get.find<AppBuilder>();
    final role = appBuilder.role;
    final bool isVerified = appBuilder.isVerified ?? false;
    final bool isProfileCompleted = appBuilder.isProfileCompleted ?? false;

    switch (role) {
      case Role.user:
        if (!isVerified) {
          // User registered but not verified
          Get.offAllNamed(Pages.verify.value);
        } else if (!isProfileCompleted) {
          // User verified but profile not completed
          Get.offAllNamed(Pages.complete_info.value);
        } else {
          // User verified and profile completed
          Get.offAllNamed(Pages.home.value);
        }
        break;
      case Role.guest:
        // Guests can view limited content
        Get.offAllNamed(Pages.home.value);
        break;
      case Role.new_user:
        // Just registered, needs verification
        Get.offAllNamed(Pages.verify.value);
        break;
      case Role.unregistered:
        // Not registered, show login page
        Get.offAllNamed(Pages.login.value);
        break;
    }
  }

  // Public method to reset navigation state and trigger navigation
  void checkAndNavigate() {
    _hasNavigated = false;
    _handleNavigation();
  }
}
