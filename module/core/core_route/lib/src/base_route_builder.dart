import 'package:go_router/go_router.dart';
import 'package:service_locator/service_locator.dart';

abstract class BaseRouteBuilder {
  RouteBase root({required ServiceLocator locator});
  List<RouteBase> routes({required ServiceLocator locator});
}
