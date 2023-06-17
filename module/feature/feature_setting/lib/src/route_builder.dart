import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';

import 'route_path.dart';

class RouteBuilder extends BaseRouteBuilder {
  @override
  List<GoRoute> routes() {
    return [
      GoRoute(
        name: RoutePath.main,
        path: RoutePath.main,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Setting'),
          ),
        ),
      ),
    ];
  }
}
