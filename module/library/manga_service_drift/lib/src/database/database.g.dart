// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ImageTablesTable extends ImageTables
    with TableInfo<$ImageTablesTable, ImageDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _webUrlMeta = const VerificationMeta('webUrl');
  @override
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
      'web_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, order, chapterId, webUrl, id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_tables';
  @override
  VerificationContext validateIntegrity(Insertable<ImageDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('web_url')) {
      context.handle(_webUrlMeta,
          webUrl.isAcceptableOrUnknown(data['web_url']!, _webUrlMeta));
    } else if (isInserting) {
      context.missing(_webUrlMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      webUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}web_url'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $ImageTablesTable createAlias(String alias) {
    return $ImageTablesTable(attachedDatabase, alias);
  }
}

class ImageDrift extends DataClass implements Insertable<ImageDrift> {
  final String createdAt;
  final String updatedAt;
  final int order;
  final String chapterId;
  final String webUrl;
  final String id;
  const ImageDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.order,
      required this.chapterId,
      required this.webUrl,
      required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['order'] = Variable<int>(order);
    map['chapter_id'] = Variable<String>(chapterId);
    map['web_url'] = Variable<String>(webUrl);
    map['id'] = Variable<String>(id);
    return map;
  }

  ImageTablesCompanion toCompanion(bool nullToAbsent) {
    return ImageTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      order: Value(order),
      chapterId: Value(chapterId),
      webUrl: Value(webUrl),
      id: Value(id),
    );
  }

  factory ImageDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      order: serializer.fromJson<int>(json['order']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      webUrl: serializer.fromJson<String>(json['webUrl']),
      id: serializer.fromJson<String>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'order': serializer.toJson<int>(order),
      'chapterId': serializer.toJson<String>(chapterId),
      'webUrl': serializer.toJson<String>(webUrl),
      'id': serializer.toJson<String>(id),
    };
  }

  ImageDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          int? order,
          String? chapterId,
          String? webUrl,
          String? id}) =>
      ImageDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        order: order ?? this.order,
        chapterId: chapterId ?? this.chapterId,
        webUrl: webUrl ?? this.webUrl,
        id: id ?? this.id,
      );
  ImageDrift copyWithCompanion(ImageTablesCompanion data) {
    return ImageDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      order: data.order.present ? data.order.value : this.order,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('order: $order, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, order, chapterId, webUrl, id);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.order == this.order &&
          other.chapterId == this.chapterId &&
          other.webUrl == this.webUrl &&
          other.id == this.id);
}

