// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class ImageTables extends Table with TableInfo<ImageTables, ImageTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ImageTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
    'web_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    order,
    chapterId,
    webUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chapterId, webUrl, order},
    {chapterId, webUrl},
    {webUrl, order},
    {chapterId, order},
  ];
  @override
  ImageTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      order:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}order'],
          )!,
      chapterId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chapter_id'],
          )!,
      webUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}web_url'],
          )!,
    );
  }

  @override
  ImageTables createAlias(String alias) {
    return ImageTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'UNIQUE(chapter_id, web_url, "order")',
    'UNIQUE(chapter_id, web_url)',
    'UNIQUE(web_url, "order")',
    'UNIQUE(chapter_id, "order")',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ImageTablesData extends DataClass implements Insertable<ImageTablesData> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final int order;
  final String chapterId;
  final String webUrl;
  const ImageTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.order,
    required this.chapterId,
    required this.webUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['order'] = Variable<int>(order);
    map['chapter_id'] = Variable<String>(chapterId);
    map['web_url'] = Variable<String>(webUrl);
    return map;
  }

  ImageTablesCompanion toCompanion(bool nullToAbsent) {
    return ImageTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      order: Value(order),
      chapterId: Value(chapterId),
      webUrl: Value(webUrl),
    );
  }

  factory ImageTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      order: serializer.fromJson<int>(json['order']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      webUrl: serializer.fromJson<String>(json['webUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'order': serializer.toJson<int>(order),
      'chapterId': serializer.toJson<String>(chapterId),
      'webUrl': serializer.toJson<String>(webUrl),
    };
  }

  ImageTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    int? order,
    String? chapterId,
    String? webUrl,
  }) => ImageTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    order: order ?? this.order,
    chapterId: chapterId ?? this.chapterId,
    webUrl: webUrl ?? this.webUrl,
  );
  ImageTablesData copyWithCompanion(ImageTablesCompanion data) {
    return ImageTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      order: data.order.present ? data.order.value : this.order,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('order: $order, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, id, order, chapterId, webUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.order == this.order &&
          other.chapterId == this.chapterId &&
          other.webUrl == this.webUrl);
}

