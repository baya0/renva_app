import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../rest_api/models/response_model.dart';
import '../controller.dart';
import '../widgets/empty.dart';
import '../widgets/initial_error.dart';
import '../widgets/initial_loading.dart';
import '../widgets/loading.dart';

class Pager<T> extends StatelessWidget {
  /// Create the pager scroll view.
  final Widget Function(
      BuildContext context, PaginationController<T> controller) builder;

  /// A tag added for [PaginationController] when inject it.
  final String tag;

  /// return the controller
  final void Function(PaginationController<T> paginationController)?
      onControllerInit;

  /// Function that get data.
  /// - page to control pagination.
  /// - cancel to control cancelling an api.
  /// Must return [ResponseModel] object.
  final Future<ResponseModel> Function(int page, CancelToken cancel) fetchApi;

  /// Function that make the modelling.
  final T Function(Map<String, dynamic> json) fromJson;

  /// The builder of children.
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// How much to the end of scroll to fetch the next page?
  final double closeToListEnd;

  /// Widget that displayed when fetching the first page.
  late final Widget initialLoading;

  /// Widget that displayed under the pager when fetching pages exept the first page.
  late final Widget loading;

  /// Widget that displayed under the pager when fetching pages exept the first page.
  late final Widget empty;

  /// Widget that displayed when the first page return an error
  final Widget Function(String)? errorWidget;

  /// if you want to provide the pager scrollCotroller.
  final ScrollController? scrollController;

  /// if you want to wrap the scroll view with [RefreshIndicator] and refreshing will be controlled by [PaginationController].
  final bool hasRefresh;

  /// if the scroll view is a sliver
  final bool isSliver;

  Pager({
    super.key,
    required this.builder,
    required this.tag,
    required this.fetchApi,
    required this.fromJson,
    required this.itemBuilder,
    this.onControllerInit,
    this.scrollController,
    this.loading = const PageLoading(),
    Widget? initialLoading,
    Widget? emptyWidget,
    this.errorWidget,
    this.closeToListEnd = 500,
    this.hasRefresh = true,
    this.isSliver = false,
  }) {
    assert(!isSliver || (isSliver && scrollController != null));
    log("$initialLoading");
    this.initialLoading = initialLoading ??
        (isSliver ? const InitialSliverLoading() : const InitialLoading());
    this.empty = isSliver ? const SliverEmptyWidget() : const EmptyWidget();
  }

  @override
  Widget build(BuildContext context) {
    PaginationController<T> controller;
    if (Get.isRegistered<PaginationController<T>>(tag: tag)) {
      controller = Get.find<PaginationController<T>>(tag: tag);
      controller.updateValues(
          scrollController: scrollController, closeToListEnd: closeToListEnd);
    } else {
      controller = Get.put(
        PaginationController<T>(
          fromJson: fromJson,
          fetchApi: fetchApi,
          closeToListEnd: closeToListEnd,
          scrollController: scrollController,
        ),
        tag: tag,
      );
    }
    onControllerInit?.call(controller);

    return Obx(
      () {
        if (controller.data.loading) {
          log("$initialLoading");
          return initialLoading;
        } else if (controller.data.hasError &&
            controller.data.valueLength == 0) {
          return errorWidget?.call(controller.data.error!) ??
              (isSliver
                  ? InitialSliverError(
                      error: controller.data.error!,
                    )
                  : InitialError(
                      error: controller.data.error!,
                      refresh: hasRefresh
                          ? () async => await controller.refreshData()
                          : null,
                    ));
        } else {
          if (controller.data.valueLength == 0) {
            return empty;
          }
          return builder(context, controller);
        }
      },
    );
  }
}
