import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:late_object/late_object.dart';

/// Signature of callbacks that has generic argument and return no data.
typedef ResultCallback<T> = void Function(T?);

/// Mixin for Page to provide result when Page is popped.
mixin ResultProvider<T> on Widget {
  /// Callback to use when pop is called.
  /// Call init before using.
  final Late<ResultCallback<T>?> callback = Late();

  /// initialize [ResultProvider] mixin.
  void initOnResult(ResultCallback<T>? callback) {
    this.callback.val = callback;
  }

  /// Pop a page with result callback.
  /// [currentScreen] required to set flutter screen name as referrer in native,
  /// just leave it empty if current screen never expects back to native
  void popWithResult(
    BuildContext context,
    T? result,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.canPop()) return;
      if (callback.isInitialized) callback.val?.call(result);
    });
  }
}
