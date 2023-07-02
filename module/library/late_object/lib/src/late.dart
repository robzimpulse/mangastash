import 'dart:async';

import 'package:flutter/foundation.dart';

/// Late variable that provide initialization check before calling it.
///
/// Currently [late] operator could not check if the variable is initialized or not.
class Late<T> {
  final ValueNotifier<bool> _initialization = ValueNotifier(false);
  late T _val;

  /// Create a [Late] instance.
  ///
  /// ```dart
  /// Late<String> typedLateString = Late();
  /// ```
  Late([T? value]) {
    if (value != null) {
      val = value;
    }
  }

  /// will return true if the value is already initialized.
  bool get isInitialized {
    return _initialization.value;
  }

  /// get value of [Late] instance.
  ///
  /// Make sure check it with [isInitialized] before using it.
  T get val => _val;

  /// set value of [Late] instance.
  ///
  /// ```dart
  /// lateString.val = "initializing here";
  /// ```
  set val(T val) => this
    .._initialization.value = true
    .._val = val;
}

/// extends any object to create [Late] instance.
extension LateExtension<T> on T {
  /// create [Late] instance from an object data type.
  ///
  /// ```dart
  /// var lateString = "".late;
  /// ```
  Late<T> get late => Late<T>();
}

/// [Late] extension to wait for an initialization.
extension ExtLate on Late {
  /// wait for an initialization.
  ///
  /// ```dart
  /// Late<String> lateVariable = Late();
  ///
  /// lateTest() async {
  ///   if(!lateVariable.isInitialized) {
  ///     await lateVariable.wait;
  ///   }
  ///   // use lateVariable here, after initialization.
  /// }
  /// ```
  Future<bool> get wait {
    Completer<bool> completer = Completer();
    _initialization.addListener(() async {
      completer.complete(_initialization.value);
    });

    return completer.future;
  }
}
