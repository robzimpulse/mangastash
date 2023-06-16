import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';

import '../feature_home.dart';

class HomeRouteBuilder extends BaseRouteBuilder {
  @override
  List<GoRoute> routes() {
    return [
      GoRoute(
        name: HomePath.main,
        path: HomePath.main,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Home'),
          ),
        ),
      ),
    ];
  }
}
