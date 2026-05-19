import 'package:flutter/material.dart';
import '../source_editor_screen_cubit.dart';

class TestSourceResult {
  final SourceTestType type;
  final String input;

  const TestSourceResult({required this.type, required this.input});
}

class TestSourceWidget extends StatefulWidget {
  final ValueChanged<TestSourceResult> onRunTest;

  const TestSourceWidget({super.key, required this.onRunTest});

  @override
  State<TestSourceWidget> createState() => _TestSourceWidgetState();
}

class _TestSourceWidgetState extends State<TestSourceWidget> {
  late final TextEditingController _controller;
  SourceTestType _selectedType = SourceTestType.getManga;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Test Source',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SourceTestType>(
            value: _selectedType,
            onChanged: (v) {
              if (v != null) setState(() => _selectedType = v);
            },
            items: SourceTestType.values.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.name),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: 'Function to Test'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: _selectedType == SourceTestType.searchUrl
                  ? 'Enter search query'
                  : 'Enter sample URL',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onRunTest(
                TestSourceResult(type: _selectedType, input: _controller.text),
              );
            },
            child: const Text('Run Test'),
          ),
        ],
      ),
    );
  }
}
