import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // TODO: beautify error screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Text(text),
      ),
    );
  }
}
