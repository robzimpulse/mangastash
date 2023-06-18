import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // TODO: beautify error screen
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}