class ImageTablesCompanion extends UpdateCompanion<ImageDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> order;
  final Value<String> chapterId;
  final Value<String> webUrl;
  final Value<String> id;
  final Value<int> rowid;
  const ImageTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required int order,
    required String chapterId,
    required String webUrl,
    required String id,
    this.rowid = const Value.absent(),
  })  : order = Value(order),
        chapterId = Value(chapterId),
        webUrl = Value(webUrl),
        id = Value(id);
  static Insertable<ImageDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? order,
    Expression<String>? chapterId,
    Expression<String>? webUrl,
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (order != null) 'order': order,
      if (chapterId != null) 'chapter_id': chapterId,
      if (webUrl != null) 'web_url': webUrl,
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? order,
      Value<String>? chapterId,
      Value<String>? webUrl,
      Value<String>? id,
      Value<int>? rowid}) {
    return ImageTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
      chapterId: chapterId ?? this.chapterId,
      webUrl: webUrl ?? this.webUrl,
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
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
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
          ..write('order: $order, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl, ')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterTablesTable extends ChapterTables
    with TableInfo<$ChapterTablesTable, ChapterDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
      'volume', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterMeta =
      const VerificationMeta('chapter');
  @override
  late final GeneratedColumn<String> chapter = GeneratedColumn<String>(
      'chapter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _translatedLanguageMeta =
      const VerificationMeta('translatedLanguage');
  @override
  late final GeneratedColumn<String> translatedLanguage =
      GeneratedColumn<String>('translated_language', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scanlationGroupMeta =
      const VerificationMeta('scanlationGroup');
  @override
  late final GeneratedColumn<String> scanlationGroup = GeneratedColumn<String>(
      'scanlation_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _webUrlMeta = const VerificationMeta('webUrl');
  @override
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
      'webUrl', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _readableAtMeta =
      const VerificationMeta('readableAt');
  @override
  late final GeneratedColumn<String> readableAt = GeneratedColumn<String>(
      'readable_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publishAtMeta =
      const VerificationMeta('publishAt');
  @override
  late final GeneratedColumn<String> publishAt = GeneratedColumn<String>(
      'publish_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        publishAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_tables';
  @override
  VerificationContext validateIntegrity(Insertable<ChapterDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    }
    if (data.containsKey('chapter')) {
      context.handle(_chapterMeta,
          chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta));
    }
    if (data.containsKey('translated_language')) {
      context.handle(
          _translatedLanguageMeta,
          translatedLanguage.isAcceptableOrUnknown(
              data['translated_language']!, _translatedLanguageMeta));
    }
    if (data.containsKey('scanlation_group')) {
      context.handle(
          _scanlationGroupMeta,
          scanlationGroup.isAcceptableOrUnknown(
              data['scanlation_group']!, _scanlationGroupMeta));
    }
    if (data.containsKey('webUrl')) {
      context.handle(_webUrlMeta,
          webUrl.isAcceptableOrUnknown(data['webUrl']!, _webUrlMeta));
    }
    if (data.containsKey('readable_at')) {
      context.handle(
          _readableAtMeta,
          readableAt.isAcceptableOrUnknown(
              data['readable_at']!, _readableAtMeta));
    }
    if (data.containsKey('publish_at')) {
      context.handle(_publishAtMeta,
          publishAt.isAcceptableOrUnknown(data['publish_at']!, _publishAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}volume']),
      chapter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter']),
      translatedLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}translated_language']),
      scanlationGroup: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scanlation_group']),
      webUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}webUrl']),
      readableAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}readable_at']),
      publishAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publish_at']),
    );
  }

  @override
  $ChapterTablesTable createAlias(String alias) {
    return $ChapterTablesTable(attachedDatabase, alias);
  }
}

class ChapterDrift extends DataClass implements Insertable<ChapterDrift> {
  final String createdAt;
  final String updatedAt;
  final String id;
  final String? mangaId;
  final String? title;
  final String? volume;
  final String? chapter;
  final String? translatedLanguage;
  final String? scanlationGroup;
  final String? webUrl;

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  final String? readableAt;

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  final String? publishAt;
  const ChapterDrift(
      {required this.createdAt,
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
      this.publishAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
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
      map['readable_at'] = Variable<String>(readableAt);
    }
    if (!nullToAbsent || publishAt != null) {
      map['publish_at'] = Variable<String>(publishAt);
    }
    return map;
  }

  ChapterTablesCompanion toCompanion(bool nullToAbsent) {
    return ChapterTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      mangaId: mangaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      volume:
          volume == null && nullToAbsent ? const Value.absent() : Value(volume),
      chapter: chapter == null && nullToAbsent
          ? const Value.absent()
          : Value(chapter),
      translatedLanguage: translatedLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedLanguage),
      scanlationGroup: scanlationGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(scanlationGroup),
      webUrl:
          webUrl == null && nullToAbsent ? const Value.absent() : Value(webUrl),
      readableAt: readableAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readableAt),
      publishAt: publishAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishAt),
    );
  }

  factory ChapterDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      title: serializer.fromJson<String?>(json['title']),
      volume: serializer.fromJson<String?>(json['volume']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      translatedLanguage:
          serializer.fromJson<String?>(json['translatedLanguage']),
      scanlationGroup: serializer.fromJson<String?>(json['scanlationGroup']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      readableAt: serializer.fromJson<String?>(json['readableAt']),
      publishAt: serializer.fromJson<String?>(json['publishAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'id': serializer.toJson<String>(id),
      'mangaId': serializer.toJson<String?>(mangaId),
      'title': serializer.toJson<String?>(title),
      'volume': serializer.toJson<String?>(volume),
      'chapter': serializer.toJson<String?>(chapter),
      'translatedLanguage': serializer.toJson<String?>(translatedLanguage),
      'scanlationGroup': serializer.toJson<String?>(scanlationGroup),
      'webUrl': serializer.toJson<String?>(webUrl),
      'readableAt': serializer.toJson<String?>(readableAt),
      'publishAt': serializer.toJson<String?>(publishAt),
    };
  }

  ChapterDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          String? id,
          Value<String?> mangaId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> volume = const Value.absent(),
          Value<String?> chapter = const Value.absent(),
          Value<String?> translatedLanguage = const Value.absent(),
          Value<String?> scanlationGroup = const Value.absent(),
          Value<String?> webUrl = const Value.absent(),
          Value<String?> readableAt = const Value.absent(),
          Value<String?> publishAt = const Value.absent()}) =>
      ChapterDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        mangaId: mangaId.present ? mangaId.value : this.mangaId,
        title: title.present ? title.value : this.title,
        volume: volume.present ? volume.value : this.volume,
        chapter: chapter.present ? chapter.value : this.chapter,
        translatedLanguage: translatedLanguage.present
            ? translatedLanguage.value
            : this.translatedLanguage,
        scanlationGroup: scanlationGroup.present
            ? scanlationGroup.value
            : this.scanlationGroup,
        webUrl: webUrl.present ? webUrl.value : this.webUrl,
        readableAt: readableAt.present ? readableAt.value : this.readableAt,
        publishAt: publishAt.present ? publishAt.value : this.publishAt,
      );
  ChapterDrift copyWithCompanion(ChapterTablesCompanion data) {
    return ChapterDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      title: data.title.present ? data.title.value : this.title,
      volume: data.volume.present ? data.volume.value : this.volume,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      translatedLanguage: data.translatedLanguage.present
          ? data.translatedLanguage.value
          : this.translatedLanguage,
      scanlationGroup: data.scanlationGroup.present
          ? data.scanlationGroup.value
          : this.scanlationGroup,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      readableAt:
          data.readableAt.present ? data.readableAt.value : this.readableAt,
      publishAt: data.publishAt.present ? data.publishAt.value : this.publishAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterDrift(')
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
          ..write('publishAt: $publishAt')
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
      publishAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterDrift &&
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
          other.publishAt == this.publishAt);
}

