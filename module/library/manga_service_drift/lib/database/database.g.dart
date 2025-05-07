// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MangaChapterImageTablesTable extends MangaChapterImageTables
    with TableInfo<$MangaChapterImageTablesTable, MangaChapterImageTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaChapterImageTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<BigInt> id = GeneratedColumn<BigInt>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.bigInt,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _webUrlMeta = const VerificationMeta('webUrl');
  @override
  late final GeneratedColumn<String> webUrl = GeneratedColumn<String>(
      'webUrl', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [id, chapterId, webUrl, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_chapter_image_tables';
  @override
  VerificationContext validateIntegrity(
      Insertable<MangaChapterImageTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    }
    if (data.containsKey('webUrl')) {
      context.handle(_webUrlMeta,
          webUrl.isAcceptableOrUnknown(data['webUrl']!, _webUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaChapterImageTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaChapterImageTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      webUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}webUrl']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MangaChapterImageTablesTable createAlias(String alias) {
    return $MangaChapterImageTablesTable(attachedDatabase, alias);
  }
}

class MangaChapterImageTable extends DataClass
    implements Insertable<MangaChapterImageTable> {
  final BigInt id;
  final String? chapterId;
  final String? webUrl;
  final String createdAt;
  const MangaChapterImageTable(
      {required this.id, this.chapterId, this.webUrl, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<BigInt>(id);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    if (!nullToAbsent || webUrl != null) {
      map['webUrl'] = Variable<String>(webUrl);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MangaChapterImageTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaChapterImageTablesCompanion(
      id: Value(id),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      webUrl:
          webUrl == null && nullToAbsent ? const Value.absent() : Value(webUrl),
      createdAt: Value(createdAt),
    );
  }

  factory MangaChapterImageTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaChapterImageTable(
      id: serializer.fromJson<BigInt>(json['id']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<BigInt>(id),
      'chapterId': serializer.toJson<String?>(chapterId),
      'webUrl': serializer.toJson<String?>(webUrl),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MangaChapterImageTable copyWith(
          {BigInt? id,
          Value<String?> chapterId = const Value.absent(),
          Value<String?> webUrl = const Value.absent(),
          String? createdAt}) =>
      MangaChapterImageTable(
        id: id ?? this.id,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        webUrl: webUrl.present ? webUrl.value : this.webUrl,
        createdAt: createdAt ?? this.createdAt,
      );
  MangaChapterImageTable copyWithCompanion(
      MangaChapterImageTablesCompanion data) {
    return MangaChapterImageTable(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaChapterImageTable(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, webUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaChapterImageTable &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.webUrl == this.webUrl &&
          other.createdAt == this.createdAt);
}

class MangaChapterImageTablesCompanion
    extends UpdateCompanion<MangaChapterImageTable> {
  final Value<BigInt> id;
  final Value<String?> chapterId;
  final Value<String?> webUrl;
  final Value<String> createdAt;
  const MangaChapterImageTablesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MangaChapterImageTablesCompanion.insert({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<MangaChapterImageTable> custom({
    Expression<BigInt>? id,
    Expression<String>? chapterId,
    Expression<String>? webUrl,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (webUrl != null) 'webUrl': webUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MangaChapterImageTablesCompanion copyWith(
      {Value<BigInt>? id,
      Value<String?>? chapterId,
      Value<String?>? webUrl,
      Value<String>? createdAt}) {
    return MangaChapterImageTablesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      webUrl: webUrl ?? this.webUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<BigInt>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (webUrl.present) {
      map['webUrl'] = Variable<String>(webUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaChapterImageTablesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('webUrl: $webUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MangaChapterTablesTable extends MangaChapterTables
    with TableInfo<$MangaChapterTablesTable, MangaChapterTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaChapterTablesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [
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
        publishAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_chapter_tables';
  @override
  VerificationContext validateIntegrity(Insertable<MangaChapterTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaChapterTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaChapterTable(
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
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MangaChapterTablesTable createAlias(String alias) {
    return $MangaChapterTablesTable(attachedDatabase, alias);
  }
}

class MangaChapterTable extends DataClass
    implements Insertable<MangaChapterTable> {
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
  final String createdAt;
  const MangaChapterTable(
      {required this.id,
      this.mangaId,
      this.mangaTitle,
      this.title,
      this.volume,
      this.chapter,
      this.translatedLanguage,
      this.scanlationGroup,
      this.webUrl,
      this.readableAt,
      this.publishAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MangaChapterTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaChapterTablesCompanion(
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
      createdAt: Value(createdAt),
    );
  }

  factory MangaChapterTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaChapterTable(
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
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
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
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MangaChapterTable copyWith(
          {String? id,
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
          String? createdAt}) =>
      MangaChapterTable(
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
        createdAt: createdAt ?? this.createdAt,
      );
  MangaChapterTable copyWithCompanion(MangaChapterTablesCompanion data) {
    return MangaChapterTable(
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
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaChapterTable(')
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      publishAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaChapterTable &&
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
          other.publishAt == this.publishAt &&
          other.createdAt == this.createdAt);
}

class MangaChapterTablesCompanion extends UpdateCompanion<MangaChapterTable> {
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
  final Value<String> createdAt;
  final Value<int> rowid;
  const MangaChapterTablesCompanion({
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
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaChapterTablesCompanion.insert({
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
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<MangaChapterTable> custom({
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
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
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
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaChapterTablesCompanion copyWith(
      {Value<String>? id,
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
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return MangaChapterTablesCompanion(
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
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaChapterTablesCompanion(')
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
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaTablesTable extends MangaTables
    with TableInfo<$MangaTablesTable, MangaTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTablesTable(this.attachedDatabase, [this._alias]);
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
      'webUrl', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        coverUrl,
        author,
        status,
        description,
        webUrl,
        source,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_tables';
  @override
  VerificationContext validateIntegrity(Insertable<MangaTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('webUrl')) {
      context.handle(_webUrlMeta,
          webUrl.isAcceptableOrUnknown(data['webUrl']!, _webUrlMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTable(
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
          .read(DriftSqlType.string, data['${effectivePrefix}webUrl']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MangaTablesTable createAlias(String alias) {
    return $MangaTablesTable(attachedDatabase, alias);
  }
}

class MangaTable extends DataClass implements Insertable<MangaTable> {
  final String id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final String createdAt;
  final String updatedAt;
  const MangaTable(
      {required this.id,
      this.title,
      this.coverUrl,
      this.author,
      this.status,
      this.description,
      this.webUrl,
      this.source,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
      map['webUrl'] = Variable<String>(webUrl);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  MangaTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTablesCompanion(
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
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MangaTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTable(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      author: serializer.fromJson<String?>(json['author']),
      status: serializer.fromJson<String?>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      source: serializer.fromJson<String?>(json['source']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'author': serializer.toJson<String?>(author),
      'status': serializer.toJson<String?>(status),
      'description': serializer.toJson<String?>(description),
      'webUrl': serializer.toJson<String?>(webUrl),
      'source': serializer.toJson<String?>(source),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  MangaTable copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          Value<String?> coverUrl = const Value.absent(),
          Value<String?> author = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> webUrl = const Value.absent(),
          Value<String?> source = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      MangaTable(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        author: author.present ? author.value : this.author,
        status: status.present ? status.value : this.status,
        description: description.present ? description.value : this.description,
        webUrl: webUrl.present ? webUrl.value : this.webUrl,
        source: source.present ? source.value : this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MangaTable copyWithCompanion(MangaTablesCompanion data) {
    return MangaTable(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      author: data.author.present ? data.author.value : this.author,
      status: data.status.present ? data.status.value : this.status,
      description:
          data.description.present ? data.description.value : this.description,
      webUrl: data.webUrl.present ? data.webUrl.value : this.webUrl,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTable(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('webUrl: $webUrl, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, coverUrl, author, status,
      description, webUrl, source, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTable &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.author == this.author &&
          other.status == this.status &&
          other.description == this.description &&
          other.webUrl == this.webUrl &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MangaTablesCompanion extends UpdateCompanion<MangaTable> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> coverUrl;
  final Value<String?> author;
  final Value<String?> status;
  final Value<String?> description;
  final Value<String?> webUrl;
  final Value<String?> source;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const MangaTablesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTablesCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.author = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.webUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<MangaTable> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<String>? author,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? webUrl,
    Expression<String>? source,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (author != null) 'author': author,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (webUrl != null) 'webUrl': webUrl,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTablesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<String?>? coverUrl,
      Value<String?>? author,
      Value<String?>? status,
      Value<String?>? description,
      Value<String?>? webUrl,
      Value<String?>? source,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return MangaTablesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      webUrl: webUrl ?? this.webUrl,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
      map['webUrl'] = Variable<String>(webUrl.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTablesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('author: $author, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('webUrl: $webUrl, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES manga_tables (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [id, mangaId, createdAt];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaLibraryTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaLibraryTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MangaLibraryTablesTable createAlias(String alias) {
    return $MangaLibraryTablesTable(attachedDatabase, alias);
  }
}

class MangaLibraryTable extends DataClass
    implements Insertable<MangaLibraryTable> {
  final BigInt id;
  final String mangaId;
  final String createdAt;
  const MangaLibraryTable(
      {required this.id, required this.mangaId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<BigInt>(id);
    map['manga_id'] = Variable<String>(mangaId);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MangaLibraryTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaLibraryTablesCompanion(
      id: Value(id),
      mangaId: Value(mangaId),
      createdAt: Value(createdAt),
    );
  }

  factory MangaLibraryTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaLibraryTable(
      id: serializer.fromJson<BigInt>(json['id']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<BigInt>(id),
      'mangaId': serializer.toJson<String>(mangaId),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MangaLibraryTable copyWith(
          {BigInt? id, String? mangaId, String? createdAt}) =>
      MangaLibraryTable(
        id: id ?? this.id,
        mangaId: mangaId ?? this.mangaId,
        createdAt: createdAt ?? this.createdAt,
      );
  MangaLibraryTable copyWithCompanion(MangaLibraryTablesCompanion data) {
    return MangaLibraryTable(
      id: data.id.present ? data.id.value : this.id,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaLibraryTable(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mangaId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaLibraryTable &&
          other.id == this.id &&
          other.mangaId == this.mangaId &&
          other.createdAt == this.createdAt);
}

class MangaLibraryTablesCompanion extends UpdateCompanion<MangaLibraryTable> {
  final Value<BigInt> id;
  final Value<String> mangaId;
  final Value<String> createdAt;
  const MangaLibraryTablesCompanion({
    this.id = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MangaLibraryTablesCompanion.insert({
    this.id = const Value.absent(),
    required String mangaId,
    this.createdAt = const Value.absent(),
  }) : mangaId = Value(mangaId);
  static Insertable<MangaLibraryTable> custom({
    Expression<BigInt>? id,
    Expression<String>? mangaId,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaId != null) 'manga_id': mangaId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MangaLibraryTablesCompanion copyWith(
      {Value<BigInt>? id, Value<String>? mangaId, Value<String>? createdAt}) {
    return MangaLibraryTablesCompanion(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<BigInt>(id.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaLibraryTablesCompanion(')
          ..write('id: $id, ')
          ..write('mangaId: $mangaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MangaTagTablesTable extends MangaTagTables
    with TableInfo<$MangaTagTablesTable, MangaTagTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTagTablesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_tag_tables';
  @override
  VerificationContext validateIntegrity(Insertable<MangaTagTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaTagTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTagTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MangaTagTablesTable createAlias(String alias) {
    return $MangaTagTablesTable(attachedDatabase, alias);
  }
}

class MangaTagTable extends DataClass implements Insertable<MangaTagTable> {
  final String id;
  final String name;
  final String createdAt;
  const MangaTagTable(
      {required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MangaTagTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTagTablesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory MangaTagTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTagTable(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MangaTagTable copyWith({String? id, String? name, String? createdAt}) =>
      MangaTagTable(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  MangaTagTable copyWithCompanion(MangaTagTablesCompanion data) {
    return MangaTagTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTagTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class MangaTagTablesCompanion extends UpdateCompanion<MangaTagTable> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> createdAt;
  final Value<int> rowid;
  const MangaTagTablesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTagTablesCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<MangaTagTable> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTagTablesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return MangaTagTablesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagTablesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [tagId, mangaId, createdAt];
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MangaTagRelationshipTable map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTagRelationshipTable(
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      mangaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manga_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MangaTagRelationshipTablesTable createAlias(String alias) {
    return $MangaTagRelationshipTablesTable(attachedDatabase, alias);
  }
}

class MangaTagRelationshipTable extends DataClass
    implements Insertable<MangaTagRelationshipTable> {
  final String tagId;
  final String mangaId;
  final String createdAt;
  const MangaTagRelationshipTable(
      {required this.tagId, required this.mangaId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag_id'] = Variable<String>(tagId);
    map['manga_id'] = Variable<String>(mangaId);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  MangaTagRelationshipTablesCompanion toCompanion(bool nullToAbsent) {
    return MangaTagRelationshipTablesCompanion(
      tagId: Value(tagId),
      mangaId: Value(mangaId),
      createdAt: Value(createdAt),
    );
  }

  factory MangaTagRelationshipTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTagRelationshipTable(
      tagId: serializer.fromJson<String>(json['tagId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tagId': serializer.toJson<String>(tagId),
      'mangaId': serializer.toJson<String>(mangaId),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  MangaTagRelationshipTable copyWith(
          {String? tagId, String? mangaId, String? createdAt}) =>
      MangaTagRelationshipTable(
        tagId: tagId ?? this.tagId,
        mangaId: mangaId ?? this.mangaId,
        createdAt: createdAt ?? this.createdAt,
      );
  MangaTagRelationshipTable copyWithCompanion(
      MangaTagRelationshipTablesCompanion data) {
    return MangaTagRelationshipTable(
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagRelationshipTable(')
          ..write('tagId: $tagId, ')
          ..write('mangaId: $mangaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tagId, mangaId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTagRelationshipTable &&
          other.tagId == this.tagId &&
          other.mangaId == this.mangaId &&
          other.createdAt == this.createdAt);
}

class MangaTagRelationshipTablesCompanion
    extends UpdateCompanion<MangaTagRelationshipTable> {
  final Value<String> tagId;
  final Value<String> mangaId;
  final Value<String> createdAt;
  final Value<int> rowid;
  const MangaTagRelationshipTablesCompanion({
    this.tagId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTagRelationshipTablesCompanion.insert({
    required String tagId,
    required String mangaId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : tagId = Value(tagId),
        mangaId = Value(mangaId);
  static Insertable<MangaTagRelationshipTable> custom({
    Expression<String>? tagId,
    Expression<String>? mangaId,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tagId != null) 'tag_id': tagId,
      if (mangaId != null) 'manga_id': mangaId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTagRelationshipTablesCompanion copyWith(
      {Value<String>? tagId,
      Value<String>? mangaId,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return MangaTagRelationshipTablesCompanion(
      tagId: tagId ?? this.tagId,
      mangaId: mangaId ?? this.mangaId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagRelationshipTablesCompanion(')
          ..write('tagId: $tagId, ')
          ..write('mangaId: $mangaId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  late final $MangaTablesTable mangaTables = $MangaTablesTable(this);
  late final $MangaLibraryTablesTable mangaLibraryTables =
      $MangaLibraryTablesTable(this);
  late final $MangaTagTablesTable mangaTagTables = $MangaTagTablesTable(this);
  late final $MangaTagRelationshipTablesTable mangaTagRelationshipTables =
      $MangaTagRelationshipTablesTable(this);
  late final MangaDao mangaDao = MangaDao(this as AppDatabase);
  late final MangaTagDao mangaTagDao = MangaTagDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mangaChapterImageTables,
        mangaChapterTables,
        mangaTables,
        mangaLibraryTables,
        mangaTagTables,
        mangaTagRelationshipTables
      ];
}

typedef $$MangaChapterImageTablesTableCreateCompanionBuilder
    = MangaChapterImageTablesCompanion Function({
  Value<BigInt> id,
  Value<String?> chapterId,
  Value<String?> webUrl,
  Value<String> createdAt,
});
typedef $$MangaChapterImageTablesTableUpdateCompanionBuilder
    = MangaChapterImageTablesCompanion Function({
  Value<BigInt> id,
  Value<String?> chapterId,
  Value<String?> webUrl,
  Value<String> createdAt,
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
  ColumnFilters<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<BigInt> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MangaChapterImageTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaChapterImageTablesTable,
    MangaChapterImageTable,
    $$MangaChapterImageTablesTableFilterComposer,
    $$MangaChapterImageTablesTableOrderingComposer,
    $$MangaChapterImageTablesTableAnnotationComposer,
    $$MangaChapterImageTablesTableCreateCompanionBuilder,
    $$MangaChapterImageTablesTableUpdateCompanionBuilder,
    (
      MangaChapterImageTable,
      BaseReferences<_$AppDatabase, $MangaChapterImageTablesTable,
          MangaChapterImageTable>
    ),
    MangaChapterImageTable,
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
            Value<BigInt> id = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              MangaChapterImageTablesCompanion(
            id: id,
            chapterId: chapterId,
            webUrl: webUrl,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<BigInt> id = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              MangaChapterImageTablesCompanion.insert(
            id: id,
            chapterId: chapterId,
            webUrl: webUrl,
            createdAt: createdAt,
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
        MangaChapterImageTable,
        $$MangaChapterImageTablesTableFilterComposer,
        $$MangaChapterImageTablesTableOrderingComposer,
        $$MangaChapterImageTablesTableAnnotationComposer,
        $$MangaChapterImageTablesTableCreateCompanionBuilder,
        $$MangaChapterImageTablesTableUpdateCompanionBuilder,
        (
          MangaChapterImageTable,
          BaseReferences<_$AppDatabase, $MangaChapterImageTablesTable,
              MangaChapterImageTable>
        ),
        MangaChapterImageTable,
        PrefetchHooks Function()>;
typedef $$MangaChapterTablesTableCreateCompanionBuilder
    = MangaChapterTablesCompanion Function({
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
  Value<String> createdAt,
  Value<int> rowid,
});
typedef $$MangaChapterTablesTableUpdateCompanionBuilder
    = MangaChapterTablesCompanion Function({
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
  Value<String> createdAt,
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

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MangaChapterTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaChapterTablesTable,
    MangaChapterTable,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (
      MangaChapterTable,
      BaseReferences<_$AppDatabase, $MangaChapterTablesTable, MangaChapterTable>
    ),
    MangaChapterTable,
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
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaChapterTablesCompanion(
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
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
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
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaChapterTablesCompanion.insert(
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
            createdAt: createdAt,
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
    MangaChapterTable,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (
      MangaChapterTable,
      BaseReferences<_$AppDatabase, $MangaChapterTablesTable, MangaChapterTable>
    ),
    MangaChapterTable,
    PrefetchHooks Function()>;
typedef $$MangaTablesTableCreateCompanionBuilder = MangaTablesCompanion
    Function({
  required String id,
  Value<String?> title,
  Value<String?> coverUrl,
  Value<String?> author,
  Value<String?> status,
  Value<String?> description,
  Value<String?> webUrl,
  Value<String?> source,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});
typedef $$MangaTablesTableUpdateCompanionBuilder = MangaTablesCompanion
    Function({
  Value<String> id,
  Value<String?> title,
  Value<String?> coverUrl,
  Value<String?> author,
  Value<String?> status,
  Value<String?> description,
  Value<String?> webUrl,
  Value<String?> source,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $$MangaTablesTableReferences
    extends BaseReferences<_$AppDatabase, $MangaTablesTable, MangaTable> {
  $$MangaTablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MangaLibraryTablesTable, List<MangaLibraryTable>>
      _mangaLibraryTablesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mangaLibraryTables,
              aliasName: $_aliasNameGenerator(
                  db.mangaTables.id, db.mangaLibraryTables.mangaId));

  $$MangaLibraryTablesTableProcessedTableManager get mangaLibraryTablesRefs {
    final manager =
        $$MangaLibraryTablesTableTableManager($_db, $_db.mangaLibraryTables)
            .filter((f) => f.mangaId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_mangaLibraryTablesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MangaTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTablesTable> {
  $$MangaTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> mangaLibraryTablesRefs(
      Expression<bool> Function($$MangaLibraryTablesTableFilterComposer f) f) {
    final $$MangaLibraryTablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mangaLibraryTables,
        getReferencedColumn: (t) => t.mangaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaLibraryTablesTableFilterComposer(
              $db: $db,
              $table: $db.mangaLibraryTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> mangaLibraryTablesRefs<T extends Object>(
      Expression<T> Function($$MangaLibraryTablesTableAnnotationComposer a) f) {
    final $$MangaLibraryTablesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.mangaLibraryTables,
            getReferencedColumn: (t) => t.mangaId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MangaLibraryTablesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.mangaLibraryTables,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MangaTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaTablesTable,
    MangaTable,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaTable, $$MangaTablesTableReferences),
    MangaTable,
    PrefetchHooks Function({bool mangaLibraryTablesRefs})> {
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
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTablesCompanion(
            id: id,
            title: title,
            coverUrl: coverUrl,
            author: author,
            status: status,
            description: description,
            webUrl: webUrl,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTablesCompanion.insert(
            id: id,
            title: title,
            coverUrl: coverUrl,
            author: author,
            status: status,
            description: description,
            webUrl: webUrl,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MangaTablesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mangaLibraryTablesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mangaLibraryTablesRefs) db.mangaLibraryTables
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mangaLibraryTablesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$MangaTablesTableReferences
                            ._mangaLibraryTablesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MangaTablesTableReferences(db, table, p0)
                                .mangaLibraryTablesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.mangaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MangaTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MangaTablesTable,
    MangaTable,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaTable, $$MangaTablesTableReferences),
    MangaTable,
    PrefetchHooks Function({bool mangaLibraryTablesRefs})>;
typedef $$MangaLibraryTablesTableCreateCompanionBuilder
    = MangaLibraryTablesCompanion Function({
  Value<BigInt> id,
  required String mangaId,
  Value<String> createdAt,
});
typedef $$MangaLibraryTablesTableUpdateCompanionBuilder
    = MangaLibraryTablesCompanion Function({
  Value<BigInt> id,
  Value<String> mangaId,
  Value<String> createdAt,
});

final class $$MangaLibraryTablesTableReferences extends BaseReferences<
    _$AppDatabase, $MangaLibraryTablesTable, MangaLibraryTable> {
  $$MangaLibraryTablesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MangaTablesTable _mangaIdTable(_$AppDatabase db) =>
      db.mangaTables.createAlias($_aliasNameGenerator(
          db.mangaLibraryTables.mangaId, db.mangaTables.id));

  $$MangaTablesTableProcessedTableManager get mangaId {
    final manager = $$MangaTablesTableTableManager($_db, $_db.mangaTables)
        .filter((f) => f.id($_item.mangaId));
    final item = $_typedResult.readTableOrNull(_mangaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MangaLibraryTablesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaLibraryTablesTable> {
  $$MangaLibraryTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MangaTablesTableFilterComposer get mangaId {
    final $$MangaTablesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangaTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaTablesTableFilterComposer(
              $db: $db,
              $table: $db.mangaTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
  ColumnOrderings<BigInt> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MangaTablesTableOrderingComposer get mangaId {
    final $$MangaTablesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangaTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaTablesTableOrderingComposer(
              $db: $db,
              $table: $db.mangaTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
  GeneratedColumn<BigInt> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MangaTablesTableAnnotationComposer get mangaId {
    final $$MangaTablesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mangaId,
        referencedTable: $db.mangaTables,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MangaTablesTableAnnotationComposer(
              $db: $db,
              $table: $db.mangaTables,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
    (MangaLibraryTable, $$MangaLibraryTablesTableReferences),
    MangaLibraryTable,
    PrefetchHooks Function({bool mangaId})> {
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
            Value<BigInt> id = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              MangaLibraryTablesCompanion(
            id: id,
            mangaId: mangaId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<BigInt> id = const Value.absent(),
            required String mangaId,
            Value<String> createdAt = const Value.absent(),
          }) =>
              MangaLibraryTablesCompanion.insert(
            id: id,
            mangaId: mangaId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MangaLibraryTablesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mangaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mangaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mangaId,
                    referencedTable:
                        $$MangaLibraryTablesTableReferences._mangaIdTable(db),
                    referencedColumn: $$MangaLibraryTablesTableReferences
                        ._mangaIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
    (MangaLibraryTable, $$MangaLibraryTablesTableReferences),
    MangaLibraryTable,
    PrefetchHooks Function({bool mangaId})>;
typedef $$MangaTagTablesTableCreateCompanionBuilder = MangaTagTablesCompanion
    Function({
  required String id,
  required String name,
  Value<String> createdAt,
  Value<int> rowid,
});
typedef $$MangaTagTablesTableUpdateCompanionBuilder = MangaTagTablesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> createdAt,
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
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MangaTagTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MangaTagTablesTable,
    MangaTagTable,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (
      MangaTagTable,
      BaseReferences<_$AppDatabase, $MangaTagTablesTable, MangaTagTable>
    ),
    MangaTagTable,
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
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagTablesCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagTablesCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
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
    MangaTagTable,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (
      MangaTagTable,
      BaseReferences<_$AppDatabase, $MangaTagTablesTable, MangaTagTable>
    ),
    MangaTagTable,
    PrefetchHooks Function()>;
typedef $$MangaTagRelationshipTablesTableCreateCompanionBuilder
    = MangaTagRelationshipTablesCompanion Function({
  required String tagId,
  required String mangaId,
  Value<String> createdAt,
  Value<int> rowid,
});
typedef $$MangaTagRelationshipTablesTableUpdateCompanionBuilder
    = MangaTagRelationshipTablesCompanion Function({
  Value<String> tagId,
  Value<String> mangaId,
  Value<String> createdAt,
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
  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mangaId => $composableBuilder(
      column: $table.mangaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
            Value<String> tagId = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagRelationshipTablesCompanion(
            tagId: tagId,
            mangaId: mangaId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tagId,
            required String mangaId,
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MangaTagRelationshipTablesCompanion.insert(
            tagId: tagId,
            mangaId: mangaId,
            createdAt: createdAt,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MangaChapterImageTablesTableTableManager get mangaChapterImageTables =>
      $$MangaChapterImageTablesTableTableManager(
          _db, _db.mangaChapterImageTables);
  $$MangaChapterTablesTableTableManager get mangaChapterTables =>
      $$MangaChapterTablesTableTableManager(_db, _db.mangaChapterTables);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db, _db.mangaTables);
  $$MangaLibraryTablesTableTableManager get mangaLibraryTables =>
      $$MangaLibraryTablesTableTableManager(_db, _db.mangaLibraryTables);
  $$MangaTagTablesTableTableManager get mangaTagTables =>
      $$MangaTagTablesTableTableManager(_db, _db.mangaTagTables);
  $$MangaTagRelationshipTablesTableTableManager
      get mangaTagRelationshipTables =>
          $$MangaTagRelationshipTablesTableTableManager(
              _db, _db.mangaTagRelationshipTables);
}