class ImageTablesCompanion extends UpdateCompanion<ImageTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<int> order;
  final Value<String> chapterId;
  final Value<String> webUrl;
  final Value<int> rowid;
  const ImageTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.order = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required int order,
    required String chapterId,
    required String webUrl,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       order = Value(order),
       chapterId = Value(chapterId),
       webUrl = Value(webUrl);
  static Insertable<ImageTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<int>? order,
    Expression<String>? chapterId,
    Expression<String>? webUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (order != null) 'order': order,
      if (chapterId != null) 'chapter_id': chapterId,
      if (webUrl != null) 'web_url': webUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<int>? order,
    Value<String>? chapterId,
    Value<String>? webUrl,
    Value<int>? rowid,
  }) {
    return ImageTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      order: order ?? this.order,
      chapterId: chapterId ?? this.chapterId,
      webUrl: webUrl ?? this.webUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (webUrl.present) {
      map['web_url'] = Variable<String>(webUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('order: $order, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChapterTables extends Table
    with TableInfo<ChapterTables, ChapterTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChapterTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
    'manga_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> chapter = GeneratedColumn<String>(
    'chapter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> translatedLanguage =
      GeneratedColumn<String>(
        'translated_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'NULL',
      );
  late final GeneratedColumn<String> scanlationGroup = GeneratedColumn<String>(
    'scanlation_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
    'webUrl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> readableAt = GeneratedColumn<int>(
    'readable_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> publishAt = GeneratedColumn<int>(
    'publish_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<int> lastReadAt = GeneratedColumn<int>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    mangaId,
    title,
    volume,
    chapter,
    translatedLanguage,
    scanlationGroup,
    webUrl,
    readableAt,
    publishAt,
    lastReadAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {mangaId, webUrl, title},
    {mangaId, title},
    {mangaId, webUrl},
    {webUrl, title},
    {webUrl},
  ];
  @override
  ChapterTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      mangaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume'],
      ),
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter'],
      ),
      translatedLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_language'],
      ),
      scanlationGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scanlation_group'],
      ),
      webUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}webUrl'],
      ),
      readableAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}readable_at'],
      ),
      publishAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publish_at'],
      ),
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_at'],
      ),
    );
  }

  @override
  ChapterTables createAlias(String alias) {
    return ChapterTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'UNIQUE(manga_id, webUrl, title)',
    'UNIQUE(manga_id, title)',
    'UNIQUE(manga_id, webUrl)',
    'UNIQUE(webUrl, title)',
    'UNIQUE(webUrl)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ChapterTablesData extends DataClass
    implements Insertable<ChapterTablesData> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String? mangaId;
  final String? title;
  final String? volume;
  final String? chapter;
  final String? translatedLanguage;
  final String? scanlationGroup;
  final String? webUrl;
  final int? readableAt;
  final int? publishAt;
  final int? lastReadAt;
  const ChapterTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.mangaId,
    this.title,
    this.volume,
    this.chapter,
    this.translatedLanguage,
    this.scanlationGroup,
    this.webUrl,
    this.readableAt,
    this.publishAt,
    this.lastReadAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mangaId != null) {
      map['manga_id'] = Variable<String>(mangaId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<String>(volume);
    }
    if (!nullToAbsent || chapter != null) {
      map['chapter'] = Variable<String>(chapter);
    }
    if (!nullToAbsent || translatedLanguage != null) {
      map['translated_language'] = Variable<String>(translatedLanguage);
    }
    if (!nullToAbsent || scanlationGroup != null) {
      map['scanlation_group'] = Variable<String>(scanlationGroup);
    }
    if (!nullToAbsent || webUrl != null) {
      map['webUrl'] = Variable<String>(webUrl);
    }
    if (!nullToAbsent || readableAt != null) {
      map['readable_at'] = Variable<int>(readableAt);
    }
    if (!nullToAbsent || publishAt != null) {
      map['publish_at'] = Variable<int>(publishAt);
    }
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<int>(lastReadAt);
    }
    return map;
  }

  ChapterTablesCompanion toCompanion(bool nullToAbsent) {
    return ChapterTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      mangaId:
          mangaId == null && nullToAbsent
              ? const Value.absent()
              : Value(mangaId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      volume:
          volume == null && nullToAbsent ? const Value.absent() : Value(volume),
      chapter:
          chapter == null && nullToAbsent
              ? const Value.absent()
              : Value(chapter),
      translatedLanguage:
          translatedLanguage == null && nullToAbsent
              ? const Value.absent()
              : Value(translatedLanguage),
      scanlationGroup:
          scanlationGroup == null && nullToAbsent
              ? const Value.absent()
              : Value(scanlationGroup),
      webUrl:
          webUrl == null && nullToAbsent ? const Value.absent() : Value(webUrl),
      readableAt:
          readableAt == null && nullToAbsent
              ? const Value.absent()
              : Value(readableAt),
      publishAt:
          publishAt == null && nullToAbsent
              ? const Value.absent()
              : Value(publishAt),
      lastReadAt:
          lastReadAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastReadAt),
    );
  }

  factory ChapterTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      title: serializer.fromJson<String?>(json['title']),
      volume: serializer.fromJson<String?>(json['volume']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      translatedLanguage: serializer.fromJson<String?>(
        json['translatedLanguage'],
      ),
      scanlationGroup: serializer.fromJson<String?>(json['scanlationGroup']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      readableAt: serializer.fromJson<int?>(json['readableAt']),
      publishAt: serializer.fromJson<int?>(json['publishAt']),
      lastReadAt: serializer.fromJson<int?>(json['lastReadAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'mangaId': serializer.toJson<String?>(mangaId),
      'title': serializer.toJson<String?>(title),
      'volume': serializer.toJson<String?>(volume),
      'chapter': serializer.toJson<String?>(chapter),
      'translatedLanguage': serializer.toJson<String?>(translatedLanguage),
      'scanlationGroup': serializer.toJson<String?>(scanlationGroup),
      'webUrl': serializer.toJson<String?>(webUrl),
      'readableAt': serializer.toJson<int?>(readableAt),
      'publishAt': serializer.toJson<int?>(publishAt),
      'lastReadAt': serializer.toJson<int?>(lastReadAt),
    };
  }

  ChapterTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    Value<String?> mangaId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> volume = const Value.absent(),
    Value<String?> chapter = const Value.absent(),
    Value<String?> translatedLanguage = const Value.absent(),
    Value<String?> scanlationGroup = const Value.absent(),
    Value<String?> webUrl = const Value.absent(),
    Value<int?> readableAt = const Value.absent(),
    Value<int?> publishAt = const Value.absent(),
    Value<int?> lastReadAt = const Value.absent(),
  }) => ChapterTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    mangaId: mangaId.present ? mangaId.value : this.mangaId,
    title: title.present ? title.value : this.title,
    volume: volume.present ? volume.value : this.volume,
    chapter: chapter.present ? chapter.value : this.chapter,
    translatedLanguage:
        translatedLanguage.present
            ? translatedLanguage.value
            : this.translatedLanguage,
    scanlationGroup:
        scanlationGroup.present ? scanlationGroup.value : this.scanlationGroup,
    webUrl: webUrl.present ? webUrl.value : this.webUrl,
    readableAt: readableAt.present ? readableAt.value : this.readableAt,
    publishAt: publishAt.present ? publishAt.value : this.publishAt,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
  );
  ChapterTablesData copyWithCompanion(ChapterTablesCompanion data) {
    return ChapterTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      title: data.title.present ? data.title.value : this.title,
      volume: data.volume.present ? data.volume.value : this.volume,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      translatedLanguage:
          data.translatedLanguage.present
              ? data.translatedLanguage.value
              : this.translatedLanguage,
      scanlationGroup:
          data.scanlationGroup.present
              ? data.scanlationGroup.value
              : this.scanlationGroup,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      readableAt:
          data.readableAt.present ? data.readableAt.value : this.readableAt,
      publishAt: data.publishAt.present ? data.publishAt.value : this.publishAt,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('title: $title, ')
          ..write('volume: $volume, ')
          ..write('chapter: $chapter, ')
          ..write('translatedLanguage: $translatedLanguage, ')
          ..write('scanlationGroup: $scanlationGroup, ')
          ..write('webUrl: $webUrl, ')
          ..write('readableAt: $readableAt, ')
          ..write('publishAt: $publishAt, ')
          ..write('lastReadAt: $lastReadAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    mangaId,
    title,
    volume,
    chapter,
    translatedLanguage,
    scanlationGroup,
    webUrl,
    readableAt,
    publishAt,
    lastReadAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.title == this.title &&
          other.volume == this.volume &&
          other.chapter == this.chapter &&
          other.translatedLanguage == this.translatedLanguage &&
          other.scanlationGroup == this.scanlationGroup &&
          other.webUrl == this.webUrl &&
          other.readableAt == this.readableAt &&
          other.publishAt == this.publishAt &&
          other.lastReadAt == this.lastReadAt);
}

