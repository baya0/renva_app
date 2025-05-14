import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitialError extends StatelessWidget {
  final Future Function()? refresh;
  final String error;
  const InitialError({super.key, this.refresh, required this.error});

  @override
  Widget build(BuildContext context) {
    if (refresh != null) {
      return RefreshIndicator(
        onRefresh: refresh!,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      error,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ScrollConfiguration(
              behavior:
                  const MaterialScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: SizedBox(height: Get.height + 1, width: Get.width),
              ),
            )
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            child: Text(
              error,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class InitialSliverError extends StatelessWidget {
  final String error;
  const InitialSliverError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
              child: Text(
                error,
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      )
    ]));
  }
}
