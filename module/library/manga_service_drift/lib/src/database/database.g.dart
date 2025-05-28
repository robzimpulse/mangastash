// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MangaChapterImageTablesTable extends MangaChapterImageTables
    with TableInfo<$MangaChapterImageTablesTable, ImageDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaChapterImageTablesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'manga_chapter_image_tables';
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
  $MangaChapterImageTablesTable createAlias(String alias) {
    return $MangaChapterImageTablesTable(attachedDatabase, alias);
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

  MangaChapterImageTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaChapterImageTablesCompanion(
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
  ImageDrift copyWithCompanion(MangaChapterImageTablesCompanion data) {
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

class MangaChapterImageTablesCompanion extends UpdateCompanion<ImageDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> order;
  final Value<String> chapterId;
  final Value<String> webUrl;
  final Value<String> id;
  final Value<int> rowid;
  const MangaChapterImageTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.order = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaChapterImageTablesCompanion.insert({
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

  MangaChapterImageTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? order,
      Value<String>? chapterId,
      Value<String>? webUrl,
      Value<String>? id,
      Value<int>? rowid}) {
    return MangaChapterImageTablesCompanion(
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
    return (StringBuffer('MangaChapterImageTablesCompanion(')
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

class $MangaChapterTablesTable extends MangaChapterTables
    with TableInfo<$MangaChapterTablesTable, ChapterDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaChapterTablesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mangaTitleMeta =
      const VerificationMeta('mangaTitle');
  @override
  late final GeneratedColumn<String> mangaTitle = GeneratedColumn<String>(
      'manga_title', aliasedName, true,
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
        mangaTitle,
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
  static const String $name = 'manga_chapter_tables';
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
    if (data.containsKey('manga_title')) {
      context.handle(
          _mangaTitleMeta,
          mangaTitle.isAcceptableOrUnknown(
              data['manga_title']!, _mangaTitleMeta));
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
      mangaTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_title']),
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
  $MangaChapterTablesTable createAlias(String alias) {
    return $MangaChapterTablesTable(attachedDatabase, alias);
  }
}

class ChapterDrift extends DataClass implements Insertable<ChapterDrift> {
  final String createdAt;
  final String updatedAt;
  final String id;
  final String? mangaId;
  final String? mangaTitle;
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
      this.mangaTitle,
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
    if (!nullToAbsent || mangaTitle != null) {
      map['manga_title'] = Variable<String>(mangaTitle);
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

  MangaChapterTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaChapterTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      mangaId: mangaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaId),
      mangaTitle: mangaTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaTitle),
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
      mangaTitle: serializer.fromJson<String?>(json['mangaTitle']),
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
      'mangaTitle': serializer.toJson<String?>(mangaTitle),
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
          Value<String?> mangaTitle = const Value.absent(),
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
        mangaTitle: mangaTitle.present ? mangaTitle.value : this.mangaTitle,
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
  ChapterDrift copyWithCompanion(MangaChapterTablesCompanion data) {
    return ChapterDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      mangaTitle:
          data.mangaTitle.present ? data.mangaTitle.value : this.mangaTitle,
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
          ..write('mangaTitle: $mangaTitle, ')
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
      mangaTitle,
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
          other.mangaTitle == this.mangaTitle &&
          other.title == this.title &&
          other.volume == this.volume &&
          other.chapter == this.chapter &&
          other.translatedLanguage == this.translatedLanguage &&
          other.scanlationGroup == this.scanlationGroup &&
          other.webUrl == this.webUrl &&
          other.readableAt == this.readableAt &&
          other.publishAt == this.publishAt);
}

class MangaChapterTablesCompanion extends UpdateCompanion<ChapterDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> id;
  final Value<String?> mangaId;
  final Value<String?> mangaTitle;
  final Value<String?> title;
  final Value<String?> volume;
  final Value<String?> chapter;
  final Value<String?> translatedLanguage;
  final Value<String?> scanlationGroup;
  final Value<String?> webUrl;
  final Value<String?> readableAt;
  final Value<String?> publishAt;
  final Value<int> rowid;
  const MangaChapterTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.mangaTitle = const Value.absent(),
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
  MangaChapterTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String id,
    this.mangaId = const Value.absent(),
    this.mangaTitle = const Value.absent(),
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
    Expression<String>? mangaTitle,
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
      if (mangaTitle != null) 'manga_title': mangaTitle,
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

  MangaChapterTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? id,
      Value<String?>? mangaId,
      Value<String?>? mangaTitle,
      Value<String?>? title,
      Value<String?>? volume,
      Value<String?>? chapter,
      Value<String?>? translatedLanguage,
      Value<String?>? scanlationGroup,
      Value<String?>? webUrl,
      Value<String?>? readableAt,
      Value<String?>? publishAt,
      Value<int>? rowid}) {
    return MangaChapterTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
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
    if (mangaTitle.present) {
      map['manga_title'] = Variable<String>(mangaTitle.value);
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
    return (StringBuffer('MangaChapterTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('mangaTitle: $mangaTitle, ')
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

class $MangaLibraryTablesTable extends MangaLibraryTables
    with TableInfo<$MangaLibraryTablesTable, MangaLibraryTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaLibraryTablesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'manga_library_tables';
  @override
  VerificationContext validateIntegrity(Insertable<MangaLibraryTable> instance,
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
  MangaLibraryTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaLibraryTable(
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
  $MangaLibraryTablesTable createAlias(String alias) {
    return $MangaLibraryTablesTable(attachedDatabase, alias);
  }
}

class MangaLibraryTable extends DataClass
    implements Insertable<MangaLibraryTable> {
  final String createdAt;
  final String updatedAt;
  final BigInt id;
  final String mangaId;
  const MangaLibraryTable(
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

  MangaLibraryTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaLibraryTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      mangaId: Value(mangaId),
    );
  }

  factory MangaLibraryTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaLibraryTable(
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

  MangaLibraryTable copyWith(
          {String? createdAt,
          String? updatedAt,
          BigInt? id,
          String? mangaId}) =>
      MangaLibraryTable(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
      );
  MangaLibraryTable copyWithCompanion(MangaLibraryTablesCompanion data) {
    return MangaLibraryTable(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaLibraryTable(')
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
      (other is MangaLibraryTable &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.mangaId == this.mangaId);
}

class MangaLibraryTablesCompanion extends UpdateCompanion<MangaLibraryTable> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<BigInt> id;
  final Value<String> mangaId;
  const MangaLibraryTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
  });
  MangaLibraryTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String mangaId,
  }) : mangaId = Value(mangaId);
  static Insertable<MangaLibraryTable> custom({
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

  MangaLibraryTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<BigInt>? id,
      Value<String>? mangaId}) {
    return MangaLibraryTablesCompanion(
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
    return (StringBuffer('MangaLibraryTablesCompanion(')
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

class $MangaTagTablesTable extends MangaTagTables
    with TableInfo<$MangaTagTablesTable, TagDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTagTablesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'manga_tag_tables';
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
  $MangaTagTablesTable createAlias(String alias) {
    return $MangaTagTablesTable(attachedDatabase, alias);
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

  MangaTagTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTagTablesCompanion(
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
  TagDrift copyWithCompanion(MangaTagTablesCompanion data) {
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

class MangaTagTablesCompanion extends UpdateCompanion<TagDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const MangaTagTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTagTablesCompanion.insert({
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

  MangaTagTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<int>? rowid}) {
    return MangaTagTablesCompanion(
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
    return (StringBuffer('MangaTagTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaTagRelationshipTablesTable extends MangaTagRelationshipTables
    with
        TableInfo<$MangaTagRelationshipTablesTable, MangaTagRelationshipTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTagRelationshipTablesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'manga_tag_relationship_tables';
  @override
  VerificationContext validateIntegrity(
      Insertable<MangaTagRelationshipTable> instance,
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
  MangaTagRelationshipTable map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTagRelationshipTable(
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
  $MangaTagRelationshipTablesTable createAlias(String alias) {
    return $MangaTagRelationshipTablesTable(attachedDatabase, alias);
  }
}

class MangaTagRelationshipTable extends DataClass
    implements Insertable<MangaTagRelationshipTable> {
  final String createdAt;
  final String updatedAt;
  final String tagId;
  final String mangaId;
  const MangaTagRelationshipTable(
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

  MangaTagRelationshipTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTagRelationshipTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tagId: Value(tagId),
      mangaId: Value(mangaId),
    );
  }

  factory MangaTagRelationshipTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTagRelationshipTable(
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

  MangaTagRelationshipTable copyWith(
          {String? createdAt,
          String? updatedAt,
          String? tagId,
          String? mangaId}) =>
      MangaTagRelationshipTable(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        tagId: tagId ?? this.tagId,
        mangaId: mangaId ?? this.mangaId,
      );
  MangaTagRelationshipTable copyWithCompanion(
      MangaTagRelationshipTablesCompanion data) {
    return MangaTagRelationshipTable(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagRelationshipTable(')
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
      (other is MangaTagRelationshipTable &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tagId == this.tagId &&
          other.mangaId == this.mangaId);
}

class MangaTagRelationshipTablesCompanion
    extends UpdateCompanion<MangaTagRelationshipTable> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> tagId;
  final Value<String> mangaId;
  final Value<int> rowid;
  const MangaTagRelationshipTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tagId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTagRelationshipTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String tagId,
    required String mangaId,
    this.rowid = const Value.absent(),
  })  : tagId = Value(tagId),
        mangaId = Value(mangaId);
  static Insertable<MangaTagRelationshipTable> custom({
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

  MangaTagRelationshipTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? tagId,
      Value<String>? mangaId,
      Value<int>? rowid}) {
    return MangaTagRelationshipTablesCompanion(
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
    return (StringBuffer('MangaTagRelationshipTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tagId: $tagId, ')
          ..write('mangaId: $mangaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadJobTablesTable extends DownloadJobTables
    with TableInfo<$DownloadJobTablesTable, DownloadJobDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadJobTablesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mangaTitleMeta =
      const VerificationMeta('mangaTitle');
  @override
  late final GeneratedColumn<String> mangaTitle = GeneratedColumn<String>(
      'manga_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mangaCoverUrlMeta =
      const VerificationMeta('mangaCoverUrl');
  @override
  late final GeneratedColumn<String> mangaCoverUrl = GeneratedColumn<String>(
      'manga_cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        updatedAt,
        mangaId,
        mangaTitle,
        mangaCoverUrl,
        chapterId,
        chapterNumber,
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_job_tables';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadJobDrift> instance,
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
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    }
    if (data.containsKey('manga_title')) {
      context.handle(
          _mangaTitleMeta,
          mangaTitle.isAcceptableOrUnknown(
              data['manga_title']!, _mangaTitleMeta));
    }
    if (data.containsKey('manga_cover_url')) {
      context.handle(
          _mangaCoverUrlMeta,
          mangaCoverUrl.isAcceptableOrUnknown(
              data['manga_cover_url']!, _mangaCoverUrlMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {mangaId, mangaTitle, mangaCoverUrl, chapterId, chapterNumber, source};
  @override
  DownloadJobDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadJobDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id']),
      mangaTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_title']),
      mangaCoverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_cover_url']),
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
    );
  }

  @override
  $DownloadJobTablesTable createAlias(String alias) {
    return $DownloadJobTablesTable(attachedDatabase, alias);
  }
}

class DownloadJobDrift extends DataClass
    implements Insertable<DownloadJobDrift> {
  final String createdAt;
  final String updatedAt;
  final String? mangaId;
  final String? mangaTitle;
  final String? mangaCoverUrl;
  final String? chapterId;
  final int? chapterNumber;
  final String? source;
  const DownloadJobDrift(
      {required this.createdAt,
      required this.updatedAt,
      this.mangaId,
      this.mangaTitle,
      this.mangaCoverUrl,
      this.chapterId,
      this.chapterNumber,
      this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || mangaId != null) {
      map['manga_id'] = Variable<String>(mangaId);
    }
    if (!nullToAbsent || mangaTitle != null) {
      map['manga_title'] = Variable<String>(mangaTitle);
    }
    if (!nullToAbsent || mangaCoverUrl != null) {
      map['manga_cover_url'] = Variable<String>(mangaCoverUrl);
    }
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    if (!nullToAbsent || chapterNumber != null) {
      map['chapter_number'] = Variable<int>(chapterNumber);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  DownloadJobTablesCompanion toCompanion(bool nullToAbsent) {
    return DownloadJobTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      mangaId: mangaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaId),
      mangaTitle: mangaTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaTitle),
      mangaCoverUrl: mangaCoverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mangaCoverUrl),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      chapterNumber: chapterNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterNumber),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory DownloadJobDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadJobDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      mangaTitle: serializer.fromJson<String?>(json['mangaTitle']),
      mangaCoverUrl: serializer.fromJson<String?>(json['mangaCoverUrl']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      chapterNumber: serializer.fromJson<int?>(json['chapterNumber']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'mangaId': serializer.toJson<String?>(mangaId),
      'mangaTitle': serializer.toJson<String?>(mangaTitle),
      'mangaCoverUrl': serializer.toJson<String?>(mangaCoverUrl),
      'chapterId': serializer.toJson<String?>(chapterId),
      'chapterNumber': serializer.toJson<int?>(chapterNumber),
      'source': serializer.toJson<String?>(source),
    };
  }

  DownloadJobDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          Value<String?> mangaId = const Value.absent(),
          Value<String?> mangaTitle = const Value.absent(),
          Value<String?> mangaCoverUrl = const Value.absent(),
          Value<String?> chapterId = const Value.absent(),
          Value<int?> chapterNumber = const Value.absent(),
          Value<String?> source = const Value.absent()}) =>
      DownloadJobDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        mangaId: mangaId.present ? mangaId.value : this.mangaId,
        mangaTitle: mangaTitle.present ? mangaTitle.value : this.mangaTitle,
        mangaCoverUrl:
            mangaCoverUrl.present ? mangaCoverUrl.value : this.mangaCoverUrl,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        chapterNumber:
            chapterNumber.present ? chapterNumber.value : this.chapterNumber,
        source: source.present ? source.value : this.source,
      );
  DownloadJobDrift copyWithCompanion(DownloadJobTablesCompanion data) {
    return DownloadJobDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      mangaTitle:
          data.mangaTitle.present ? data.mangaTitle.value : this.mangaTitle,
      mangaCoverUrl: data.mangaCoverUrl.present
          ? data.mangaCoverUrl.value
          : this.mangaCoverUrl,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mangaId: $mangaId, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('mangaCoverUrl: $mangaCoverUrl, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, mangaId, mangaTitle,
      mangaCoverUrl, chapterId, chapterNumber, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadJobDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.mangaId == this.mangaId &&
          other.mangaTitle == this.mangaTitle &&
          other.mangaCoverUrl == this.mangaCoverUrl &&
          other.chapterId == this.chapterId &&
          other.chapterNumber == this.chapterNumber &&
          other.source == this.source);
}

class DownloadJobTablesCompanion extends UpdateCompanion<DownloadJobDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> mangaId;
  final Value<String?> mangaTitle;
  final Value<String?> mangaCoverUrl;
  final Value<String?> chapterId;
  final Value<int?> chapterNumber;
  final Value<String?> source;
  final Value<int> rowid;
  const DownloadJobTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.mangaTitle = const Value.absent(),
    this.mangaCoverUrl = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadJobTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.mangaTitle = const Value.absent(),
    this.mangaCoverUrl = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<DownloadJobDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? mangaId,
    Expression<String>? mangaTitle,
    Expression<String>? mangaCoverUrl,
    Expression<String>? chapterId,
    Expression<int>? chapterNumber,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (mangaId != null) 'manga_id': mangaId,
      if (mangaTitle != null) 'manga_title': mangaTitle,
      if (mangaCoverUrl != null) 'manga_cover_url': mangaCoverUrl,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadJobTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? mangaId,
      Value<String?>? mangaTitle,
      Value<String?>? mangaCoverUrl,
      Value<String?>? chapterId,
      Value<int?>? chapterNumber,
      Value<String?>? source,
      Value<int>? rowid}) {
    return DownloadJobTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mangaId: mangaId ?? this.mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      mangaCoverUrl: mangaCoverUrl ?? this.mangaCoverUrl,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
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
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (mangaTitle.present) {
      map['manga_title'] = Variable<String>(mangaTitle.value);
    }
    if (mangaCoverUrl.present) {
      map['manga_cover_url'] = Variable<String>(mangaCoverUrl.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
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
    return (StringBuffer('DownloadJobTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('mangaId: $mangaId, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('mangaCoverUrl: $mangaCoverUrl, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrefetchJobTablesTable extends PrefetchJobTables
    with TableInfo<$PrefetchJobTablesTable, PrefetchJobDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrefetchJobTablesTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<JobType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JobType>($PrefetchJobTablesTable.$convertertype);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      'manga_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, type, source, chapterId, mangaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prefetch_job_tables';
  @override
  VerificationContext validateIntegrity(Insertable<PrefetchJobDrift> instance,
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
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
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
  PrefetchJobDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrefetchJobDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $PrefetchJobTablesTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
    );
  }

  @override
  $PrefetchJobTablesTable createAlias(String alias) {
    return $PrefetchJobTablesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobType, String, String> $convertertype =
      const EnumNameConverter<JobType>(JobType.values);
}

class PrefetchJobDrift extends DataClass
    implements Insertable<PrefetchJobDrift> {
  final String createdAt;
  final String updatedAt;
  final int id;
  final JobType type;
  final String source;
  final String? chapterId;
  final String mangaId;
  const PrefetchJobDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.type,
      required this.source,
      this.chapterId,
      required this.mangaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<String>($PrefetchJobTablesTable.$convertertype.toSql(type));
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    map['manga_id'] = Variable<String>(mangaId);
    return map;
  }

  PrefetchJobTablesCompanion toCompanion(bool nullToAbsent) {
    return PrefetchJobTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      type: Value(type),
      source: Value(source),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      mangaId: Value(mangaId),
    );
  }

  factory PrefetchJobDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrefetchJobDrift(
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      type: $PrefetchJobTablesTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      source: serializer.fromJson<String>(json['source']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
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
          .toJson<String>($PrefetchJobTablesTable.$convertertype.toJson(type)),
      'source': serializer.toJson<String>(source),
      'chapterId': serializer.toJson<String?>(chapterId),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  PrefetchJobDrift copyWith(
          {String? createdAt,
          String? updatedAt,
          int? id,
          JobType? type,
          String? source,
          Value<String?> chapterId = const Value.absent(),
          String? mangaId}) =>
      PrefetchJobDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        type: type ?? this.type,
        source: source ?? this.source,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        mangaId: mangaId ?? this.mangaId,
      );
  PrefetchJobDrift copyWithCompanion(PrefetchJobTablesCompanion data) {
    return PrefetchJobDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      source: data.source.present ? data.source.value : this.source,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrefetchJobDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(createdAt, updatedAt, id, type, source, chapterId, mangaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrefetchJobDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.type == this.type &&
          other.source == this.source &&
          other.chapterId == this.chapterId &&
          other.mangaId == this.mangaId);
}

class PrefetchJobTablesCompanion extends UpdateCompanion<PrefetchJobDrift> {
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> id;
  final Value<JobType> type;
  final Value<String> source;
  final Value<String?> chapterId;
  final Value<String> mangaId;
  const PrefetchJobTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
  });
  PrefetchJobTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required JobType type,
    required String source,
    this.chapterId = const Value.absent(),
    required String mangaId,
  })  : type = Value(type),
        source = Value(source),
        mangaId = Value(mangaId);
  static Insertable<PrefetchJobDrift> custom({
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? chapterId,
    Expression<String>? mangaId,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (source != null) 'source': source,
      if (chapterId != null) 'chapter_id': chapterId,
      if (mangaId != null) 'manga_id': mangaId,
    });
  }

  PrefetchJobTablesCompanion copyWith(
      {Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? id,
      Value<JobType>? type,
      Value<String>? source,
      Value<String?>? chapterId,
      Value<String>? mangaId}) {
    return PrefetchJobTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      chapterId: chapterId ?? this.chapterId,
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
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $PrefetchJobTablesTable.$convertertype.toSql(type.value));
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrefetchJobTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('source: $source, ')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MangaChapterImageTablesTable mangaChapterImageTables =
      $MangaChapterImageTablesTable(this);
  late final $MangaChapterTablesTable mangaChapterTables =
      $MangaChapterTablesTable(this);
  late final $MangaLibraryTablesTable mangaLibraryTables =
      $MangaLibraryTablesTable(this);
  late final $MangaTablesTable mangaTables = $MangaTablesTable(this);
  late final $MangaTagTablesTable mangaTagTables = $MangaTagTablesTable(this);
  late final $MangaTagRelationshipTablesTable mangaTagRelationshipTables =
      $MangaTagRelationshipTablesTable(this);
  late final $DownloadJobTablesTable downloadJobTables =
      $DownloadJobTablesTable(this);
  late final $PrefetchJobTablesTable prefetchJobTables =
      $PrefetchJobTablesTable(this);
  late final MangaDao mangaDao = MangaDao(this as AppDatabase);
  late final ChapterDao chapterDao = ChapterDao(this as AppDatabase);
  late final LibraryDao libraryDao = LibraryDao(this as AppDatabase);
  late final DownloadJobDao downloadJobDao =
      DownloadJobDao(this as AppDatabase);
  late final PrefetchJobDao prefetchJobDao =
      PrefetchJobDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mangaChapterImageTables,
        mangaChapterTables,
        mangaLibraryTables,
        mangaTables,
        mangaTagTables,
        mangaTagRelationshipTables,
        downloadJobTables,
        prefetchJobTables
      ];
}

typedef $$MangaChapterImageTablesTableCreateCompanionBuilder
    = MangaChapterImageTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required int order,
  required String chapterId,
  required String webUrl,
  required String id,
  Value<int> rowid,
});
typedef $$MangaChapterImageTablesTableUpdateCompanionBuilder
    = MangaChapterImageTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> order,
  Value<String> chapterId,
  Value<String> webUrl,
  Value<String> id,
  Value<int> rowid,
});

class $$MangaChapterImageTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaChapterImageTablesTable> {
  $$MangaChapterImageTablesTableFilterComposer({
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

class $$MangaChapterImageTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaChapterImageTablesTable> {
  $$MangaChapterImageTablesTableOrderingComposer({
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

class $$MangaChapterImageTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaChapterImageTablesTable> {
  $$MangaChapterImageTablesTableAnnotationComposer({
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

class $$MangaChapterImageTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaChapterImageTablesTable,
    ImageDrift,
    $$MangaChapterImageTablesTableFilterComposer,
    $$MangaChapterImageTablesTableOrderingComposer,
    $$MangaChapterImageTablesTableAnnotationComposer,
    $$MangaChapterImageTablesTableCreateCompanionBuilder,
    $$MangaChapterImageTablesTableUpdateCompanionBuilder,
    (
      ImageDrift,
      BaseReferences<_$AppDatabase, $MangaChapterImageTablesTable, ImageDrift>
    ),
    ImageDrift,
    PrefetchHooks Function()> {
  $$MangaChapterImageTablesTableTableManager(
      _$AppDatabase db, $MangaChapterImageTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaChapterImageTablesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaChapterImageTablesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaChapterImageTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> webUrl = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaChapterImageTablesCompanion(
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
              MangaChapterImageTablesCompanion.insert(
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

typedef $$MangaChapterImageTablesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MangaChapterImageTablesTable,
        ImageDrift,
        $$MangaChapterImageTablesTableFilterComposer,
        $$MangaChapterImageTablesTableOrderingComposer,
        $$MangaChapterImageTablesTableAnnotationComposer,
        $$MangaChapterImageTablesTableCreateCompanionBuilder,
        $$MangaChapterImageTablesTableUpdateCompanionBuilder,
        (
          ImageDrift,
          BaseReferences<_$AppDatabase, $MangaChapterImageTablesTable,
              ImageDrift>
        ),
        ImageDrift,
        PrefetchHooks Function()>;
typedef $$MangaChapterTablesTableCreateCompanionBuilder
    = MangaChapterTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String id,
  Value<String?> mangaId,
  Value<String?> mangaTitle,
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
typedef $$MangaChapterTablesTableUpdateCompanionBuilder
    = MangaChapterTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> id,
  Value<String?> mangaId,
  Value<String?> mangaTitle,
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

class $$MangaChapterTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaChapterTablesTable> {
  $$MangaChapterTablesTableFilterComposer({
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

  ColumnFilters<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => ColumnFilters(column));

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

class $$MangaChapterTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaChapterTablesTable> {
  $$MangaChapterTablesTableOrderingComposer({
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

  ColumnOrderings<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => ColumnOrderings(column));

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

class $$MangaChapterTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaChapterTablesTable> {
  $$MangaChapterTablesTableAnnotationComposer({
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

  GeneratedColumn<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => column);

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

class $$MangaChapterTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaChapterTablesTable,
    ChapterDrift,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (
      ChapterDrift,
      BaseReferences<_$AppDatabase, $MangaChapterTablesTable, ChapterDrift>
    ),
    ChapterDrift,
    PrefetchHooks Function()> {
  $$MangaChapterTablesTableTableManager(
      _$AppDatabase db, $MangaChapterTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaChapterTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaChapterTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaChapterTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> mangaTitle = const Value.absent(),
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
              MangaChapterTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
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
            Value<String?> mangaTitle = const Value.absent(),
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
              MangaChapterTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
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

typedef $$MangaChapterTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaChapterTablesTable,
    ChapterDrift,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (
      ChapterDrift,
      BaseReferences<_$AppDatabase, $MangaChapterTablesTable, ChapterDrift>
    ),
    ChapterDrift,
    PrefetchHooks Function()>;
typedef $$MangaLibraryTablesTableCreateCompanionBuilder
    = MangaLibraryTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<BigInt> id,
  required String mangaId,
});
typedef $$MangaLibraryTablesTableUpdateCompanionBuilder
    = MangaLibraryTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<BigInt> id,
  Value<String> mangaId,
});

class $$MangaLibraryTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaLibraryTablesTable> {
  $$MangaLibraryTablesTableFilterComposer({
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

class $$MangaLibraryTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaLibraryTablesTable> {
  $$MangaLibraryTablesTableOrderingComposer({
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

class $$MangaLibraryTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaLibraryTablesTable> {
  $$MangaLibraryTablesTableAnnotationComposer({
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

class $$MangaLibraryTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaLibraryTablesTable,
    MangaLibraryTable,
    $$MangaLibraryTablesTableFilterComposer,
    $$MangaLibraryTablesTableOrderingComposer,
    $$MangaLibraryTablesTableAnnotationComposer,
    $$MangaLibraryTablesTableCreateCompanionBuilder,
    $$MangaLibraryTablesTableUpdateCompanionBuilder,
    (
      MangaLibraryTable,
      BaseReferences<_$AppDatabase, $MangaLibraryTablesTable, MangaLibraryTable>
    ),
    MangaLibraryTable,
    PrefetchHooks Function()> {
  $$MangaLibraryTablesTableTableManager(
      _$AppDatabase db, $MangaLibraryTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaLibraryTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaLibraryTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaLibraryTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<BigInt> id = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
          }) =>
              MangaLibraryTablesCompanion(
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
              MangaLibraryTablesCompanion.insert(
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

typedef $$MangaLibraryTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaLibraryTablesTable,
    MangaLibraryTable,
    $$MangaLibraryTablesTableFilterComposer,
    $$MangaLibraryTablesTableOrderingComposer,
    $$MangaLibraryTablesTableAnnotationComposer,
    $$MangaLibraryTablesTableCreateCompanionBuilder,
    $$MangaLibraryTablesTableUpdateCompanionBuilder,
    (
      MangaLibraryTable,
      BaseReferences<_$AppDatabase, $MangaLibraryTablesTable, MangaLibraryTable>
    ),
    MangaLibraryTable,
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
typedef $$MangaTagTablesTableCreateCompanionBuilder = MangaTagTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$MangaTagTablesTableUpdateCompanionBuilder = MangaTagTablesCompanion
    Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$MangaTagTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTagTablesTable> {
  $$MangaTagTablesTableFilterComposer({
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

class $$MangaTagTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaTagTablesTable> {
  $$MangaTagTablesTableOrderingComposer({
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

class $$MangaTagTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaTagTablesTable> {
  $$MangaTagTablesTableAnnotationComposer({
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

class $$MangaTagTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaTagTablesTable,
    TagDrift,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (TagDrift, BaseReferences<_$AppDatabase, $MangaTagTablesTable, TagDrift>),
    TagDrift,
    PrefetchHooks Function()> {
  $$MangaTagTablesTableTableManager(
      _$AppDatabase db, $MangaTagTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaTagTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaTagTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaTagTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagTablesCompanion(
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
              MangaTagTablesCompanion.insert(
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

typedef $$MangaTagTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaTagTablesTable,
    TagDrift,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (TagDrift, BaseReferences<_$AppDatabase, $MangaTagTablesTable, TagDrift>),
    TagDrift,
    PrefetchHooks Function()>;
typedef $$MangaTagRelationshipTablesTableCreateCompanionBuilder
    = MangaTagRelationshipTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  required String tagId,
  required String mangaId,
  Value<int> rowid,
});
typedef $$MangaTagRelationshipTablesTableUpdateCompanionBuilder
    = MangaTagRelationshipTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> tagId,
  Value<String> mangaId,
  Value<int> rowid,
});

class $$MangaTagRelationshipTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTagRelationshipTablesTable> {
  $$MangaTagRelationshipTablesTableFilterComposer({
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

class $$MangaTagRelationshipTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaTagRelationshipTablesTable> {
  $$MangaTagRelationshipTablesTableOrderingComposer({
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

class $$MangaTagRelationshipTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaTagRelationshipTablesTable> {
  $$MangaTagRelationshipTablesTableAnnotationComposer({
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

class $$MangaTagRelationshipTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaTagRelationshipTablesTable,
    MangaTagRelationshipTable,
    $$MangaTagRelationshipTablesTableFilterComposer,
    $$MangaTagRelationshipTablesTableOrderingComposer,
    $$MangaTagRelationshipTablesTableAnnotationComposer,
    $$MangaTagRelationshipTablesTableCreateCompanionBuilder,
    $$MangaTagRelationshipTablesTableUpdateCompanionBuilder,
    (
      MangaTagRelationshipTable,
      BaseReferences<_$AppDatabase, $MangaTagRelationshipTablesTable,
          MangaTagRelationshipTable>
    ),
    MangaTagRelationshipTable,
    PrefetchHooks Function()> {
  $$MangaTagRelationshipTablesTableTableManager(
      _$AppDatabase db, $MangaTagRelationshipTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaTagRelationshipTablesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaTagRelationshipTablesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaTagRelationshipTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagRelationshipTablesCompanion(
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
              MangaTagRelationshipTablesCompanion.insert(
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

typedef $$MangaTagRelationshipTablesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MangaTagRelationshipTablesTable,
        MangaTagRelationshipTable,
        $$MangaTagRelationshipTablesTableFilterComposer,
        $$MangaTagRelationshipTablesTableOrderingComposer,
        $$MangaTagRelationshipTablesTableAnnotationComposer,
        $$MangaTagRelationshipTablesTableCreateCompanionBuilder,
        $$MangaTagRelationshipTablesTableUpdateCompanionBuilder,
        (
          MangaTagRelationshipTable,
          BaseReferences<_$AppDatabase, $MangaTagRelationshipTablesTable,
              MangaTagRelationshipTable>
        ),
        MangaTagRelationshipTable,
        PrefetchHooks Function()>;
typedef $$DownloadJobTablesTableCreateCompanionBuilder
    = DownloadJobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> mangaId,
  Value<String?> mangaTitle,
  Value<String?> mangaCoverUrl,
  Value<String?> chapterId,
  Value<int?> chapterNumber,
  Value<String?> source,
  Value<int> rowid,
});
typedef $$DownloadJobTablesTableUpdateCompanionBuilder
    = DownloadJobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> mangaId,
  Value<String?> mangaTitle,
  Value<String?> mangaCoverUrl,
  Value<String?> chapterId,
  Value<int?> chapterNumber,
  Value<String?> source,
  Value<int> rowid,
});

class $$DownloadJobTablesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadJobTablesTable> {
  $$DownloadJobTablesTableFilterComposer({
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

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaCoverUrl => $composableBuilder(
      column: $table.mangaCoverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$DownloadJobTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadJobTablesTable> {
  $$DownloadJobTablesTableOrderingComposer({
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

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaCoverUrl => $composableBuilder(
      column: $table.mangaCoverUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$DownloadJobTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadJobTablesTable> {
  $$DownloadJobTablesTableAnnotationComposer({
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

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);

  GeneratedColumn<String> get mangaTitle => $composableBuilder(
      column: $table.mangaTitle, builder: (column) => column);

  GeneratedColumn<String> get mangaCoverUrl => $composableBuilder(
      column: $table.mangaCoverUrl, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$DownloadJobTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadJobTablesTable,
    DownloadJobDrift,
    $$DownloadJobTablesTableFilterComposer,
    $$DownloadJobTablesTableOrderingComposer,
    $$DownloadJobTablesTableAnnotationComposer,
    $$DownloadJobTablesTableCreateCompanionBuilder,
    $$DownloadJobTablesTableUpdateCompanionBuilder,
    (
      DownloadJobDrift,
      BaseReferences<_$AppDatabase, $DownloadJobTablesTable, DownloadJobDrift>
    ),
    DownloadJobDrift,
    PrefetchHooks Function()> {
  $$DownloadJobTablesTableTableManager(
      _$AppDatabase db, $DownloadJobTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadJobTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadJobTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadJobTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> mangaTitle = const Value.absent(),
            Value<String?> mangaCoverUrl = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<int?> chapterNumber = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadJobTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
            mangaCoverUrl: mangaCoverUrl,
            chapterId: chapterId,
            chapterNumber: chapterNumber,
            source: source,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> mangaTitle = const Value.absent(),
            Value<String?> mangaCoverUrl = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<int?> chapterNumber = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadJobTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            mangaId: mangaId,
            mangaTitle: mangaTitle,
            mangaCoverUrl: mangaCoverUrl,
            chapterId: chapterId,
            chapterNumber: chapterNumber,
            source: source,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadJobTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadJobTablesTable,
    DownloadJobDrift,
    $$DownloadJobTablesTableFilterComposer,
    $$DownloadJobTablesTableOrderingComposer,
    $$DownloadJobTablesTableAnnotationComposer,
    $$DownloadJobTablesTableCreateCompanionBuilder,
    $$DownloadJobTablesTableUpdateCompanionBuilder,
    (
      DownloadJobDrift,
      BaseReferences<_$AppDatabase, $DownloadJobTablesTable, DownloadJobDrift>
    ),
    DownloadJobDrift,
    PrefetchHooks Function()>;
typedef $$PrefetchJobTablesTableCreateCompanionBuilder
    = PrefetchJobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> id,
  required JobType type,
  required String source,
  Value<String?> chapterId,
  required String mangaId,
});
typedef $$PrefetchJobTablesTableUpdateCompanionBuilder
    = PrefetchJobTablesCompanion Function({
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> id,
  Value<JobType> type,
  Value<String> source,
  Value<String?> chapterId,
  Value<String> mangaId,
});

class $$PrefetchJobTablesTableFilterComposer
    extends Composer<_$AppDatabase, $PrefetchJobTablesTable> {
  $$PrefetchJobTablesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<JobType, JobType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));
}

class $$PrefetchJobTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrefetchJobTablesTable> {
  $$PrefetchJobTablesTableOrderingComposer({
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
}

class $$PrefetchJobTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrefetchJobTablesTable> {
  $$PrefetchJobTablesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<JobType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);
}

class $$PrefetchJobTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrefetchJobTablesTable,
    PrefetchJobDrift,
    $$PrefetchJobTablesTableFilterComposer,
    $$PrefetchJobTablesTableOrderingComposer,
    $$PrefetchJobTablesTableAnnotationComposer,
    $$PrefetchJobTablesTableCreateCompanionBuilder,
    $$PrefetchJobTablesTableUpdateCompanionBuilder,
    (
      PrefetchJobDrift,
      BaseReferences<_$AppDatabase, $PrefetchJobTablesTable, PrefetchJobDrift>
    ),
    PrefetchJobDrift,
    PrefetchHooks Function()> {
  $$PrefetchJobTablesTableTableManager(
      _$AppDatabase db, $PrefetchJobTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrefetchJobTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrefetchJobTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrefetchJobTablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<JobType> type = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
          }) =>
              PrefetchJobTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
          ),
          createCompanionCallback: ({
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            required JobType type,
            required String source,
            Value<String?> chapterId = const Value.absent(),
            required String mangaId,
          }) =>
              PrefetchJobTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrefetchJobTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrefetchJobTablesTable,
    PrefetchJobDrift,
    $$PrefetchJobTablesTableFilterComposer,
    $$PrefetchJobTablesTableOrderingComposer,
    $$PrefetchJobTablesTableAnnotationComposer,
    $$PrefetchJobTablesTableCreateCompanionBuilder,
    $$PrefetchJobTablesTableUpdateCompanionBuilder,
    (
      PrefetchJobDrift,
      BaseReferences<_$AppDatabase, $PrefetchJobTablesTable, PrefetchJobDrift>
    ),
    PrefetchJobDrift,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MangaChapterImageTablesTableTableManager get mangaChapterImageTables =>
      $$MangaChapterImageTablesTableTableManager(
          _db, _db.mangaChapterImageTables);
  $$MangaChapterTablesTableTableManager get mangaChapterTables =>
      $$MangaChapterTablesTableTableManager(_db, _db.mangaChapterTables);
  $$MangaLibraryTablesTableTableManager get mangaLibraryTables =>
      $$MangaLibraryTablesTableTableManager(_db, _db.mangaLibraryTables);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db, _db.mangaTables);
  $$MangaTagTablesTableTableManager get mangaTagTables =>
      $$MangaTagTablesTableTableManager(_db, _db.mangaTagTables);
  $$MangaTagRelationshipTablesTableTableManager
      get mangaTagRelationshipTables =>
          $$MangaTagRelationshipTablesTableTableManager(
              _db, _db.mangaTagRelationshipTables);
  $$DownloadJobTablesTableTableManager get downloadJobTables =>
      $$DownloadJobTablesTableTableManager(_db, _db.downloadJobTables);
  $$PrefetchJobTablesTableTableManager get prefetchJobTables =>
      $$PrefetchJobTablesTableTableManager(_db, _db.prefetchJobTables);
}
