import 'package:get/get_utils/get_utils.dart';

class Validators {
  static String? validateConfirmation(String? value, String originalValue, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.trParams({'field': fieldName});
    }
    if (value != originalValue) {
      return 'confirmation_invalid'.trParams({'field': fieldName});
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.trParams({'field': fieldName});
    }
    return null;
  }

  static String? validateName(String? value, {int minLength = 2, int maxLength = 50}) {
    if (value == null || value.trim().isEmpty) {
      return 'name_required'.tr;
    }

    value = value.trim();

    if (value.length < minLength) {
      return 'name_min'.trParams({'min': '$minLength'});
    }

    if (value.length > maxLength) {
      return 'name_max'.trParams({'max': '$maxLength'});
    }

    final nameRegex = RegExp(r"^[a-zA-Z\-\s]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'name_invalid'.tr;
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'url_required'.tr;
    }
    final urlPattern = r"^(http|https):\/\/[^\s$.?#].[^\s]*$";
    final urlRegex = RegExp(urlPattern);
    if (!urlRegex.hasMatch(value)) {
      return 'url_invalid'.tr;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'email_required'.tr;
    }

    final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return 'email_invalid'.tr;
    }

    return null;
  }
}
