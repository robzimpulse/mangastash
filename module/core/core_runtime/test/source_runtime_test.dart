import 'package:core_runtime/src/source_runtime.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SourceRuntime sourceRuntime;

  setUp(() {
    sourceRuntime = SourceRuntime();
  });

  test('should compile and execute a simple script', () async {
    const sourceCode = '''
    import 'package:html/parser.dart';
    import 'package:entity_manga_external/src/manga_scrapped.dart';
    
    MangaScrapped parseManga(String html) {
      final doc = parse(html);
      final title = doc.querySelector('h1')?.text;
      return MangaScrapped(title: title);
    }
    ''';

    final bytecode = sourceRuntime.getOrCreateBytecode('test', sourceCode);
    final result = await sourceRuntime.execute(
      bytecode: bytecode,
      functionName: 'parseManga',
      args: ['<html lang=""><body><h1>Hello Manga</h1></body></html>'],
    );

    expect(result, isA<MangaScrapped>());
    expect((result as MangaScrapped).title, 'Hello Manga');
  });

  test('should fetch timeout from script', () async {
    const sourceCode = '''
      int getMangaTimeout() {
        return 5000;
      }
    ''';

    final bytecode = sourceRuntime.getOrCreateBytecode(
      'timeout_test',
      sourceCode,
    );
    final result = sourceRuntime.executeSync(
      bytecode: bytecode,
      functionName: 'getMangaTimeout',
    );

    expect(result, 5000);
  });

  test('should fetch scripts from script', () async {
    const sourceCode = '''
    List<String> getMangaScripts() {
      return ['script1.js', 'script2.js'];
    }
    ''';

    final bytecode = sourceRuntime.getOrCreateBytecode(
      'scripts_test',
      sourceCode,
    );
    final result = sourceRuntime.executeSync(
      bytecode: bytecode,
      functionName: 'getMangaScripts',
    );

    expect(result, ['script1.js', 'script2.js']);
  });
}
