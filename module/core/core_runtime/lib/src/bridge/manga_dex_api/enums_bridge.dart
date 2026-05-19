import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class $MangaStatus extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'MangaStatus'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: ['ongoing', 'completed', 'hiatus', 'cancelled'],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $MangaStatus.wrap(this.value) : _superclass = $Object(value);

  final MangaStatus value;
  final $Instance _superclass;

  @override
  MangaStatus get $value => value;

  @override
  MangaStatus get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $ContentRating extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'ContentRating'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: ['safe', 'suggestive', 'erotica', 'pornographic'],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $ContentRating.wrap(this.value) : _superclass = $Object(value);

  final ContentRating value;
  final $Instance _superclass;

  @override
  ContentRating get $value => value;

  @override
  ContentRating get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $LanguageCodes extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'LanguageCodes'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: [
      'english',
      'simplifiedChinese',
      'traditionalChinese',
      'brazillianPortugese',
      'castilianSpanish',
      'latinAmericaSpanish',
      'romanizedJapanese',
      'romanizedKorean',
      'romanizedChinese',
    ],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $LanguageCodes.wrap(this.value) : _superclass = $Object(value);

  final LanguageCodes value;
  final $Instance _superclass;

  @override
  LanguageCodes get $value => value;

  @override
  LanguageCodes get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $PublicDemographic extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec(
      'package:manga_dex_api/manga_dex_api.dart',
      'PublicDemographic',
    ),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: ['shounen', 'shoujo', 'josei', 'seinen'],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $PublicDemographic.wrap(this.value) : _superclass = $Object(value);

  final PublicDemographic value;
  final $Instance _superclass;

  @override
  PublicDemographic get $value => value;

  @override
  PublicDemographic get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $TagsMode extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'TagsMode'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: ['and', 'or'],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $TagsMode.wrap(this.value) : _superclass = $Object(value);

  final TagsMode value;
  final $Instance _superclass;

  @override
  TagsMode get $value => value;

  @override
  TagsMode get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $SearchOrders extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'SearchOrders'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: [
      'title',
      'year',
      'createdAt',
      'updatedAt',
      'latestUploadedChapter',
      'followedCount',
      'relevance',
      'rating',
    ],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $SearchOrders.wrap(this.value) : _superclass = $Object(value);

  final SearchOrders value;
  final $Instance _superclass;

  @override
  SearchOrders get $value => value;

  @override
  SearchOrders get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $OrderDirections extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec(
      'package:manga_dex_api/manga_dex_api.dart',
      'OrderDirections',
    ),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: ['ascending', 'descending'],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $OrderDirections.wrap(this.value) : _superclass = $Object(value);

  final OrderDirections value;
  final $Instance _superclass;

  @override
  OrderDirections get $value => value;

  @override
  OrderDirections get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}

class $Include extends $Value implements $Instance {
  static const $type = BridgeTypeRef(
    BridgeTypeSpec('package:manga_dex_api/manga_dex_api.dart', 'Include'),
  );

  static const $declaration = BridgeEnumDef(
    $type,
    values: [
      'coverArt',
      'author',
      'artist',
      'tag',
      'creator',
      'scanlationGroup',
      'manga',
      'user',
    ],
    fields: {
      'rawValue': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string)),
      ),
    },
  );

  $Include.wrap(this.value) : _superclass = $Object(value);

  final Include value;
  final $Instance _superclass;

  @override
  Include get $value => value;

  @override
  Include get $reified => value;

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'rawValue':
        return runtime.wrap(value.rawValue);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    _superclass.$setProperty(runtime, identifier, value);
  }

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($type.spec!);
}
