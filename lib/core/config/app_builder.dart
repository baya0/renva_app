import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:renva0/core/config/role.dart';

import '../services/rest_api/rest_api.dart';

class AppBuilder extends GetxService {
  final box = GetStorage("app");
  late Role role;
  String? token;
  bool? isVerified;
  bool? isProfileCompleted;

  Future<void> loadData() async {
    await box.initStorage;

    // For testing, always start as unregistered to show login first
    role = Role.unregistered;
    token = null;
    isVerified = false;
    isProfileCompleted = false;

    // Comment out the storage loading for now to force login flow
    // role =
    //     box.hasData("role")
    //         ? Role.fromString(box.read("role"))
    //         : Role.unregistered;
    // token = box.read("token");
    // isVerified = box.read("isVerified") ?? false;
    // isProfileCompleted = box.read("isProfileCompleted") ?? false;
  }

  void setRole(Role role) {
    this.role = role;
    box.write("role", role.name);
  }

  void setToken(String? token) {
    this.token = token;
    if (token != null) {
      box.write("token", token);
    } else {
      box.remove("token");
    }
  }

  void setVerified(bool verified) {
    isVerified = verified;
    box.write("isVerified", verified);
  }

  void setProfileCompleted(bool completed) {
    isProfileCompleted = completed;
    box.write("isProfileCompleted", completed);
  }

  void logout() {
    setRole(Role.unregistered);
    setToken(null);
    setVerified(false);
    setProfileCompleted(false);
    Get.find<APIService>().setToken(null);
  }
}
