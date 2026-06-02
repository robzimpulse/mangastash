# Custom Scraper Script Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable users to side-load custom manga scrapers via remote Dart scripts executed securely using `dart_eval` with bound `package:html` and `package:collection` utilities.

**Architecture:** We will store scripts in Drift SQLite, parse HTML natively, and pass `Document` objects into a `dart_eval` environment where the script implements parsing functions. The custom sources will be dynamically added to the global `Sources.values` list.

**Tech Stack:** `dart_eval`, Drift, HTML parsing, Flutter.

---

### Task 1: Add Dependencies

**Files:**
- Modify: `module/domain/domain_manga/pubspec.yaml`

- [ ] **Step 1: Add dart_eval**

Modify `module/domain/domain_manga/pubspec.yaml` to include `dart_eval` under `dependencies`:
```yaml
dependencies:
  dart_eval: ^0.7.6
  http: ^1.2.1
```

- [ ] **Step 2: Run melos refresh**
Run: `melos run refresh`
Expected: PASS with dependencies synchronized.

- [ ] **Step 3: Commit**
```bash
git add module/domain/domain_manga/pubspec.yaml
git commit -m "build: add dart_eval dependency to domain_manga"
```

---

### Task 2: Database Schema

**Files:**
- Create: `module/library/manga_service_drift/lib/src/tables/custom_source_tables.dart`
- Create: `module/library/manga_service_drift/lib/src/dao/custom_source_dao.dart`
- Modify: `module/library/manga_service_drift/lib/src/database/database.dart`

- [ ] **Step 1: Define the table**
Create `module/library/manga_service_drift/lib/src/tables/custom_source_tables.dart`:
```dart
import 'package:drift/drift.dart';
import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('CustomSourceDrift')
class CustomSourceTables extends Table with AutoTimestampTable, AutoIntIdTable {
  TextColumn get name => text().named('name')();
  TextColumn get baseUrl => text().named('base_url')();
  TextColumn get iconUrl => text().named('icon_url').nullable()();
  TextColumn get scriptUrl => text().named('script_url').unique()();
  TextColumn get scriptCode => text().named('script_code')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
```

- [ ] **Step 2: Define the DAO**
Create `module/library/manga_service_drift/lib/src/dao/custom_source_dao.dart`:
```dart
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../tables/custom_source_tables.dart';

part 'custom_source_dao.g.dart';

@DriftAccessor(tables: [CustomSourceTables])
class CustomSourceDao extends DatabaseAccessor<AppDatabase> with _$CustomSourceDaoMixin {
  CustomSourceDao(super.attachedDatabase);

  Future<List<CustomSourceDrift>> getAllSources() => select(customSourceTables).get();

  Future<int> insertSource(CustomSourceTablesCompanion source) =>
      into(customSourceTables).insert(source, mode: InsertMode.insertOrReplace);

  Future<int> deleteSource(int id) =>
      (delete(customSourceTables)..where((t) => t.id.equals(id))).go();
}
```

- [ ] **Step 3: Register in AppDatabase**
Modify `module/library/manga_service_drift/lib/src/database/database.dart`:
Add `CustomSourceTables` to `@DriftDatabase(tables: [..., CustomSourceTables], daos: [..., CustomSourceDao])`.

- [ ] **Step 4: Generate drift code**
Run: `melos run generate` in the root.
Expected: PASS, `.g.dart` files generated successfully.

- [ ] **Step 5: Commit**
```bash
git add module/library/manga_service_drift
git commit -m "feat: add custom source drift schema and dao"
```

---

### Task 3: Script Execution Engine & Bindings

**Files:**
- Create: `module/domain/domain_manga/lib/src/sources/custom_script_executor.dart`

