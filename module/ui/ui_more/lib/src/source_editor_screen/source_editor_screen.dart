import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/dart.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'source_editor_screen_cubit.dart';
import 'source_editor_screen_state.dart';

class SourceEditorScreen extends StatefulWidget {
  final DynamicSourceDrift? initialSource;

  const SourceEditorScreen({super.key, this.initialSource});

  static Widget create({required ServiceLocator locator, DynamicSourceDrift? initialSource}) {
    return BlocProvider(
      create: (context) => SourceEditorScreenCubit(
        importDynamicSourceUseCase: locator(),
        sourceRuntime: locator(),
        dio: locator(),
        initialSource: initialSource,
      ),
      child: SourceEditorScreen(initialSource: initialSource),
    );
  }

  @override
  State<SourceEditorScreen> createState() => _SourceEditorScreenState();
}

class _SourceEditorScreenState extends State<SourceEditorScreen> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialSource?.sourceCode ?? '',
      language: dart,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  SourceEditorScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: Text(widget.initialSource == null ? 'New Source' : 'Edit Source'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _showTestDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _cubit(context)?.updateSourceCode(_codeController.text);
              _cubit(context)?.save();
            },
          ),
        ],
      ),
      body: BlocBuilder<SourceEditorScreenCubit, SourceEditorScreenState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Source Name'),
                  onChanged: (v) => _cubit(context)?.updateName(v),
                  controller: TextEditingController(text: state.name)..selection = TextSelection.collapsed(offset: state.name.length),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Base URL'),
                  onChanged: (v) => _cubit(context)?.updateBaseUrl(v),
                  controller: TextEditingController(text: state.baseUrl)..selection = TextSelection.collapsed(offset: state.baseUrl.length),
                ),
              ),
              Expanded(
                child: CodeField(
                  controller: _codeController,
                  textStyle: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              if (state.testResult != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  width: double.infinity,
                  child: Text('Test Result: ${state.testResult}'),
                ),
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  width: double.infinity,
                  child: Text('Error: ${state.error}'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showTestDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Test with URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter sample manga URL'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cubit(context)?.updateSourceCode(_codeController.text);
              _cubit(context)?.runTest(controller.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Run Test'),
          ),
        ],
      ),
    );
  }
}