class ChapterTablesCompanion extends UpdateCompanion<ChapterTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String?> mangaId;
  final Value<String?> title;
  final Value<String?> volume;
  final Value<String?> chapter;
  final Value<String?> translatedLanguage;
  final Value<String?> scanlationGroup;
  final Value<String?> webUrl;
  final Value<int?> readableAt;
  final Value<int?> publishAt;
  final Value<int?> lastReadAt;
  final Value<int> rowid;
  const ChapterTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.title = const Value.absent(),
    this.volume = const Value.absent(),
    this.chapter = const Value.absent(),
    this.translatedLanguage = const Value.absent(),
    this.scanlationGroup = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.readableAt = const Value.absent(),
    this.publishAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    this.mangaId = const Value.absent(),
    this.title = const Value.absent(),
    this.volume = const Value.absent(),
    this.chapter = const Value.absent(),
    this.translatedLanguage = const Value.absent(),
    this.scanlationGroup = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.readableAt = const Value.absent(),
    this.publishAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id);
  static Insertable<ChapterTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? mangaId,
    Expression<String>? title,
    Expression<String>? volume,
    Expression<String>? chapter,
    Expression<String>? translatedLanguage,
    Expression<String>? scanlationGroup,
    Expression<String>? webUrl,
    Expression<int>? readableAt,
    Expression<int>? publishAt,
    Expression<int>? lastReadAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (title != null) 'title': title,
      if (volume != null) 'volume': volume,
      if (chapter != null) 'chapter': chapter,
      if (translatedLanguage != null) 'translated_language': translatedLanguage,
      if (scanlationGroup != null) 'scanlation_group': scanlationGroup,
      if (webUrl != null) 'webUrl': webUrl,
      if (readableAt != null) 'readable_at': readableAt,
      if (publishAt != null) 'publish_at': publishAt,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String?>? mangaId,
    Value<String?>? title,
    Value<String?>? volume,
    Value<String?>? chapter,
    Value<String?>? translatedLanguage,
    Value<String?>? scanlationGroup,
    Value<String?>? webUrl,
    Value<int?>? readableAt,
    Value<int?>? publishAt,
    Value<int?>? lastReadAt,
    Value<int>? rowid,
  }) {
    return ChapterTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      chapter: chapter ?? this.chapter,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      scanlationGroup: scanlationGroup ?? this.scanlationGroup,
      webUrl: webUrl ?? this.webUrl,
      readableAt: readableAt ?? this.readableAt,
      publishAt: publishAt ?? this.publishAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (volume.present) {
      map['volume'] = Variable<String>(volume.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<String>(chapter.value);
    }
    if (translatedLanguage.present) {
      map['translated_language'] = Variable<String>(translatedLanguage.value);
    }
    if (scanlationGroup.present) {
      map['scanlation_group'] = Variable<String>(scanlationGroup.value);
    }
    if (webUrl.present) {
      map['webUrl'] = Variable<String>(webUrl.value);
    }
    if (readableAt.present) {
      map['readable_at'] = Variable<int>(readableAt.value);
    }
    if (publishAt.present) {
      map['publish_at'] = Variable<int>(publishAt.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<int>(lastReadAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('title: $title, ')
          ..write('volume: $volume, ')
          ..write('chapter: $chapter, ')
          ..write('translatedLanguage: $translatedLanguage, ')
          ..write('scanlationGroup: $scanlationGroup, ')
          ..write('webUrl: $webUrl, ')
          ..write('readableAt: $readableAt, ')
          ..write('publishAt: $publishAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LibraryTables extends Table
    with TableInfo<LibraryTables, LibraryTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LibraryTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
    'manga_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, mangaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {mangaId};
  @override
  LibraryTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      mangaId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}manga_id'],
          )!,
    );
  }

  @override
  LibraryTables createAlias(String alias) {
    return LibraryTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(manga_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class LibraryTablesData extends DataClass
    implements Insertable<LibraryTablesData> {
  final int createdAt;
  final int updatedAt;
  final String mangaId;
  const LibraryTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.mangaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['manga_id'] = Variable<String>(mangaId);
    return map;
  }

  LibraryTablesCompanion toCompanion(bool nullToAbsent) {
    return LibraryTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      mangaId: Value(mangaId),
    );
  }

  factory LibraryTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  LibraryTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    String? mangaId,
  }) => LibraryTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    mangaId: mangaId ?? this.mangaId,
  );
  LibraryTablesData copyWithCompanion(LibraryTablesCompanion data) {
    return LibraryTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, mangaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.mangaId == this.mangaId);
}

