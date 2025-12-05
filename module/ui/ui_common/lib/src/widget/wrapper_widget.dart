import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({
    super.key,
    required this.locatorBuilder,
    required this.appScreenBuilder,
    required this.splashScreenBuilder,
    required this.errorScreenBuilder,
  });

  final Widget Function(BuildContext, ServiceLocator) appScreenBuilder;

  final WidgetBuilder splashScreenBuilder;

  final Widget Function(BuildContext, Object) errorScreenBuilder;

  final ValueGetter<Future<ServiceLocator>> locatorBuilder;

  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_WrapperScreenState>()?.restartApp();
  }

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  late Future<ServiceLocator> _locator;
  late Key _key;

  @override
  void initState() {
    super.initState();
    _locator = widget.locatorBuilder();
    _key = UniqueKey();
  }

  void restartApp() {
    setState(() {
      _key = UniqueKey();
      _locator = widget.locatorBuilder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: FutureBuilder(
        future: _locator,
        builder: (context, snapshot) {
          /// render splash screen when future being processed
          if (snapshot.connectionState != ConnectionState.done) {
            return widget.splashScreenBuilder(context);
          }

          /// render error screen when future resolved error
          final error = snapshot.error;
          if (snapshot.hasError && error != null) {
            log(snapshot.error.toString(), error: snapshot.error);
            return widget.errorScreenBuilder(context, error);
          }

          /// render error screen when future resolved null data
          final data = snapshot.data;
          if (data == null) {
            final error = Exception('Locator not found');
            log(error.toString(), error: error);
            return widget.errorScreenBuilder(context, error);
          }

          /// render apps screen when future resolved non-null data
          return widget.appScreenBuilder(context, data);
        },
      ),
    );
  }
}