class ChapterTablesCompanion extends UpdateCompanion<ChapterDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> id;
  final Value<String?> mangaId;
  final Value<String?> title;
  final Value<String?> volume;
  final Value<String?> chapter;
  final Value<String?> translatedLanguage;
  final Value<String?> scanlationGroup;
  final Value<String?> webUrl;
  final Value<String?> readableAt;
  final Value<String?> publishAt;
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
    this.rowid = const Value.absent(),
  });
  ChapterTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
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
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ChapterDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? id,
    Expression<String>? mangaId,
    Expression<String>? title,
    Expression<String>? volume,
    Expression<String>? chapter,
    Expression<String>? translatedLanguage,
    Expression<String>? scanlationGroup,
    Expression<String>? webUrl,
    Expression<String>? readableAt,
    Expression<String>? publishAt,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? id,
      Value<String?>? mangaId,
      Value<String?>? title,
      Value<String?>? volume,
      Value<String?>? chapter,
      Value<String?>? translatedLanguage,
      Value<String?>? scanlationGroup,
      Value<String?>? webUrl,
      Value<String?>? readableAt,
      Value<String?>? publishAt,
      Value<int>? rowid}) {
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
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
      map['readable_at'] = Variable<String>(readableAt.value);
    }
    if (publishAt.present) {
      map['publish_at'] = Variable<String>(publishAt.value);
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryTablesTable extends LibraryTables
    with TableInfo<$LibraryTablesTable, LibraryDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<BigInt> id = GeneratedColumn<BigInt>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, id, mangaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_tables';
  @override
  VerificationContext validateIntegrity(Insertable<LibraryDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
    );
  }

  @override
  $LibraryTablesTable createAlias(String alias) {
    return $LibraryTablesTable(attachedDatabase, alias);
  }
}

class LibraryDrift extends DataClass implements Insertable<LibraryDrift> {
  final String createdAt;
  final String updatedAt;
  final BigInt id;
  final String mangaId;
  const LibraryDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.mangaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['id'] = Variable<BigInt>(id);
    map['manga_id'] = Variable<String>(mangaId);
    return map;
  }

  LibraryTablesCompanion toCompanion(bool nullToAbsent) {
    return LibraryTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      mangaId: Value(mangaId),
    );
  }

  factory LibraryDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      id: serializer.fromJson<BigInt>(json['id']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'id': serializer.toJson<BigInt>(id),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  LibraryDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          BigInt? id,
          String? mangaId}) =>
      LibraryDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
      );
  LibraryDrift copyWithCompanion(LibraryTablesCompanion data) {
    return LibraryDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, mangaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.mangaId == this.mangaId);
}

class LibraryTablesCompanion extends UpdateCompanion<LibraryDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<BigInt> id;
  final Value<String> mangaId;
  const LibraryTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
  });
  LibraryTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String mangaId,
  }) : mangaId = Value(mangaId);
  static Insertable<LibraryDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<BigInt>? id,
    Expression<String>? mangaId,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
    });
  }

  LibraryTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<BigInt>? id,
      Value<String>? mangaId}) {
    return LibraryTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<BigInt>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }
}

class $MangaTablesTable extends MangaTables
    with TableInfo<$MangaTablesTable, MangaDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _webUrlMeta = const VerificationMeta('webUrl');
  @override
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
      'web_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_tables';
  @override
  VerificationContext validateIntegrity(Insertable<MangaDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('web_url')) {
      context.handle(_webUrlMeta,
          webUrl.isAcceptableOrUnknown(data['web_url']!, _webUrlMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      webUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}web_url']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
    );
  }

  @override
  $MangaTablesTable createAlias(String alias) {
    return $MangaTablesTable(attachedDatabase, alias);
  }
}

class MangaDrift extends DataClass implements Insertable<MangaDrift> {
  final String createdAt;
  final String updatedAt;
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  const MangaDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      this.title,
      this.coverUrl,
      this.author,
      this.status,
      this.description,
      this.webUrl,
      this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
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
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      webUrl:
          webUrl == null && nullToAbsent ? const Value.absent() : Value(webUrl),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory MangaDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
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
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
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

  MangaDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          String? id,
          Value<String?> title = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> webUrl = const Value.absent(),
          Value<String?> source = const Value.absent()}) =>
      MangaDrift(
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
  MangaDrift copyWithCompanion(MangaTablesCompanion data) {
    return MangaDrift(
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
    return (StringBuffer('MangaDrift(')
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
  int get hashCode => Object.hash(createdAt, updatedAt, id, title, coverUrl,
      author, status, description, webUrl, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaDrift &&
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

class MangaTablesCompanion extends UpdateCompanion<MangaDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String id,
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<MangaDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
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

  MangaTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? id,
      Value<String?>? title,
      Value<String?>? coverUrl,
      Value<String?>? author,
      Value<String?>? status,
      Value<String?>? description,
      Value<String?>? webUrl,
      Value<String?>? source,
      Value<int>? rowid}) {
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
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
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

class $TagTablesTable extends TagTables
    with TableInfo<$TagTablesTable, TagDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_tables';
  @override
  VerificationContext validateIntegrity(Insertable<TagDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagTablesTable createAlias(String alias) {
    return $TagTablesTable(attachedDatabase, alias);
  }
}

class TagDrift extends DataClass implements Insertable<TagDrift> {
  final String createdAt;
  final String updatedAt;
  final String id;
  final String name;
  const TagDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagTablesCompanion toCompanion(bool nullToAbsent) {
    return TagTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
    );
  }

  factory TagDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagDrift copyWith(
          {String? createdAt, String? updatedAt, String? id, String? name}) =>
      TagDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  TagDrift copyWithCompanion(TagTablesCompanion data) {
    return TagDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name);
}

class TagTablesCompanion extends UpdateCompanion<TagDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<TagDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<int>? rowid}) {
    return TagTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipTablesTable extends RelationshipTables
    with TableInfo<$RelationshipTablesTable, RelationshipTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, tagId, mangaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationship_tables';
  @override
  VerificationContext validateIntegrity(Insertable<RelationshipTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tagId, mangaId};
  @override
  RelationshipTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipTable(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
    );
  }

  @override
  $RelationshipTablesTable createAlias(String alias) {
    return $RelationshipTablesTable(attachedDatabase, alias);
  }
}

class RelationshipTable extends DataClass
    implements Insertable<RelationshipTable> {
  final String createdAt;
  final String updatedAt;
  final String tagId;
  final String mangaId;
  const RelationshipTable(
      {required this.createdAt,
      required this.updatedAt,
      required this.tagId,
      required this.mangaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['tag_id'] = Variable<String>(tagId);
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

  factory RelationshipTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipTable(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      tagId: serializer.fromJson<String>(json['tagId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'tagId': serializer.toJson<String>(tagId),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  RelationshipTable copyWith(
          {String? createdAt,
          String? updatedAt,
          String? tagId,
          String? mangaId}) =>
      RelationshipTable(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        tagId: tagId ?? this.tagId,
        mangaId: mangaId ?? this.mangaId,
      );
  RelationshipTable copyWithCompanion(RelationshipTablesCompanion data) {
    return RelationshipTable(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipTable(')
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
      (other is RelationshipTable &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tagId == this.tagId &&
          other.mangaId == this.mangaId);
}

class RelationshipTablesCompanion extends UpdateCompanion<RelationshipTable> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> tagId;
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String tagId,
    required String mangaId,
    this.rowid = const Value.absent(),
  })  : tagId = Value(tagId),
        mangaId = Value(mangaId);
  static Insertable<RelationshipTable> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? tagId,
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

  RelationshipTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? tagId,
      Value<String>? mangaId,
      Value<int>? rowid}) {
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
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
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

class $JobTablesTable extends JobTables
    with TableInfo<$JobTablesTable, JobDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<JobTypeEnum, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JobTypeEnum>($JobTablesTable.$convertertype);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'image_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, type, source, chapterId, mangaId, imageId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_tables';
  @override
  VerificationContext validateIntegrity(Insertable<JobDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    }
    if (data.containsKey('image_id')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $JobTablesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id']),
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_id']),
    );
  }

  @override
  $JobTablesTable createAlias(String alias) {
    return $JobTablesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobTypeEnum, String, String> $convertertype =
      const EnumNameConverter<JobTypeEnum>(JobTypeEnum.values);
}

class JobDrift extends DataClass implements Insertable<JobDrift> {
  final String createdAt;
  final String updatedAt;
  final int id;
  final JobTypeEnum type;
  final String? source;
  final String? chapterId;
  final String? mangaId;
  final String? imageId;
  const JobDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.type,
      this.source,
      this.chapterId,
      this.mangaId,
      this.imageId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<String>($JobTablesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    if (!nullToAbsent || mangaId != null) {
      map['manga_id'] = Variable<String>(mangaId);
    }
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<String>(imageId);
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
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      mangaId: mangaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaId),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
    );
  }

  factory JobDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      type: $JobTablesTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      source: serializer.fromJson<String?>(json['source']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      imageId: serializer.fromJson<String?>(json['imageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<String>($JobTablesTable.$convertertype.toJson(type)),
      'source': serializer.toJson<String?>(source),
      'chapterId': serializer.toJson<String?>(chapterId),
      'mangaId': serializer.toJson<String?>(mangaId),
      'imageId': serializer.toJson<String?>(imageId),
    };
  }

  JobDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          int? id,
          JobTypeEnum? type,
          Value<String?> source = const Value.absent(),
          Value<String?> chapterId = const Value.absent(),
          Value<String?> mangaId = const Value.absent(),
          Value<String?> imageId = const Value.absent()}) =>
      JobDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        type: type ?? this.type,
        source: source.present ? source.value : this.source,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        mangaId: mangaId.present ? mangaId.value : this.mangaId,
        imageId: imageId.present ? imageId.value : this.imageId,
      );
  JobDrift copyWithCompanion(JobTablesCompanion data) {
    return JobDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId, ')
          ..write('imageId: $imageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      createdAt, updatedAt, id, type, source, chapterId, mangaId, imageId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.type == this.type &&
          other.source == this.source &&
          other.chapterId == this.chapterId &&
          other.mangaId == this.mangaId &&
          other.imageId == this.imageId);
}

