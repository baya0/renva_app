// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/features/splash/index.dart';
import '../../features/auth/complete_info/index.dart';
import '../../features/auth/login/index.dart';
import '../../features/auth/register/index.dart';
import '../../features/auth/vertification/index.dart';
import '../../features/home/index.dart';

class AppRouting {
  static GetPage unknownRoute = GetPage(
    name: "/unknown",
    page: () => SizedBox(),
  );

  static GetPage initialRoute = GetPage(name: "/", page: () => SplashScreen());

  static List<GetPage> routes = [
    initialRoute,
    ...Pages.values.map((e) => e.page),
  ];
}

enum Pages {
  //Auth
  login,
  signup,
  verify,
  complete_info,
  home;

  String get value => '/$name';

  GetPage get page => switch (this) {
    login => GetPage(name: value, page: () => LoginPage()),
    home => GetPage(name: value, page: () => HomePage()),
    verify => GetPage(name: value, page: () => VerifyPhonePage()),
    signup => GetPage(name: value, page: () => RegisterPage()),
    complete_info => GetPage(name: value, page: () => CompleteInfoPage()),
  };
}
