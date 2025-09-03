import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:renva0/core/localization/localization.dart';

import 'core/config/app_builder.dart';
import 'core/routes/routes.dart';
import 'core/style/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocalization.values.map((e) => e.locale).toList(),
      path: "assets/translations",
      fallbackLocale: AppLocalization.en.locale,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppBuilder());

    return GetMaterialApp(
      title: 'Renva',
      theme: AppStyle.theme,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,

      // Routing
      initialRoute: '/',
      unknownRoute: AppRouting.unknownRoute,
      getPages: AppRouting.routes,

      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}