class JobTablesCompanion extends UpdateCompanion<JobDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> id;
  final Value<JobTypeEnum> type;
  final Value<String?> source;
  final Value<String?> chapterId;
  final Value<String?> mangaId;
  final Value<String?> imageId;
  const JobTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageId = const Value.absent(),
  });
  JobTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required JobTypeEnum type,
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageId = const Value.absent(),
  }) : type = Value(type);
  static Insertable<JobDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? chapterId,
    Expression<String>? mangaId,
    Expression<String>? imageId,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (chapterId != null) 'chapter_id': chapterId,
      if (mangaId != null) 'manga_id': mangaId,
      if (imageId != null) 'image_id': imageId,
    });
  }

  JobTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? id,
      Value<JobTypeEnum>? type,
      Value<String?>? source,
      Value<String?>? chapterId,
      Value<String?>? mangaId,
      Value<String?>? imageId}) {
    return JobTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      chapterId: chapterId ?? this.chapterId,
      mangaId: mangaId ?? this.mangaId,
      imageId: imageId ?? this.imageId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($JobTablesTable.$convertertype.toSql(type.value));
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
    if (imageId.present) {
      map['image_id'] = Variable<String>(imageId.value);
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
          ..write('imageId: $imageId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ImageTablesTable imageTables = $ImageTablesTable(this);
  late final $ChapterTablesTable chapterTables = $ChapterTablesTable(this);
  late final $LibraryTablesTable libraryTables = $LibraryTablesTable(this);
  late final $MangaTablesTable mangaTables = $MangaTablesTable(this);
  late final $TagTablesTable tagTables = $TagTablesTable(this);
  late final $RelationshipTablesTable relationshipTables =
      $RelationshipTablesTable(this);
  late final $JobTablesTable jobTables = $JobTablesTable(this);
  late final MangaDao mangaDao = MangaDao(this as AppDatabase);
  late final ChapterDao chapterDao = ChapterDao(this as AppDatabase);
  late final LibraryDao libraryDao = LibraryDao(this as AppDatabase);
  late final JobDao jobDao = JobDao(this as AppDatabase);
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
        jobTables
      ];
}

typedef $$ImageTablesTableCreateCompanionBuilder = ImageTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required int order,
  required String chapterId,
  required String webUrl,
  required String id,
  Value<int> rowid,
});
typedef $$ImageTablesTableUpdateCompanionBuilder = ImageTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> order,
  Value<String> chapterId,
  Value<String> webUrl,
  Value<String> id,
  Value<int> rowid,
});

class $$ImageTablesTableFilterComposer
    extends Composer<_$AppDatabase, $ImageTablesTable> {
  $$ImageTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
}

class $$ImageTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageTablesTable> {
  $$ImageTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
}

