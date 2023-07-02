import 'navigation_result_mixin.dart';

class BaseRouteArgs<T> {
  final Object? args;
  final ResultCallback<T>? callback;

  const BaseRouteArgs({
    this.args,
    this.callback,
  });
}