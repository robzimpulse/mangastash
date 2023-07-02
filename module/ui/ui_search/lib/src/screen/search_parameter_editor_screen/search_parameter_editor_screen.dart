import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class SearchParameterEditorScreen extends StatelessWidget {
  const SearchParameterEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Advanced Search Screen'),
      ),
      // TODO: add form builder
      child: Center(
        child: Text('View'),
      ),
    );
  }

}