- [ ] **Step 1: Write executor and basic bindings**
Create `module/domain/domain_manga/lib/src/sources/custom_script_executor.dart`:
```dart
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

class CustomScriptExecutor {
  final Runtime runtime;

  CustomScriptExecutor(String scriptCode) : runtime = _buildRuntime(scriptCode);

  static Runtime _buildRuntime(String scriptCode) {
    final compiler = Compiler();
    compiler.defineBridgeClasses([$Document.$declaration, $Element.$declaration]);
    compiler.defineBridgeTopLevelFunction(BridgeFunctionDeclaration(
      'package:html/parser.dart',
      'parse',
      BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [
        BridgeParameter('html', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)
      ])
    ));

    final program = compiler.compile({
      'scraper': {'main.dart': scriptCode}
    });

    final runtime = Runtime.ofProgram(program);
    runtime.registerBridgeFunc('package:html/parser.dart', 'parse', (rt, target, args) {
      final doc = html_parser.parse(args[0]?.\$value as String);
      return $Document.wrap(doc);
    });
    runtime.setup();
    return runtime;
  }

  dynamic invoke(String functionName, List<dynamic> positionalArgs) {
    return runtime.executeLib('package:scraper/main.dart', functionName, positionalArgs);
  }
}

class $Document implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Document'));
  static const $declaration = BridgeClassDef(BridgeClassType($type),
      constructors: {},
      methods: {
        'querySelector': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
        'querySelectorAll': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
      },
      getters: {}, setters: {}, fields: {}, wrap: true);

  final Document \$value;
  $Document.wrap(this.\$value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'querySelector':
        return __evalFunction((rt, target, args) {
          final el = \$value.querySelector(args[0]?.\$value as String);
          return el != null ? $Element.wrap(el) : const $null();
        });
      case 'querySelectorAll':
        return __evalFunction((rt, target, args) {
          final els = \$value.querySelectorAll(args[0]?.\$value as String);
          return $List.wrap(els.map((e) => $Element.wrap(e)).toList());
        });
    }
    return null;
  }
  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {}
  @override
  int get $runtimeType => runtimeType.hashCode;
}

class $Element implements $Instance {
  static const $type = BridgeTypeRef(BridgeTypeSpec('package:html/dom.dart', 'Element'));
  static const $declaration = BridgeClassDef(BridgeClassType($type),
      constructors: {},
      methods: {
        'querySelector': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)), params: [BridgeParameter('selector', BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)), false)])),
      },
      getters: {
        'text': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)))),
        'attributes': BridgeMethodDef(BridgeFunctionDef(returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)))),
      }, setters: {}, fields: {}, wrap: true);

  final Element \$value;
  $Element.wrap(this.\$value);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'text':
        return $String(\$value.text);
      case 'attributes':
        return $Map.wrap(\$value.attributes.map((k, v) => MapEntry($String(k.toString()), $String(v))));
      case 'querySelector':
        return __evalFunction((rt, target, args) {
          final el = \$value.querySelector(args[0]?.\$value as String);
          return el != null ? $Element.wrap(el) : const $null();
        });
    }
    return null;
  }
  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {}
  @override
  int get $runtimeType => runtimeType.hashCode;
}

$Value __evalFunction(Function(Runtime rt, $Value? target, List<$Value?> args) func) {
  return $Function((rt, target, args) => func(rt, target, args));
}
```

- [ ] **Step 2: Commit**
```bash
git add module/domain/domain_manga/lib/src/sources/custom_script_executor.dart
git commit -m "feat: add script executor and html bindings"
```

---

### Task 4: Custom Source Wrapper Implementation

**Files:**
- Create: `module/domain/domain_manga/lib/src/sources/custom_source_external.dart`

