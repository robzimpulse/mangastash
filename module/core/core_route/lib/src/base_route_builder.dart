import 'package:go_router/go_router.dart';

abstract class BaseRouteBuilder {
  RouteBase root();
  List<RouteBase> routes();
}