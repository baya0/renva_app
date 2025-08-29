import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller.dart';
import '../widgets/page_error.dart';
import 'pager.dart';

// ignore: must_be_immutable
class GridViewPagination<T> extends Pager<T> {
  GridViewPagination.builder({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    super.onControllerInit,
    super.scrollController,
    super.hasRefresh,
    super.loading,
    super.initialLoading,
    super.emptyWidget,
    super.errorWidget,
    super.closeToListEnd,
    required SliverGridDelegate gridDelegate,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return GridView.builder(
                controller: controller.scrollController,
                gridDelegate: gridDelegate,
                shrinkWrap: false,
                physics: physics ?? const AlwaysScrollableScrollPhysics(),
                padding: padding,
                reverse: reverse,
                scrollDirection: scrollDirection,
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(() {
                      if (controller.loading) {
                        return loading;
                      } else if (controller.data.hasError) {
                        return PageError(retry: () => controller.loadData());
                      } else {
                        return const SizedBox();
                      }
                    });
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

  // GridViewPagination.aligned({
  //   super.key,
  //   required super.tag,
  //   required super.fetchApi,
  //   required super.fromJson,
  //   required super.itemBuilder,
  //   super.onControllerInit,
  //   super.scrollController,
  //   super.hasRefresh,
  //   super.loading,
  //   super.initialLoading,
  //   super.emptyWidget,
  //   super.errorWidget,
  //   super.closeToListEnd,
  //   required int crossAxisCount,
  //   double mainAxisSpacing = 0.0,
  //   double crossAxisSpacing = 0.0,
  //   EdgeInsetsGeometry? padding,
  //   Axis scrollDirection = Axis.vertical,
  //   ScrollPhysics? physics,
  //   bool reverse = false,
  // }) : super(
  //        builder: (BuildContext context, PaginationController<T> controller) {
  //          Widget scrollView = Obx(() {
  //            return AlignedGridView.count(
  //              controller: controller.scrollController,
  //              crossAxisCount: crossAxisCount,
  //              mainAxisSpacing: mainAxisSpacing,
  //              crossAxisSpacing: crossAxisSpacing,
  //              shrinkWrap: false,
  //              physics: physics ?? const AlwaysScrollableScrollPhysics(),
  //              padding: padding,
  //              reverse: reverse,
  //              scrollDirection: scrollDirection,
  //              itemCount:
  //                  controller.data.valueLength +
  //                  (!controller.isFinished ? 1 : 0),
  //              itemBuilder: (context, index) {
  //                if (index == controller.data.valueLength) {
  //                  return Obx(() {
  //                    if (controller.loading) {
  //                      return loading;
  //                    } else if (controller.data.hasError) {
  //                      return PageError(retry: () => controller.loadData());
  //                    } else {
  //                      return const SizedBox();
  //                    }
  //                  });
  //                }
  //                return itemBuilder(
  //                  context,
  //                  index,
  //                  controller.data.value![index],
  //                );
  //              },
  //            );
  //          });

  //          if (hasRefresh) {
  //            return RefreshIndicator(
  //              triggerMode: RefreshIndicatorTriggerMode.anywhere,
  //              onRefresh: () async => await controller.refreshData(),
  //              child: scrollView,
  //            );
  //          } else {
  //            return scrollView;
  //          }
  //        },
  //      );

  GridViewPagination.sliver({
    super.key,
    required super.tag,
    required super.fetchApi,
    required super.fromJson,
    required super.itemBuilder,
    super.onControllerInit,
    super.scrollController,
    super.loading,
    super.initialLoading,
    super.emptyWidget,
    super.errorWidget,
    super.closeToListEnd,
    required SliverGridDelegate gridDelegate,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool reverse = false,
  }) : super(
          hasRefresh: false,
          isSliver: true,
          builder: (BuildContext context, PaginationController<T> controller) {
            Widget scrollView = Obx(() {
              return SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: controller.data.valueLength +
                    (!controller.isFinished ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.data.valueLength) {
                    return Obx(() {
                      if (controller.loading) {
                        return loading;
                      } else if (controller.data.hasError) {
                        return PageError(retry: () => controller.loadData());
                      } else {
                        return const SizedBox();
                      }
                    });
                  }
                  return itemBuilder(
                    context,
                    index,
                    controller.data.value![index],
                  );
                },
              );
            });

            return scrollView;
          },
        );

  // GridViewPagination.alignedSliver({
  //   super.key,
  //   required super.tag,
  //   required super.fetchApi,
  //   required super.fromJson,
  //   required super.itemBuilder,
  //   super.onControllerInit,
  //   super.scrollController,
  //   super.loading,
  //   super.initialLoading,
  //   super.emptyWidget,
  //   super.errorWidget,
  //   super.closeToListEnd,
  //   EdgeInsetsGeometry? padding,
  //   Axis scrollDirection = Axis.vertical,
  //   ScrollPhysics? physics,
  //   bool reverse = false,
  //   double mainAxisSpacing = 0.0,
  //   double crossAxisSpacing = 0.0,
  //   required int crossAxisCount,
  // }) : super(
  //        isSliver: true,
  //        builder: (BuildContext context, PaginationController<T> controller) {
  //          Widget scrollView = Obx(() {
  //            return SliverAlignedGrid.count(
  //              crossAxisCount: crossAxisCount,
  //              mainAxisSpacing: mainAxisSpacing,
  //              crossAxisSpacing: crossAxisSpacing,
  //              itemCount:
  //                  controller.data.valueLength +
  //                  (!controller.isFinished ? 1 : 0),
  //              itemBuilder: (context, index) {
  //                if (index == controller.data.valueLength) {
  //                  return Obx(() {
  //                    if (controller.loading) {
  //                      return loading;
  //                    } else if (controller.data.hasError) {
  //                      return PageError(retry: () => controller.loadData());
  //                    } else {
  //                      return const SizedBox();
  //                    }
  //                  });
  //                }
  //                return itemBuilder(
  //                  context,
  //                  index,
  //                  controller.data.value![index],
  //                );
  //              },
  //            );
  //          });

  //          if (padding != null && padding != EdgeInsets.zero) {
  //            return SliverPadding(padding: padding, sliver: scrollView);
  //          }

  //          return scrollView;
  //        },
  //      );
}
