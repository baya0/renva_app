import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(Icons.warning_amber));
  }
}

class SliverEmptyWidget extends StatelessWidget {
  const SliverEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(delegate: SliverChildListDelegate([const EmptyWidget()]));
  }
}