class $$ImageTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageTablesTable> {
  $$ImageTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$ImageTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ImageTablesTable,
    ImageDrift,
    $$ImageTablesTableFilterComposer,
    $$ImageTablesTableOrderingComposer,
    $$ImageTablesTableAnnotationComposer,
    $$ImageTablesTableCreateCompanionBuilder,
    $$ImageTablesTableUpdateCompanionBuilder,
    (ImageDrift, BaseReferences<_$AppDatabase, $ImageTablesTable, ImageDrift>),
    ImageDrift,
    PrefetchHooks Function()> {
  $$ImageTablesTableTableManager(_$AppDatabase db, $ImageTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> webUrl = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            order: order,
            chapterId: chapterId,
            webUrl: webUrl,
            id: id,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required int order,
            required String chapterId,
            required String webUrl,
            required String id,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            order: order,
            chapterId: chapterId,
            webUrl: webUrl,
            id: id,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ImageTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ImageTablesTable,
    ImageDrift,
    $$ImageTablesTableFilterComposer,
    $$ImageTablesTableOrderingComposer,
    $$ImageTablesTableAnnotationComposer,
    $$ImageTablesTableCreateCompanionBuilder,
    $$ImageTablesTableUpdateCompanionBuilder,
    (ImageDrift, BaseReferences<_$AppDatabase, $ImageTablesTable, ImageDrift>),
    ImageDrift,
    PrefetchHooks Function()>;
typedef $$ChapterTablesTableCreateCompanionBuilder = ChapterTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String id,
  Value<String?> mangaId,
  Value<String?> title,
  Value<String?> volume,
  Value<String?> chapter,
  Value<String?> translatedLanguage,
  Value<String?> scanlationGroup,
  Value<String?> webUrl,
  Value<String?> readableAt,
  Value<String?> publishAt,
  Value<int> rowid,
});
typedef $$ChapterTablesTableUpdateCompanionBuilder = ChapterTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> id,
  Value<String?> mangaId,
  Value<String?> title,
  Value<String?> volume,
  Value<String?> chapter,
  Value<String?> translatedLanguage,
  Value<String?> scanlationGroup,
  Value<String?> webUrl,
  Value<String?> readableAt,
  Value<String?> publishAt,
  Value<int> rowid,
});

class $$ChapterTablesTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterTablesTable> {
  $$ChapterTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapter => $composableBuilder(
      column: $table.chapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translatedLanguage => $composableBuilder(
      column: $table.translatedLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scanlationGroup => $composableBuilder(
      column: $table.scanlationGroup,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publishAt => $composableBuilder(
      column: $table.publishAt, builder: (column) => ColumnFilters(column));
}

class $$ChapterTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterTablesTable> {
  $$ChapterTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapter => $composableBuilder(
      column: $table.chapter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translatedLanguage => $composableBuilder(
      column: $table.translatedLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scanlationGroup => $composableBuilder(
      column: $table.scanlationGroup,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publishAt => $composableBuilder(
      column: $table.publishAt, builder: (column) => ColumnOrderings(column));
}

class $$ChapterTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterTablesTable> {
  $$ChapterTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<String> get translatedLanguage => $composableBuilder(
      column: $table.translatedLanguage, builder: (column) => column);

  GeneratedColumn<String> get scanlationGroup => $composableBuilder(
      column: $table.scanlationGroup, builder: (column) => column);

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);

  GeneratedColumn<String> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => column);

  GeneratedColumn<String> get publishAt =>
      $composableBuilder(column: $table.publishAt, builder: (column) => column);
}

class $$ChapterTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChapterTablesTable,
    ChapterDrift,
    $$ChapterTablesTableFilterComposer,
    $$ChapterTablesTableOrderingComposer,
    $$ChapterTablesTableAnnotationComposer,
    $$ChapterTablesTableCreateCompanionBuilder,
    $$ChapterTablesTableUpdateCompanionBuilder,
    (
      ChapterDrift,
      BaseReferences<_$AppDatabase, $ChapterTablesTable, ChapterDrift>
    ),
    ChapterDrift,
    PrefetchHooks Function()> {
  $$ChapterTablesTableTableManager(_$AppDatabase db, $ChapterTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> volume = const Value.absent(),
            Value<String?> chapter = const Value.absent(),
            Value<String?> translatedLanguage = const Value.absent(),
            Value<String?> scanlationGroup = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> readableAt = const Value.absent(),
            Value<String?> publishAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
            title: title,
            volume: volume,
            chapter: chapter,
            translatedLanguage: translatedLanguage,
            scanlationGroup: scanlationGroup,
            webUrl: webUrl,
            readableAt: readableAt,
            publishAt: publishAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required String id,
            Value<String?> mangaId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> volume = const Value.absent(),
            Value<String?> chapter = const Value.absent(),
            Value<String?> translatedLanguage = const Value.absent(),
            Value<String?> scanlationGroup = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> readableAt = const Value.absent(),
            Value<String?> publishAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
            title: title,
            volume: volume,
            chapter: chapter,
            translatedLanguage: translatedLanguage,
            scanlationGroup: scanlationGroup,
            webUrl: webUrl,
            readableAt: readableAt,
            publishAt: publishAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChapterTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChapterTablesTable,
    ChapterDrift,
    $$ChapterTablesTableFilterComposer,
    $$ChapterTablesTableOrderingComposer,
    $$ChapterTablesTableAnnotationComposer,
    $$ChapterTablesTableCreateCompanionBuilder,
    $$ChapterTablesTableUpdateCompanionBuilder,
    (
      ChapterDrift,
      BaseReferences<_$AppDatabase, $ChapterTablesTable, ChapterDrift>
    ),
    ChapterDrift,
    PrefetchHooks Function()>;
typedef $$LibraryTablesTableCreateCompanionBuilder = LibraryTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<BigInt> id,
  required String mangaId,
});
typedef $$LibraryTablesTableUpdateCompanionBuilder = LibraryTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<BigInt> id,
  Value<String> mangaId,
});

class $$LibraryTablesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryTablesTable> {
  $$LibraryTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));
}

