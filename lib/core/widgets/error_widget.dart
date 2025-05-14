import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String error;
  final bool withScrolling;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.withScrolling = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget errorWidget = Center(
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
    );

    if (withScrolling) {
      errorWidget = Stack(
        children: [
          errorWidget,
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox.expand(),
          ),
        ],
      );
    }

    return errorWidget;
  }
}
