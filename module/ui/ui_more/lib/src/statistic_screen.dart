import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const StatisticScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Statistic'),
      ),
      body: ListView(
        children: [

        ],
      ),
    );
  }
}
