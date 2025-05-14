import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';
import '../widgets/page_error.dart';
import 'pager.dart';

class ListViewPagination<T> extends Pager<T> {
  ListViewPagination.builder({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    super.onControllerInit,
    super.closeToListEnd,
    super.scrollController,
    super.hasRefresh,
    super.loading,
    super.initialLoading,
    super.errorWidget,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                shrinkWrap: false,
                physics: physics ?? const AlwaysScrollableScrollPhysics(),
                padding: padding,
                reverse: reverse,
                scrollDirection: scrollDirection,
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(
                      () {
                        if (controller.loading) {
                          return loading;
                        } else {
                          return PageError(
                            retry: () => controller.loadData(),
                            error: controller.data.error!,
                          );
                        }
                      },
                    );
                  }
                  return itemBuilder(
                    context,
                    index,
                    controller.data.value![index],
                  );
                },
              );
            });

            if (hasRefresh) {
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: () async => await controller.refreshData(),
                child: scrollView,
              );
            } else {
              return scrollView;
            }
          },
        );

  ListViewPagination.separated({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    super.onControllerInit,
    super.closeToListEnd,
    super.scrollController,
    super.hasRefresh,
    super.loading,
    super.initialLoading,
    super.errorWidget,
    required Widget Function(BuildContext, int) separatorBuilder,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return ListView.separated(
                controller: controller.scrollController,
                shrinkWrap: false,
                physics: physics ?? const AlwaysScrollableScrollPhysics(),
                padding: padding,
                reverse: reverse,
                scrollDirection: scrollDirection,
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                separatorBuilder: separatorBuilder,
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(
                      () {
                        if (controller.loading) {
                          return loading;
                        } else {
                          return PageError(
                            retry: () => controller.loadData(),
                            error: controller.data.error ?? "",
                          );
                        }
                      },
                    );
                  }
                  return itemBuilder(
                    context,
                    index,
                    controller.data.value![index],
                  );
                },
              );
            });

            if (hasRefresh) {
              return RefreshIndicator(
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: () async => await controller.refreshData(),
                child: scrollView,
              );
            } else {
              return scrollView;
            }
          },
        );

  ListViewPagination.sliver({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    required super.scrollController,
    super.onControllerInit,
    super.closeToListEnd,
    super.loading,
    super.initialLoading,
    super.errorWidget,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          hasRefresh: false,
          isSliver: true,
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return SliverList.builder(
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(
                      () {
                        if (controller.loading) {
                          return loading;
                        } else {
                          return PageError(
                            retry: () => controller.loadData(),
                            error: controller.data.error!,
                          );
                        }
                      },
                    );
                  }
                  return itemBuilder(
                    context,
                    index,
                    controller.data.value![index],
                  );
                },
              );
            });

            if (padding != null && padding != EdgeInsets.zero) {
              return SliverPadding(
                padding: padding,
                sliver: scrollView,
              );
            }

            return scrollView;
          },
        );

  ListViewPagination.sliverSeperated({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    required super.scrollController,
    super.onControllerInit,
    super.closeToListEnd,
    super.loading,
    super.initialLoading,
    super.errorWidget,
    required Widget Function(BuildContext, int) separatorBuilder,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          hasRefresh: false,
          isSliver: true,
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return SliverList.separated(
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                separatorBuilder: separatorBuilder,
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(
                      () {
                        if (controller.loading) {
                          return loading;
                        } else {
                          return PageError(
                            retry: () => controller.loadData(),
                            error: controller.data.error!,
                          );
                        }
                      },
                    );
                  }
                  return itemBuilder(
                    context,
                    index,
                    controller.data.value![index],
                  );
                },
              );
            });

            if (padding != null && padding != EdgeInsets.zero) {
              return SliverPadding(
                padding: padding,
                sliver: scrollView,
              );
            }

            return scrollView;
          },
        );
}
