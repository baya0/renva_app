import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/error_widget.dart';
import '../../../widgets/loading.dart';
import '../obs.dart';

export '../constants/variable_status.dart';

class ObsVariableBuilder<T> extends StatelessWidget {
  final ObsVar<T> obs;
  final Widget Function(BuildContext context)? loader;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context, T value) builder;
  final Future<void> Function()? onRefresh;

  const ObsVariableBuilder({
    super.key,
    required this.obs,
    required this.builder,
    this.loader,
    this.errorBuilder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (obs.loading) {
        return loader?.call(context) ?? const LoadingWidget();
      } else if (obs.hasError) {
        final errorWidget = errorBuilder?.call(context, obs.error!) ??
            AppErrorWidget(error: obs.error!);
        if (onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: errorWidget);
        }
        return errorWidget;
      } else {
        return builder(context, obs.value as T);
      }
    });
  }
}

class ObsListBuilder<T> extends StatelessWidget {
  final ObsList<T> obs;
  final Widget Function(BuildContext context)? loader;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context, List<T> value) builder;
  final Future<void> Function()? onRefresh;

  const ObsListBuilder({
    super.key,
    required this.obs,
    required this.builder,
    this.loader,
    this.errorBuilder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (obs.loading) {
        return loader?.call(context) ?? const LoadingWidget();
      } else if (obs.hasError) {
        final errorWidget = errorBuilder?.call(context, obs.error!) ??
            AppErrorWidget(error: obs.error!);
        if (onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: errorWidget);
        }
        return errorWidget;
      } else {
        return builder(context, obs.value as List<T>);
      }
    });
  }
}
