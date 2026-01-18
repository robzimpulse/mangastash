// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'source_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'chapter_scrapped.dart';
import 'html_document.dart';
import 'manga_scrapped.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:entity_manga_external/src/source_external.eval.dart';
import 'package:dart_eval/stdlib/async.dart';
import 'package:entity_manga_external/src/manga_scrapped.eval.dart';
import 'package:entity_manga_external/src/chapter_scrapped.eval.dart';

/// dart_eval wrapper binding for [SourceExternal]
class $SourceExternal implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$SourceExternal]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'SourceExternal',
  );

  /// Compile-time type declaration of [$SourceExternal]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SourceExternal]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {},
    getters: {
      'name': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'iconUrl': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'baseUrl': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),

      'getMangaUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'GetMangaUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'getChapterImageUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'GetChapterImageUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'searchMangaUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'SearchMangaExternalUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'searchChapterUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'SearchChapterExternalUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final SourceExternal $value;

  @override
  SourceExternal get $reified => $value;

  /// Wrap a [SourceExternal] in a [$SourceExternal]
  $SourceExternal.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'iconUrl':
        final _iconUrl = $value.iconUrl;
        return $String(_iconUrl);

      case 'baseUrl':
        final _baseUrl = $value.baseUrl;
        return $String(_baseUrl);

      case 'getMangaUseCase':
        final _getMangaUseCase = $value.getMangaUseCase;
        return $GetMangaUseCase.wrap(_getMangaUseCase);

      case 'getChapterImageUseCase':
        final _getChapterImageUseCase = $value.getChapterImageUseCase;
        return $GetChapterImageUseCase.wrap(_getChapterImageUseCase);

      case 'searchMangaUseCase':
        final _searchMangaUseCase = $value.searchMangaUseCase;
        return $SearchMangaExternalUseCase.wrap(_searchMangaUseCase);

      case 'searchChapterUseCase':
        final _searchChapterUseCase = $value.searchChapterUseCase;
        return $SearchChapterExternalUseCase.wrap(_searchChapterUseCase);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [GetMangaUseCase]
class $GetMangaUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$GetMangaUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'GetMangaUseCase',
  );

  /// Compile-time type declaration of [$GetMangaUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$GetMangaUseCase]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'parse': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/manga_scrapped.dart',
                    'MangaScrapped',
                  ),
                  [],
                ),
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'root',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/html_document.dart',
                    'HtmlDocument',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {
      'scripts': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final GetMangaUseCase $value;

  @override
  GetMangaUseCase get $reified => $value;

  /// Wrap a [GetMangaUseCase] in a [$GetMangaUseCase]
  $GetMangaUseCase.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'scripts':
        final _scripts = $value.scripts;
        return $List.view(_scripts, (e) => $String(e));
      case 'parse':
        return __parse;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __parse = $Function(_parse);
  static $Value? _parse(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $GetMangaUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(result.then((e) => $MangaScrapped.wrap(e)));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [GetChapterImageUseCase]
class $GetChapterImageUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$GetChapterImageUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'GetChapterImageUseCase',
  );

  /// Compile-time type declaration of [$GetChapterImageUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$GetChapterImageUseCase]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'parse': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                ]),
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'root',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/html_document.dart',
                    'HtmlDocument',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {
      'scripts': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final GetChapterImageUseCase $value;

  @override
  GetChapterImageUseCase get $reified => $value;

  /// Wrap a [GetChapterImageUseCase] in a [$GetChapterImageUseCase]
  $GetChapterImageUseCase.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'scripts':
        final _scripts = $value.scripts;
        return $List.view(_scripts, (e) => $String(e));
      case 'parse':
        return __parse;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __parse = $Function(_parse);
  static $Value? _parse(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $GetChapterImageUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(result.then((e) => $List.view(e, (e) => $String(e))));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [SearchMangaExternalUseCase]
class $SearchMangaExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$SearchMangaExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'SearchMangaExternalUseCase',
  );

  /// Compile-time type declaration of [$SearchMangaExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SearchMangaExternalUseCase]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'url': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [
            BridgeParameter(
              'parameter',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:manga_dex_api/src/model/manga/search_manga_parameter.dart',
                    'SearchMangaParameter',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),

      'parse': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:entity_manga_external/src/manga_scrapped.dart',
                        'MangaScrapped',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'root',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/html_document.dart',
                    'HtmlDocument',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),

      'haveNextPage': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.bool, []),
                nullable: true,
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'root',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/html_document.dart',
                    'HtmlDocument',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {
      'scripts': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final SearchMangaExternalUseCase $value;

  @override
  SearchMangaExternalUseCase get $reified => $value;

  /// Wrap a [SearchMangaExternalUseCase] in a [$SearchMangaExternalUseCase]
  $SearchMangaExternalUseCase.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'scripts':
        final _scripts = $value.scripts;
        return $List.view(_scripts, (e) => $String(e));
      case 'url':
        return __url;

      case 'parse':
        return __parse;

      case 'haveNextPage':
        return __haveNextPage;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __url = $Function(_url);
  static $Value? _url(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $SearchMangaExternalUseCase;
    final result = self.$value.url(parameter: args[0]!.$value);
    return $String(result);
  }

  static const $Function __parse = $Function(_parse);
  static $Value? _parse(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $SearchMangaExternalUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(
      result.then((e) => $List.view(e, (e) => $MangaScrapped.wrap(e))),
    );
  }

  static const $Function __haveNextPage = $Function(_haveNextPage);
  static $Value? _haveNextPage(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $SearchMangaExternalUseCase;
    final result = self.$value.haveNextPage(root: args[0]!.$value);
    return $Future.wrap(
      result.then((e) => e == null ? const $null() : $bool(e)),
    );
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [SearchChapterExternalUseCase]
class $SearchChapterExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$SearchChapterExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'SearchChapterExternalUseCase',
  );

  /// Compile-time type declaration of [$SearchChapterExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SearchChapterExternalUseCase]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type, isAbstract: true),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [],
          params: [],
        ),
        isFactory: false,
      ),
    },

    methods: {
      'parse': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.list, [
                  BridgeTypeAnnotation(
                    BridgeTypeRef(
                      BridgeTypeSpec(
                        'package:entity_manga_external/src/chapter_scrapped.dart',
                        'ChapterScrapped',
                      ),
                      [],
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          namedParams: [
            BridgeParameter(
              'root',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:entity_manga_external/src/html_document.dart',
                    'HtmlDocument',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
          params: [],
        ),
      ),
    },
    getters: {
      'scripts': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.list, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            ]),
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {},
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final SearchChapterExternalUseCase $value;

  @override
  SearchChapterExternalUseCase get $reified => $value;

  /// Wrap a [SearchChapterExternalUseCase] in a [$SearchChapterExternalUseCase]
  $SearchChapterExternalUseCase.wrap(this.$value)
    : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'scripts':
        final _scripts = $value.scripts;
        return $List.view(_scripts, (e) => $String(e));
      case 'parse':
        return __parse;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __parse = $Function(_parse);
  static $Value? _parse(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $SearchChapterExternalUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(
      result.then((e) => $List.view(e, (e) => $ChapterScrapped.wrap(e))),
    );
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