class LibraryTablesCompanion extends UpdateCompanion<LibraryTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> mangaId;
  final Value<int> rowid;
  const LibraryTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String mangaId,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       mangaId = Value(mangaId);
  static Insertable<LibraryTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? mangaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (mangaId != null) 'manga_id': mangaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? mangaId,
    Value<int>? rowid,
  }) {
    return LibraryTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mangaId: mangaId ?? this.mangaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mangaId: $mangaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MangaTables extends Table with TableInfo<MangaTables, MangaTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MangaTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
    'web_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    title,
    coverUrl,
    author,
    status,
    description,
    webUrl,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {webUrl, source},
    {webUrl},
  ];
  @override
  MangaTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      webUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}web_url'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  MangaTables createAlias(String alias) {
    return MangaTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'UNIQUE(web_url, source)',
    'UNIQUE(web_url)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MangaTablesData extends DataClass implements Insertable<MangaTablesData> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  const MangaTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || webUrl != null) {
      map['web_url'] = Variable<String>(webUrl);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  MangaTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      coverUrl:
          coverUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(coverUrl),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      webUrl:
          webUrl == null && nullToAbsent ? const Value.absent() : Value(webUrl),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory MangaTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      author: serializer.fromJson<String?>(json['author']),
      status: serializer.fromJson<String?>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'author': serializer.toJson<String?>(author),
      'status': serializer.toJson<String?>(status),
      'description': serializer.toJson<String?>(description),
      'webUrl': serializer.toJson<String?>(webUrl),
      'source': serializer.toJson<String?>(source),
    };
  }

  MangaTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> webUrl = const Value.absent(),
    Value<String?> source = const Value.absent(),
  }) => MangaTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    author: author.present ? author.value : this.author,
    status: status.present ? status.value : this.status,
    description: description.present ? description.value : this.description,
    webUrl: webUrl.present ? webUrl.value : this.webUrl,
    source: source.present ? source.value : this.source,
  );
  MangaTablesData copyWithCompanion(MangaTablesCompanion data) {
    return MangaTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      author: data.author.present ? data.author.value : this.author,
      status: data.status.present ? data.status.value : this.status,
      description:
          data.description.present ? data.description.value : this.description,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('webUrl: $webUrl, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    title,
    coverUrl,
    author,
    status,
    description,
    webUrl,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.author == this.author &&
          other.status == this.status &&
          other.description == this.description &&
          other.webUrl == this.webUrl &&
          other.source == this.source);
}

