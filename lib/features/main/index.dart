import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/config/app_builder.dart';
import '../add_orders/index.dart';
import '../chat/index.dart';
import '../home/controller.dart';
import '../home/index.dart';
import '../orders/index.dart';
import '../profile/index.dart';
import '../provider/home/controller.dart';
import '../provider/home/index.dart';
import '../provider/orders/index.dart';
import 'controller.dart';
import 'widgets/nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainPageController());
    final appBuilder = Get.find<AppBuilder>();
    Get.put(HomePageController());
    Get.lazyPut(() => ProviderHomePageController());

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            final isProviderMode = appBuilder.isProviderMode.value;
            final isProvider = appBuilder.isProvider.value;
            final providerStatus = appBuilder.providerStatus.value;

            // Build pages array based on mode
            final List<Widget> pages =
                isProviderMode && isProvider
                    ? [
                      const ProviderHomePage(), // 0
                      _withNavBarPadding(_getOrdersPage(isProvider, isProviderMode)), // 1
                      const ChatPage(), // 2
                      const ProfilePage(), // 3
                    ]
                    : [
                      const HomePage(), // 0
                      _withNavBarPadding(_getOrdersPage(isProvider, isProviderMode)), // 1
                      const AddOrdersPage(), // 2
                      const ChatPage(), // 3
                      const ProfilePage(), // 4
                    ];

            // i am using controller.currentPage.value for IndexedStack index
            final index =
                controller.currentPage.value >= pages.length
                    ? pages.length - 1
                    : controller.currentPage.value;

            return IndexedStack(index: index, children: pages);
          }),
          const FloatingNavBar(),
        ],
      ),
    );
  }

  Widget _getOrdersPage(bool isProvider, bool isProviderMode) {
    if (isProvider && isProviderMode) {
      return ProviderOrdersPage(); // new provider orders page
    } else {
      return const OrdersPage(); //  customer orders page
    }
  }

  Widget _withNavBarPadding(Widget child) {
    final appBuilder = Get.find<AppBuilder>();

    return Obx(() {
      final bottom = MediaQuery.of(Get.context!).padding.bottom;

      final isProviderMode = appBuilder.isProviderMode.value;
      final providerStatus = appBuilder.providerStatus.value;

      // Padding should be applied unless: provider mode & not approved
      final shouldAddPadding = !(isProviderMode && providerStatus != "Approved");

      return Padding(
        padding: EdgeInsets.only(bottom: shouldAddPadding ? (70 + 28 + bottom) : 0),
        child: child,
      );
    });
  }
}
