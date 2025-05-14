import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renva0/core/localization/localization.dart';

import 'core/config/app_builder.dart';
import 'core/routes/routes.dart';
import 'core/services/rest_api/api_service.dart';
import 'core/style/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final appBuilder = Get.put(AppBuilder()); // Register and retrieve instance
  await appBuilder.loadData();
  Get.put(APIService(token: appBuilder.token));

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
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppStyle.theme,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      initialRoute: '/',
      unknownRoute: AppRouting.unknownRoute,
      getPages: AppRouting.routes,
    );
  }
}