class $$LibraryTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryTablesTable> {
  $$LibraryTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));
}

class $$LibraryTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryTablesTable> {
  $$LibraryTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<BigInt> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);
}

class $$LibraryTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LibraryTablesTable,
    LibraryDrift,
    $$LibraryTablesTableFilterComposer,
    $$LibraryTablesTableOrderingComposer,
    $$LibraryTablesTableAnnotationComposer,
    $$LibraryTablesTableCreateCompanionBuilder,
    $$LibraryTablesTableUpdateCompanionBuilder,
    (
      LibraryDrift,
      BaseReferences<_$AppDatabase, $LibraryTablesTable, LibraryDrift>
    ),
    LibraryDrift,
    PrefetchHooks Function()> {
  $$LibraryTablesTableTableManager(_$AppDatabase db, $LibraryTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<BigInt> id = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
          }) =>
              LibraryTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<BigInt> id = const Value.absent(),
            required String mangaId,
          }) =>
              LibraryTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LibraryTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LibraryTablesTable,
    LibraryDrift,
    $$LibraryTablesTableFilterComposer,
    $$LibraryTablesTableOrderingComposer,
    $$LibraryTablesTableAnnotationComposer,
    $$LibraryTablesTableCreateCompanionBuilder,
    $$LibraryTablesTableUpdateCompanionBuilder,
    (
      LibraryDrift,
      BaseReferences<_$AppDatabase, $LibraryTablesTable, LibraryDrift>
    ),
    LibraryDrift,
    PrefetchHooks Function()>;
typedef $$MangaTablesTableCreateCompanionBuilder = MangaTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String id,
  Value<String?> title,
  Value<String?> coverUrl,
  Value<String?> author,
  Value<String?> status,
  Value<String?> description,
  Value<String?> webUrl,
  Value<String?> source,
  Value<int> rowid,
});
typedef $$MangaTablesTableUpdateCompanionBuilder = MangaTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> id,
  Value<String?> title,
  Value<String?> coverUrl,
  Value<String?> author,
  Value<String?> status,
  Value<String?> description,
  Value<String?> webUrl,
  Value<String?> source,
  Value<int> rowid,
});

class $$MangaTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTablesTable> {
  $$MangaTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$MangaTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaTablesTable> {
  $$MangaTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$MangaTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaTablesTable> {
  $$MangaTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$MangaTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaTablesTable,
    MangaDrift,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaDrift, BaseReferences<_$AppDatabase, $MangaTablesTable, MangaDrift>),
    MangaDrift,
    PrefetchHooks Function()> {
  $$MangaTablesTableTableManager(_$AppDatabase db, $MangaTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            title: title,
            coverUrl: coverUrl,
            author: author,
            status: status,
            description: description,
            webUrl: webUrl,
            source: source,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required String id,
            Value<String?> title = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            title: title,
            coverUrl: coverUrl,
            author: author,
            status: status,
            description: description,
            webUrl: webUrl,
            source: source,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MangaTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaTablesTable,
    MangaDrift,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaDrift, BaseReferences<_$AppDatabase, $MangaTablesTable, MangaDrift>),
    MangaDrift,
    PrefetchHooks Function()>;
typedef $$TagTablesTableCreateCompanionBuilder = TagTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$TagTablesTableUpdateCompanionBuilder = TagTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$TagTablesTableFilterComposer
    extends Composer<_$AppDatabase, $TagTablesTable> {
  $$TagTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TagTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $TagTablesTable> {
  $$TagTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagTablesTable> {
  $$TagTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagTablesTable,
    TagDrift,
    $$TagTablesTableFilterComposer,
    $$TagTablesTableOrderingComposer,
    $$TagTablesTableAnnotationComposer,
    $$TagTablesTableCreateCompanionBuilder,
    $$TagTablesTableUpdateCompanionBuilder,
    (TagDrift, BaseReferences<_$AppDatabase, $TagTablesTable, TagDrift>),
    TagDrift,
    PrefetchHooks Function()> {
  $$TagTablesTableTableManager(_$AppDatabase db, $TagTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagTablesTable,
    TagDrift,
    $$TagTablesTableFilterComposer,
    $$TagTablesTableOrderingComposer,
    $$TagTablesTableAnnotationComposer,
    $$TagTablesTableCreateCompanionBuilder,
    $$TagTablesTableUpdateCompanionBuilder,
    (TagDrift, BaseReferences<_$AppDatabase, $TagTablesTable, TagDrift>),
    TagDrift,
    PrefetchHooks Function()>;
typedef $$RelationshipTablesTableCreateCompanionBuilder
    = RelationshipTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String tagId,
  required String mangaId,
  Value<int> rowid,
});
typedef $$RelationshipTablesTableUpdateCompanionBuilder
    = RelationshipTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> tagId,
  Value<String> mangaId,
  Value<int> rowid,
});

class $$RelationshipTablesTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipTablesTable> {
  $$RelationshipTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));
}

class $$RelationshipTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipTablesTable> {
  $$RelationshipTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));
}