class MangaTablesCompanion extends UpdateCompanion<MangaTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> coverUrl;
  final Value<String?> author;
  final Value<String?> status;
  final Value<String?> description;
  final Value<String?> webUrl;
  final Value<String?> source;
  final Value<int> rowid;
  const MangaTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id);
  static Insertable<MangaTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<String>? author,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? webUrl,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (author != null) 'author': author,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (webUrl != null) 'web_url': webUrl,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? coverUrl,
    Value<String?>? author,
    Value<String?>? status,
    Value<String?>? description,
    Value<String?>? webUrl,
    Value<String?>? source,
    Value<int>? rowid,
  }) {
    return MangaTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      webUrl: webUrl ?? this.webUrl,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (webUrl.present) {
      map['web_url'] = Variable<String>(webUrl.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('webUrl: $webUrl, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TagTables extends Table with TableInfo<TagTables, TagTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TagTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    tagId,
    name,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tagId, name},
    {tagId, name, source},
  ];
  @override
  TagTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      ),
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  TagTables createAlias(String alias) {
    return TagTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(tag_id, name)',
    'UNIQUE(tag_id, name, source)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TagTablesData extends DataClass implements Insertable<TagTablesData> {
  final int createdAt;
  final int updatedAt;
  final int id;
  final String? tagId;
  final String name;
  final String? source;
  const TagTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.tagId,
    required this.name,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tagId != null) {
      map['tag_id'] = Variable<String>(tagId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  TagTablesCompanion toCompanion(bool nullToAbsent) {
    return TagTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      tagId:
          tagId == null && nullToAbsent ? const Value.absent() : Value(tagId),
      name: Value(name),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory TagTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      tagId: serializer.fromJson<String?>(json['tagId']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<int>(id),
      'tagId': serializer.toJson<String?>(tagId),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String?>(source),
    };
  }

  TagTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    int? id,
    Value<String?> tagId = const Value.absent(),
    String? name,
    Value<String?> source = const Value.absent(),
  }) => TagTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    tagId: tagId.present ? tagId.value : this.tagId,
    name: name ?? this.name,
    source: source.present ? source.value : this.source,
  );
  TagTablesData copyWithCompanion(TagTablesCompanion data) {
    return TagTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('name: $name, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, id, tagId, name, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.name == this.name &&
          other.source == this.source);
}

