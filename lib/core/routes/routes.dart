// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/features/add_orders/review_complete_order_page/index.dart';
import 'package:renva0/features/profile/edit_profile/index.dart';
import 'package:renva0/features/provider/home/index.dart';
import 'package:renva0/features/splash/index.dart';

import '../../features/add_orders/add_order_detail/index.dart';
import '../../features/add_orders/complete_order_detail/index.dart';
import '../../features/add_orders/index.dart';
import '../../features/add_orders/sub_orders/index.dart';
import '../../features/auth/complete_info/index.dart';
import '../../features/auth/login/index.dart';
import '../../features/auth/register/index.dart';
import '../../features/auth/reset_pass/index.dart';
import '../../features/auth/vertification/index.dart';
import '../../features/home/join_as_provider/form_index.dart';
import '../../features/home/join_as_provider/index.dart';
import '../../features/main/index.dart';
import '../../features/provider/add_offer/index.dart';
import '../../features/provider/orders/index.dart';
import '../../features/provider/review_offer/index.dart';
import '../../features/provider/view_order_detail/index.dart';

class AppRouting {
  static GetPage unknownRoute = GetPage(name: "/unknown", page: () => SizedBox());

  static GetPage initialRoute = GetPage(name: "/", page: () => SplashScreen());

  static List<GetPage> routes = [initialRoute, ...Pages.values.map((e) => e.page)];
}

enum Pages {
  // Auth
  login,
  signup,
  verify,
  complete_info,
  reset_password,

  // Main App
  home,

  // Profile
  edit_profile,

  // Provider
  join_as_provider,
  join_as_provider_form,
  provider_home,
  view_order_detail,
  add_offer_page,
  review_offer_page,

  // Orders Flow
  add_order_page,
  add_order_subcategory,
  add_order_details,
  complete_order_detail,
  review_completed_order_page,
  provider_orders_page;

  String get value => '/$name';

  GetPage get page => switch (this) {
    // Auth routes
    login => GetPage(
      name: value,
      page: () => LoginPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    signup => GetPage(
      name: value,
      page: () => RegisterPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    verify => GetPage(
      name: value,
      page: () => VerifyPhonePage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    complete_info => GetPage(
      name: value,
      page: () => CompleteInfoPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    reset_password => GetPage(
      name: value,
      page: () => ResetPasswordPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Main app
    home => GetPage(
      name: value,
      page: () => MainPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Profile routes
    edit_profile => GetPage(
      name: value,
      page: () => EditProfilePage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Provider routes
    join_as_provider => GetPage(
      name: value,
      page: () => JoinAsProviderPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    join_as_provider_form => GetPage(
      name: value,
      page: () => JoinAsProviderFormPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    provider_home => GetPage(
      name: value,
      page: () => ProviderHomePage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    view_order_detail => GetPage(
      name: value,
      page: () => ViewOrderDetail(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    add_offer_page => GetPage(
      name: value,
      page: () => AddOfferPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    review_offer_page => GetPage(
      name: value,
      page: () => ReviewOfferPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    provider_orders_page => GetPage(
      name: value,
      page: () => ProviderOrdersPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    //adding order process :D
    add_order_page => GetPage(
      name: value,
      page: () => AddOrdersPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    add_order_subcategory => GetPage(
      name: value,
      page: () => AddSubOrderPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    add_order_details => GetPage(
      name: value,
      page: () => AddOrderDetailsPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    complete_order_detail => GetPage(
      name: value,
      page: () => CompleteOrderPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    review_completed_order_page => GetPage(
      name: value,
      page: () => ReviewCompletedOrderPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  };
}
