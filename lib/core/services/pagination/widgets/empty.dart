import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO - pagination
    return Center(child: Text("No data"));
  }
}

class SliverEmptyWidget extends StatelessWidget {
  const SliverEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(delegate: SliverChildListDelegate([const EmptyWidget()]));
  }
}
