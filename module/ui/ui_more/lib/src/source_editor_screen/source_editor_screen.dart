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

  static Widget create({
    required ServiceLocator locator,
    DynamicSourceDrift? initialSource,
  }) {
    return BlocProvider(
      create:
          (context) => SourceEditorScreenCubit(
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
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialSource?.sourceCode ?? _defaultSourceCode,
      language: dart,
    );
    _nameController =
        TextEditingController(text: widget.initialSource?.name ?? '');
    _baseUrlController =
        TextEditingController(text: widget.initialSource?.baseUrl ?? '');
  }

  static const String _defaultSourceCode = '''
  import 'package:html/parser.dart';
  import 'package:entity_manga_external/src/manga_scrapped.dart';
  import 'package:entity_manga_external/src/chapter_scrapped.dart';
  import 'package:entity_manga_external/src/tag_scrapped.dart';
  import 'package:manga_dex_api/manga_dex_api.dart';
  
  /**
   * PARSE MANGA DETAILS
   */
  MangaScrapped getManga(String html) {
    final doc = parse(html);
    final title = doc.querySelector('h1.entry-title')?.text;
    final cover = doc.querySelector('img.wp-post-image')?.attributes['src'];
    final description = doc.querySelector('.entry-content p')?.text;
    
    return MangaScrapped(
      title: title?.trim(),
      coverUrl: cover,
      description: description?.trim(),
    );
  }
  
  int getMangaTimeout() => 10000;
  List<String> getMangaScripts() => [];
  
  /**
   * LIST CHAPTERS
   */
  List<ChapterScrapped> listChapters(String html) {
    final doc = parse(html);
    final rows = doc.querySelectorAll('.chapter-list li');
    
    return rows.map((row) {
      final link = row.querySelector('a');
      return ChapterScrapped(
        title: link?.text.trim(),
        webUrl: link?.attributes['href'],
      );
    }).toList();
  }
  
  int listChapterTimeout() => 10000;
  List<String> listChapterScripts() => [];
  
  /**
   * SEARCH MANGA
   */
  String searchUrl(SearchMangaParameter parameter) {
    return 'https://example.com/search?q=\${parameter.title}&page=\${parameter.page}';
  }

  List<MangaScrapped> searchManga(String html) {
    final doc = parse(html);
    final items = doc.querySelectorAll('.search-item');
    
    return items.map((item) {
      return MangaScrapped(
        title: item.querySelector('.title')?.text.trim(),
        webUrl: item.querySelector('a')?.attributes['href'],
        coverUrl: item.querySelector('img')?.attributes['src'],
      );
    }).toList();
  }
  
  bool searchHaveNextPage(String html) {
    final doc = parse(html);
    return doc.querySelector('.next-page') != null;
  }
  
  int searchMangaTimeout() => 10000;
  List<String> searchMangaScripts() => [];
  
  /**
   * GET CHAPTER IMAGES
   */
  List<String> getChapterImages(String html) {
    final doc = parse(html);
    final images = doc.querySelectorAll('#readerarea img');
    
    return images.map((img) {
      return img.attributes['src'] ?? '';
    }).where((src) => src.isNotEmpty).toList();
  }
  
  int getChapterImageTimeout() => 20000;
  List<String> getChapterImageScripts() => [];
  
  /**
   * LIST TAGS
   */
  List<TagScrapped> listTags(String html) {
    final doc = parse(html);
    final tags = doc.querySelectorAll('.genre-list a');
    
    return tags.map((tag) {
      return TagScrapped(
        name: tag.text.trim(),
      );
    }).toList();
  }
  
  int listTagTimeout() => 5000;
  List<String> listTagScripts() => [];
  ''';

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  SourceEditorScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: Text(
          widget.initialSource == null ? 'New Source' : 'Edit Source',
        ),
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Source Name'),
                    onChanged: (v) => _cubit(context)?.updateName(v),
                    controller: _nameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Base URL'),
                    onChanged: (v) => _cubit(context)?.updateBaseUrl(v),
                    controller: _baseUrlController,
                  ),
                ),
                CodeField(
                  controller: _codeController,
                  textStyle: const TextStyle(fontFamily: 'monospace'),
                ),
                if (state.testResult != null)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    width: double.infinity,
                    child: Text('Test Result: ${state.testResult}'),
                  ),
                if (state.error != null)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[100],
                    width: double.infinity,
                    child: Text('Error: ${state.error}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTestDialog(BuildContext context) {
    final controller = TextEditingController();
    SourceTestType selectedType = SourceTestType.getManga;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Test Source'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SourceTestType>(
                    value: selectedType,
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
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
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: selectedType == SourceTestType.searchUrl
                          ? 'Enter search query'
                          : 'Enter sample URL',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _cubit(context)?.updateSourceCode(_codeController.text);
                    _cubit(context)?.runTest(controller.text, type: selectedType);
                    // Navigator.pop(dialogContext);
                  },
                  child: const Text('Run Test'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
