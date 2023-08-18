import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'base_route_args.dart';
import 'navigation_result_mixin.dart';

extension PushForResult on BuildContext {
  /// Push a page with args callback as an extra.
  void pushForResult<T>(
    String location, {
    Object? args,
    required ResultCallback<T>? callback,
  }) =>
      push(location, extra: BaseRouteArgs<T>(args: args, callback: callback));
}

extension ArgsHelper on GoRouterState {
  BaseRouteArgs<T>? getArgs<T>() {
    return (extra is BaseRouteArgs<T>) ? extra as BaseRouteArgs<T> : null;
  }
}