class $$RelationshipTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipTablesTable> {
  $$RelationshipTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);
}

class $$RelationshipTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RelationshipTablesTable,
    RelationshipTable,
    $$RelationshipTablesTableFilterComposer,
    $$RelationshipTablesTableOrderingComposer,
    $$RelationshipTablesTableAnnotationComposer,
    $$RelationshipTablesTableCreateCompanionBuilder,
    $$RelationshipTablesTableUpdateCompanionBuilder,
    (
      RelationshipTable,
      BaseReferences<_$AppDatabase, $RelationshipTablesTable, RelationshipTable>
    ),
    RelationshipTable,
    PrefetchHooks Function()> {
  $$RelationshipTablesTableTableManager(
      _$AppDatabase db, $RelationshipTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            tagId: tagId,
            mangaId: mangaId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required String tagId,
            required String mangaId,
            Value<int> rowid = const Value.absent(),
          }) =>
              RelationshipTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            tagId: tagId,
            mangaId: mangaId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RelationshipTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RelationshipTablesTable,
    RelationshipTable,
    $$RelationshipTablesTableFilterComposer,
    $$RelationshipTablesTableOrderingComposer,
    $$RelationshipTablesTableAnnotationComposer,
    $$RelationshipTablesTableCreateCompanionBuilder,
    $$RelationshipTablesTableUpdateCompanionBuilder,
    (
      RelationshipTable,
      BaseReferences<_$AppDatabase, $RelationshipTablesTable, RelationshipTable>
    ),
    RelationshipTable,
    PrefetchHooks Function()>;
typedef $$JobTablesTableCreateCompanionBuilder = JobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> id,
  required JobTypeEnum type,
  Value<String?> source,
  Value<String?> chapterId,
  Value<String?> mangaId,
  Value<String?> imageId,
});
typedef $$JobTablesTableUpdateCompanionBuilder = JobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> id,
  Value<JobTypeEnum> type,
  Value<String?> source,
  Value<String?> chapterId,
  Value<String?> mangaId,
  Value<String?> imageId,
});

class $$JobTablesTableFilterComposer
    extends Composer<_$AppDatabase, $JobTablesTable> {
  $$JobTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JobTypeEnum, JobTypeEnum, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageId => $composableBuilder(
      column: $table.imageId, builder: (column) => ColumnFilters(column));
}

class $$JobTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $JobTablesTable> {
  $$JobTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageId => $composableBuilder(
      column: $table.imageId, builder: (column) => ColumnOrderings(column));
}

class $$JobTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobTablesTable> {
  $$JobTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobTypeEnum, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);

  GeneratedColumn<String> get imageId =>
      $composableBuilder(column: $table.imageId, builder: (column) => column);
}

class $$JobTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JobTablesTable,
    JobDrift,
    $$JobTablesTableFilterComposer,
    $$JobTablesTableOrderingComposer,
    $$JobTablesTableAnnotationComposer,
    $$JobTablesTableCreateCompanionBuilder,
    $$JobTablesTableUpdateCompanionBuilder,
    (JobDrift, BaseReferences<_$AppDatabase, $JobTablesTable, JobDrift>),
    JobDrift,
    PrefetchHooks Function()> {
  $$JobTablesTableTableManager(_$AppDatabase db, $JobTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<JobTypeEnum> type = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> imageId = const Value.absent(),
          }) =>
              JobTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
            imageId: imageId,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            required JobTypeEnum type,
            Value<String?> source = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> imageId = const Value.absent(),
          }) =>
              JobTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
            imageId: imageId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JobTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JobTablesTable,
    JobDrift,
    $$JobTablesTableFilterComposer,
    $$JobTablesTableOrderingComposer,
    $$JobTablesTableAnnotationComposer,
    $$JobTablesTableCreateCompanionBuilder,
    $$JobTablesTableUpdateCompanionBuilder,
    (JobDrift, BaseReferences<_$AppDatabase, $JobTablesTable, JobDrift>),
    JobDrift,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ImageTablesTableTableManager get imageTables =>
      $$ImageTablesTableTableManager(_db, _db.imageTables);
  $$ChapterTablesTableTableManager get chapterTables =>
      $$ChapterTablesTableTableManager(_db, _db.chapterTables);
  $$LibraryTablesTableTableManager get libraryTables =>
      $$LibraryTablesTableTableManager(_db, _db.libraryTables);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db, _db.mangaTables);
  $$TagTablesTableTableManager get tagTables =>
      $$TagTablesTableTableManager(_db, _db.tagTables);
  $$RelationshipTablesTableTableManager get relationshipTables =>
      $$RelationshipTablesTableTableManager(_db, _db.relationshipTables);
  $$JobTablesTableTableManager get jobTables =>
      $$JobTablesTableTableManager(_db, _db.jobTables);
}
