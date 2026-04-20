// ignore_for_file: unused_import, unnecessary_import
// ignore_for_file: always_specify_types, avoid_redundant_argument_values
// ignore_for_file: sort_constructors_first
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/async.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'chapter_scrapped.eval.dart';
import 'html_document.dart';
import 'manga_scrapped.dart';
import 'manga_scrapped.eval.dart';
import 'source_external.dart';
import 'source_external.eval.dart';
import 'tag_scrapped.dart';

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

      'builtIn': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
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
                'GetMangaSourceExternalUseCase',
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
                'GetChapterImageSourceExternalUseCase',
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
                'SearchMangaSourceExternalUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'listChapterUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'ListChapterSourceExternalUseCase',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [],
        ),
      ),

      'listTagUseCase': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:entity_manga_external/src/source_external.dart',
                'ListTagSourceExternalUseCase',
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

      case 'builtIn':
        final _builtIn = $value.builtIn;
        return $bool(_builtIn);

      case 'getMangaUseCase':
        final _getMangaUseCase = $value.getMangaUseCase;
        return $GetMangaSourceExternalUseCase.wrap(_getMangaUseCase);

      case 'getChapterImageUseCase':
        final _getChapterImageUseCase = $value.getChapterImageUseCase;
        return $GetChapterImageSourceExternalUseCase.wrap(
          _getChapterImageUseCase,
        );

      case 'searchMangaUseCase':
        final _searchMangaUseCase = $value.searchMangaUseCase;
        return $SearchMangaSourceExternalUseCase.wrap(_searchMangaUseCase);

      case 'listChapterUseCase':
        final _listChapterUseCase = $value.listChapterUseCase;
        return $ListChapterSourceExternalUseCase.wrap(_listChapterUseCase);

      case 'listTagUseCase':
        final _listTagUseCase = $value.listTagUseCase;
        return $ListTagSourceExternalUseCase.wrap(_listTagUseCase);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [GetMangaSourceExternalUseCase]
class $GetMangaSourceExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$GetMangaSourceExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'GetMangaSourceExternalUseCase',
  );

  /// Compile-time type declaration of [$GetMangaSourceExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$GetMangaSourceExternalUseCase]
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
  final GetMangaSourceExternalUseCase $value;

  @override
  GetMangaSourceExternalUseCase get $reified => $value;

  /// Wrap a [GetMangaSourceExternalUseCase] in a [$GetMangaSourceExternalUseCase]
  $GetMangaSourceExternalUseCase.wrap(this.$value)
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
    final self = target! as $GetMangaSourceExternalUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(result.then((e) => $MangaScrapped.wrap(e)));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [GetChapterImageSourceExternalUseCase]
class $GetChapterImageSourceExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$GetChapterImageSourceExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'GetChapterImageSourceExternalUseCase',
  );

  /// Compile-time type declaration of [$GetChapterImageSourceExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$GetChapterImageSourceExternalUseCase]
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
  final GetChapterImageSourceExternalUseCase $value;

  @override
  GetChapterImageSourceExternalUseCase get $reified => $value;

  /// Wrap a [GetChapterImageSourceExternalUseCase] in a [$GetChapterImageSourceExternalUseCase]
  $GetChapterImageSourceExternalUseCase.wrap(this.$value)
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
    final self = target! as $GetChapterImageSourceExternalUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(result.then((e) => $List.view(e, (e) => $String(e))));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [SearchMangaSourceExternalUseCase]
class $SearchMangaSourceExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$SearchMangaSourceExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'SearchMangaSourceExternalUseCase',
  );

  /// Compile-time type declaration of [$SearchMangaSourceExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$SearchMangaSourceExternalUseCase]
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
  final SearchMangaSourceExternalUseCase $value;

  @override
  SearchMangaSourceExternalUseCase get $reified => $value;

  /// Wrap a [SearchMangaSourceExternalUseCase] in a [$SearchMangaSourceExternalUseCase]
  $SearchMangaSourceExternalUseCase.wrap(this.$value)
    : _superclass = $Object($value);

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
    final self = target! as $SearchMangaSourceExternalUseCase;
    final result = self.$value.url(parameter: args[0]!.$value);
    return $String(result);
  }

  static const $Function __parse = $Function(_parse);
  static $Value? _parse(Runtime runtime, $Value? target, List<$Value?> args) {
    final self = target! as $SearchMangaSourceExternalUseCase;
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
    final self = target! as $SearchMangaSourceExternalUseCase;
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

/// dart_eval wrapper binding for [ListChapterSourceExternalUseCase]
class $ListChapterSourceExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$ListChapterSourceExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'ListChapterSourceExternalUseCase',
  );

  /// Compile-time type declaration of [$ListChapterSourceExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ListChapterSourceExternalUseCase]
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
  final ListChapterSourceExternalUseCase $value;

  @override
  ListChapterSourceExternalUseCase get $reified => $value;

  /// Wrap a [ListChapterSourceExternalUseCase] in a [$ListChapterSourceExternalUseCase]
  $ListChapterSourceExternalUseCase.wrap(this.$value)
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
    final self = target! as $ListChapterSourceExternalUseCase;
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

/// dart_eval wrapper binding for [ListTagSourceExternalUseCase]
class $ListTagSourceExternalUseCase implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {}

  /// Compile-time type specification of [$ListTagSourceExternalUseCase]
  static const $spec = BridgeTypeSpec(
    'package:entity_manga_external/src/source_external.dart',
    'ListTagSourceExternalUseCase',
  );

  /// Compile-time type declaration of [$ListTagSourceExternalUseCase]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$ListTagSourceExternalUseCase]
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
                        'package:entity_manga_external/src/tag_scrapped.dart',
                        'TagScrapped',
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
  final ListTagSourceExternalUseCase $value;

  @override
  ListTagSourceExternalUseCase get $reified => $value;

  /// Wrap a [ListTagSourceExternalUseCase] in a [$ListTagSourceExternalUseCase]
  $ListTagSourceExternalUseCase.wrap(this.$value)
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
    final self = target! as $ListTagSourceExternalUseCase;
    final result = self.$value.parse(root: args[0]!.$value);
    return $Future.wrap(
      result.then((e) => $List.view(e, (e) => runtime.wrapAlways(e))),
    );
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
