import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopUpToast {
  static void show(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black45,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      borderRadius: 16,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
    );
  }
}