class TagTablesCompanion extends UpdateCompanion<TagTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> id;
  final Value<String?> tagId;
  final Value<String> name;
  final Value<String?> source;
  const TagTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
  });
  TagTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    required String name,
    this.source = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<TagTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? id,
    Expression<String>? tagId,
    Expression<String>? name,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
    });
  }

  TagTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? id,
    Value<String?>? tagId,
    Value<String>? name,
    Value<String?>? source,
  }) {
    return TagTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      name: name ?? this.name,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('name: $name, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class RelationshipTables extends Table
    with TableInfo<RelationshipTables, RelationshipTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RelationshipTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
    'manga_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, tagId, mangaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationship_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tagId, mangaId},
  ];
  @override
  RelationshipTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      tagId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}tag_id'],
          )!,
      mangaId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}manga_id'],
          )!,
    );
  }

  @override
  RelationshipTables createAlias(String alias) {
    return RelationshipTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(tag_id, manga_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class RelationshipTablesData extends DataClass
    implements Insertable<RelationshipTablesData> {
  final int createdAt;
  final int updatedAt;
  final int tagId;
  final String mangaId;
  const RelationshipTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.tagId,
    required this.mangaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['tag_id'] = Variable<int>(tagId);
    map['manga_id'] = Variable<String>(mangaId);
    return map;
  }

  RelationshipTablesCompanion toCompanion(bool nullToAbsent) {
    return RelationshipTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tagId: Value(tagId),
      mangaId: Value(mangaId),
    );
  }

  factory RelationshipTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      tagId: serializer.fromJson<int>(json['tagId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'tagId': serializer.toJson<int>(tagId),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  RelationshipTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    int? tagId,
    String? mangaId,
  }) => RelationshipTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tagId: tagId ?? this.tagId,
    mangaId: mangaId ?? this.mangaId,
  );
  RelationshipTablesData copyWithCompanion(RelationshipTablesCompanion data) {
    return RelationshipTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tagId: $tagId, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, tagId, mangaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tagId == this.tagId &&
          other.mangaId == this.mangaId);
}

class RelationshipTablesCompanion
    extends UpdateCompanion<RelationshipTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> tagId;
  final Value<String> mangaId;
  final Value<int> rowid;
  const RelationshipTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tagId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required int tagId,
    required String mangaId,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       tagId = Value(tagId),
       mangaId = Value(mangaId);
  static Insertable<RelationshipTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? tagId,
    Expression<String>? mangaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tagId != null) 'tag_id': tagId,
      if (mangaId != null) 'manga_id': mangaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? tagId,
    Value<String>? mangaId,
    Value<int>? rowid,
  }) {
    return RelationshipTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagId: tagId ?? this.tagId,
      mangaId: mangaId ?? this.mangaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tagId: $tagId, ')
          ..write('mangaId: $mangaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class JobTables extends Table with TableInfo<JobTables, JobTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JobTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
    'manga_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    type,
    source,
    chapterId,
    mangaId,
    imageUrl,
    path,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      ),
      mangaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_id'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
    );
  }

  @override
  JobTables createAlias(String alias) {
    return JobTables(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class JobTablesData extends DataClass implements Insertable<JobTablesData> {
  final int createdAt;
  final int updatedAt;
  final int id;
  final String type;
  final String? source;
  final String? chapterId;
  final String? mangaId;
  final String? imageUrl;
  final String? path;
  const JobTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.type,
    this.source,
    this.chapterId,
    this.mangaId,
    this.imageUrl,
    this.path,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    if (!nullToAbsent || mangaId != null) {
      map['manga_id'] = Variable<String>(mangaId);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    return map;
  }

  JobTablesCompanion toCompanion(bool nullToAbsent) {
    return JobTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      type: Value(type),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      chapterId:
          chapterId == null && nullToAbsent
              ? const Value.absent()
              : Value(chapterId),
      mangaId:
          mangaId == null && nullToAbsent
              ? const Value.absent()
              : Value(mangaId),
      imageUrl:
          imageUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(imageUrl),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
    );
  }

  factory JobTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      source: serializer.fromJson<String?>(json['source']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      path: serializer.fromJson<String?>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'source': serializer.toJson<String?>(source),
      'chapterId': serializer.toJson<String?>(chapterId),
      'mangaId': serializer.toJson<String?>(mangaId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'path': serializer.toJson<String?>(path),
    };
  }

  JobTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    int? id,
    String? type,
    Value<String?> source = const Value.absent(),
    Value<String?> chapterId = const Value.absent(),
    Value<String?> mangaId = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> path = const Value.absent(),
  }) => JobTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    type: type ?? this.type,
    source: source.present ? source.value : this.source,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    mangaId: mangaId.present ? mangaId.value : this.mangaId,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    path: path.present ? path.value : this.path,
  );
  JobTablesData copyWithCompanion(JobTablesCompanion data) {
    return JobTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    type,
    source,
    chapterId,
    mangaId,
    imageUrl,
    path,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.type == this.type &&
          other.source == this.source &&
          other.chapterId == this.chapterId &&
          other.mangaId == this.mangaId &&
          other.imageUrl == this.imageUrl &&
          other.path == this.path);
}

