import 'package:flutter/material.dart';

class PageLoading extends StatelessWidget {
  const PageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //TODO - pagination
        Text("loading"),
        const SizedBox(width: 12.0),
        const CircularProgressIndicator(),
      ],
    );
  }
}
