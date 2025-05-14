import 'package:flutter/material.dart';

class InitialLoading extends StatelessWidget {
  const InitialLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class InitialSliverLoading extends StatelessWidget {
  const InitialSliverLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate(
            [const Center(child: CircularProgressIndicator())]));
  }
}