class JobTablesCompanion extends UpdateCompanion<JobTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> id;
  final Value<String> type;
  final Value<String?> source;
  final Value<String?> chapterId;
  final Value<String?> mangaId;
  final Value<String?> imageUrl;
  final Value<String?> path;
  const JobTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.path = const Value.absent(),
  });
  JobTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    this.id = const Value.absent(),
    required String type,
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.path = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       type = Value(type);
  static Insertable<JobTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? chapterId,
    Expression<String>? mangaId,
    Expression<String>? imageUrl,
    Expression<String>? path,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (chapterId != null) 'chapter_id': chapterId,
      if (mangaId != null) 'manga_id': mangaId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (path != null) 'path': path,
    });
  }

  JobTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? id,
    Value<String>? type,
    Value<String?>? source,
    Value<String?>? chapterId,
    Value<String?>? mangaId,
    Value<String?>? imageUrl,
    Value<String?>? path,
  }) {
    return JobTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      chapterId: chapterId ?? this.chapterId,
      mangaId: mangaId ?? this.mangaId,
      imageUrl: imageUrl ?? this.imageUrl,
      path: path ?? this.path,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }
}

class FileTables extends Table with TableInfo<FileTables, FileTablesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FileTables(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
    'web_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    webUrl,
    relativePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_tables';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {webUrl},
  ];
  @override
  FileTablesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileTablesData(
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      webUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}web_url'],
          )!,
      relativePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}relative_path'],
          )!,
    );
  }

  @override
  FileTables createAlias(String alias) {
    return FileTables(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(id)',
    'UNIQUE(web_url)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class FileTablesData extends DataClass implements Insertable<FileTablesData> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String webUrl;
  final String relativePath;
  const FileTablesData({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.webUrl,
    required this.relativePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['web_url'] = Variable<String>(webUrl);
    map['relative_path'] = Variable<String>(relativePath);
    return map;
  }

  FileTablesCompanion toCompanion(bool nullToAbsent) {
    return FileTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      webUrl: Value(webUrl),
      relativePath: Value(relativePath),
    );
  }

  factory FileTablesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileTablesData(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      webUrl: serializer.fromJson<String>(json['webUrl']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'webUrl': serializer.toJson<String>(webUrl),
      'relativePath': serializer.toJson<String>(relativePath),
    };
  }

  FileTablesData copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? webUrl,
    String? relativePath,
  }) => FileTablesData(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    webUrl: webUrl ?? this.webUrl,
    relativePath: relativePath ?? this.relativePath,
  );
  FileTablesData copyWithCompanion(FileTablesCompanion data) {
    return FileTablesData(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      relativePath:
          data.relativePath.present
              ? data.relativePath.value
              : this.relativePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileTablesData(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('webUrl: $webUrl, ')
          ..write('relativePath: $relativePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, id, webUrl, relativePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileTablesData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.webUrl == this.webUrl &&
          other.relativePath == this.relativePath);
}

class FileTablesCompanion extends UpdateCompanion<FileTablesData> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> webUrl;
  final Value<String> relativePath;
  final Value<int> rowid;
  const FileTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileTablesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String webUrl,
    required String relativePath,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       webUrl = Value(webUrl),
       relativePath = Value(relativePath);
  static Insertable<FileTablesData> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? webUrl,
    Expression<String>? relativePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (webUrl != null) 'web_url': webUrl,
      if (relativePath != null) 'relative_path': relativePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileTablesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? webUrl,
    Value<String>? relativePath,
    Value<int>? rowid,
  }) {
    return FileTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      webUrl: webUrl ?? this.webUrl,
      relativePath: relativePath ?? this.relativePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (webUrl.present) {
      map['web_url'] = Variable<String>(webUrl.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('webUrl: $webUrl, ')
          ..write('relativePath: $relativePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final ImageTables imageTables = ImageTables(this);
  late final ChapterTables chapterTables = ChapterTables(this);
  late final LibraryTables libraryTables = LibraryTables(this);
  late final MangaTables mangaTables = MangaTables(this);
  late final TagTables tagTables = TagTables(this);
  late final RelationshipTables relationshipTables = RelationshipTables(this);
  late final JobTables jobTables = JobTables(this);
  late final FileTables fileTables = FileTables(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    imageTables,
    chapterTables,
    libraryTables,
    mangaTables,
    tagTables,
    relationshipTables,
    jobTables,
    fileTables,
  ];
  @override
  int get schemaVersion => 2;
}
