// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/style/repo.dart';
import '../../gen/assets.gen.dart';
import 'controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashScreenController());
    return Scaffold(
      backgroundColor: StyleRepo.softWhite,
      body: Center(
        child: Assets.images.logo.splashLight.svg(),
        //child: ,
      ),
    );
  }
}