- [ ] **Step 1: Write CustomSourceExternal class**
Create the file:
```dart
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'custom_script_executor.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class CustomSourceExternal extends SourceExternal {
  final CustomScriptExecutor _executor;
  final String _name;
  final String _baseUrl;
  final String _iconUrl;

  CustomSourceExternal({
    required CustomScriptExecutor executor,
    required String name,
    required String baseUrl,
    required String iconUrl,
  })  : _executor = executor,
        _name = name,
        _baseUrl = baseUrl,
        _iconUrl = iconUrl;

  static CustomSourceExternal fromScript(String scriptCode) {
    final executor = CustomScriptExecutor(scriptCode);
    final metaValue = executor.invoke('getMetadata', []) as Map;
    final meta = metaValue.map((k, v) => MapEntry(k.toString(), v.toString()));
    return CustomSourceExternal(
      executor: executor,
      name: meta['name'] ?? 'Unknown',
      baseUrl: meta['baseUrl'] ?? '',
      iconUrl: meta['iconUrl'] ?? '',
    );
  }

  @override
  String get name => _name;

  @override
  String get baseUrl => _baseUrl;

  @override
  String get iconUrl => _iconUrl;

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase => _GetManga(_executor);

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase => _GetChapterImage(_executor);

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase => _SearchManga(_executor);

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase => _ListChapter(_executor);

  @override
  ListTagSourceExternalUseCase get listTagUseCase => _ListTag(_executor);
}

class _GetManga implements GetMangaSourceExternalUseCase {
  final CustomScriptExecutor _executor;
  _GetManga(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);
  @override
  List<String> get scripts => [];

  @override
  Future<MangaScrapped> parse({required Document root}) async {
    final res = _executor.invoke('parseManga', [$Document.wrap(root)]) as Map;
    return MangaScrapped(
      title: res['title']?.toString(),
      author: res['author']?.toString(),
      coverUrl: res['coverUrl']?.toString(),
      description: res['description']?.toString(),
      tags: (res['tags'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class _GetChapterImage implements GetChapterImageSourceExternalUseCase {
  final CustomScriptExecutor _executor;
  _GetChapterImage(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);
  @override
  List<String> get scripts => [];

  @override
  Future<List<String>> parse({required Document root}) async {
    final res = _executor.invoke('parseChapterImages', [$Document.wrap(root)]) as List;
    return res.map((e) => e.toString()).toList();
  }
}

class _SearchManga implements SearchMangaSourceExternalUseCase {
  final CustomScriptExecutor _executor;
  _SearchManga(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);
  @override
  List<String> get scripts => [];

  @override
  Future<bool?> haveNextPage({required Document root}) async {
    return _executor.invoke('haveNextPage', [$Document.wrap(root)]) as bool?;
  }

  @override
  Future<List<MangaScrapped>> parse({required Document root}) async {
    final res = _executor.invoke('parseSearchManga', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return MangaScrapped(
        title: map['title']?.toString(),
        coverUrl: map['coverUrl']?.toString(),
        webUrl: map['webUrl']?.toString(),
        status: map['status']?.toString(),
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList(),
      );
    }).toList();
  }

  @override
  String url({required SearchMangaParameter parameter}) {
    return _executor.invoke('searchMangaUrl', [
      parameter.page,
      parameter.title ?? '',
      parameter.status?.map((e) => e.name).toList() ?? [],
      parameter.includedTags ?? [],
      parameter.includedTagsMode.name,
    ]) as String;
  }
}

class _ListChapter implements ListChapterSourceExternalUseCase {
  final CustomScriptExecutor _executor;
  _ListChapter(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);
  @override
  List<String> get scripts => [];

  @override
  Future<List<ChapterScrapped>> parse({required Document root}) async {
    final res = _executor.invoke('parseChapters', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return ChapterScrapped(
        title: map['title']?.toString(),
        chapter: map['chapter']?.toString(),
        readableAt: map['readableAt']?.toString(),
        webUrl: map['webUrl']?.toString(),
      );
    }).toList();
  }
}

class _ListTag implements ListTagSourceExternalUseCase {
  final CustomScriptExecutor _executor;
  _ListTag(this._executor);

  @override
  Duration? get timeout => const Duration(seconds: 15);
  @override
  List<String> get scripts => [];

  @override
  Future<List<TagScrapped>> parse({required Document root}) async {
    final res = _executor.invoke('parseTags', [$Document.wrap(root)]) as List;
    return res.map((item) {
      final map = item as Map;
      return TagScrapped(
        id: map['id']?.toString(),
        name: map['name']?.toString(),
      );
    }).toList();
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add module/domain/domain_manga/lib/src/sources/custom_source_external.dart
git commit -m "feat: add CustomSourceExternal implementation"
```

---

### Task 5: Source Aggregation & UI

**Files:**
- Modify: `module/domain/domain_manga/lib/src/sources/sources.dart`
- Modify: `module/ui/ui_browse/lib/src/browse_source_screen/browse_source_screen.dart`

- [ ] **Step 1: Aggregate Custom Sources**
Modify `Sources.dart` to expose a method to load custom sources dynamically, or update `GlobalOptionsManager` to fetch from the DAO and append to `_sources`.

- [ ] **Step 2: Add "Add Source" Dialog**
Modify `BrowseSourceScreen` to include a Floating Action Button that opens a simple URL input dialog. On submit, download the script via `http.get`, create a `CustomSourceExternal.fromScript(code)`, and insert it into `CustomSourceDao`.

- [ ] **Step 3: Commit**
```bash
git commit -am "feat: UI for side-loading custom scripts"
```
