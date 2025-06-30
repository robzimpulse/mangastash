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
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
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
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, order, chapterId, webUrl];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    return context;
  }

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
  ImageDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      webUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}web_url'])!,
    );
  }

  @override
  $ImageTablesTable createAlias(String alias) {
    return $ImageTablesTable(attachedDatabase, alias);
  }
}

class ImageDrift extends DataClass implements Insertable<ImageDrift> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final int order;
  final String chapterId;
  final String webUrl;
  const ImageDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.order,
      required this.chapterId,
      required this.webUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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

  factory ImageDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'order': serializer.toJson<int>(order),
      'chapterId': serializer.toJson<String>(chapterId),
      'webUrl': serializer.toJson<String>(webUrl),
    };
  }

  ImageDrift copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
          String? id,
          int? order,
          String? chapterId,
          String? webUrl}) =>
      ImageDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        order: order ?? this.order,
        chapterId: chapterId ?? this.chapterId,
        webUrl: webUrl ?? this.webUrl,
      );
  ImageDrift copyWithCompanion(ImageTablesCompanion data) {
    return ImageDrift(
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
    return (StringBuffer('ImageDrift(')
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
      (other is ImageDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.order == this.order &&
          other.chapterId == this.chapterId &&
          other.webUrl == this.webUrl);
}

class ImageTablesCompanion extends UpdateCompanion<ImageDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
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
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int order,
    required String chapterId,
    required String webUrl,
    this.rowid = const Value.absent(),
  })  : order = Value(order),
        chapterId = Value(chapterId),
        webUrl = Value(webUrl);
  static Insertable<ImageDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
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

  ImageTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? id,
      Value<int>? order,
      Value<String>? chapterId,
      Value<String>? webUrl,
      Value<int>? rowid}) {
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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

class $ChapterTablesTable extends ChapterTables
    with TableInfo<$ChapterTablesTable, ChapterDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
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
  late final GeneratedColumn<DateTime> readableAt = GeneratedColumn<DateTime>(
      'readable_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _publishAtMeta =
      const VerificationMeta('publishAt');
  @override
  late final GeneratedColumn<DateTime> publishAt = GeneratedColumn<DateTime>(
      'publish_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
      'last_read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        lastReadAt
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
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    return context;
  }

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
  ChapterDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
          .read(DriftSqlType.dateTime, data['${effectivePrefix}readable_at']),
      publishAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}publish_at']),
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_read_at']),
    );
  }

  @override
  $ChapterTablesTable createAlias(String alias) {
    return $ChapterTablesTable(attachedDatabase, alias);
  }
}

class ChapterDrift extends DataClass implements Insertable<ChapterDrift> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String? mangaId;
  final String? title;
  final String? volume;
  final String? chapter;
  final String? translatedLanguage;
  final String? scanlationGroup;
  final String? webUrl;
  final DateTime? readableAt;
  final DateTime? publishAt;
  final DateTime? lastReadAt;
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
      this.publishAt,
      this.lastReadAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
      map['readable_at'] = Variable<DateTime>(readableAt);
    }
    if (!nullToAbsent || publishAt != null) {
      map['publish_at'] = Variable<DateTime>(publishAt);
    }
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
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
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
    );
  }

  factory ChapterDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      title: serializer.fromJson<String?>(json['title']),
      volume: serializer.fromJson<String?>(json['volume']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      translatedLanguage:
          serializer.fromJson<String?>(json['translatedLanguage']),
      scanlationGroup: serializer.fromJson<String?>(json['scanlationGroup']),
      webUrl: serializer.fromJson<String?>(json['webUrl']),
      readableAt: serializer.fromJson<DateTime?>(json['readableAt']),
      publishAt: serializer.fromJson<DateTime?>(json['publishAt']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'mangaId': serializer.toJson<String?>(mangaId),
      'title': serializer.toJson<String?>(title),
      'volume': serializer.toJson<String?>(volume),
      'chapter': serializer.toJson<String?>(chapter),
      'translatedLanguage': serializer.toJson<String?>(translatedLanguage),
      'scanlationGroup': serializer.toJson<String?>(scanlationGroup),
      'webUrl': serializer.toJson<String?>(webUrl),
      'readableAt': serializer.toJson<DateTime?>(readableAt),
      'publishAt': serializer.toJson<DateTime?>(publishAt),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
    };
  }

  ChapterDrift copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
          String? id,
          Value<String?> mangaId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> volume = const Value.absent(),
          Value<String?> chapter = const Value.absent(),
          Value<String?> translatedLanguage = const Value.absent(),
          Value<String?> scanlationGroup = const Value.absent(),
          Value<String?> webUrl = const Value.absent(),
          Value<DateTime?> readableAt = const Value.absent(),
          Value<DateTime?> publishAt = const Value.absent(),
          Value<DateTime?> lastReadAt = const Value.absent()}) =>
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
        lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
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
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
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
      lastReadAt);
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
          other.publishAt == this.publishAt &&
          other.lastReadAt == this.lastReadAt);
}

class ChapterTablesCompanion extends UpdateCompanion<ChapterDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String?> mangaId;
  final Value<String?> title;
  final Value<String?> volume;
  final Value<String?> chapter;
  final Value<String?> translatedLanguage;
  final Value<String?> scanlationGroup;
  final Value<String?> webUrl;
  final Value<DateTime?> readableAt;
  final Value<DateTime?> publishAt;
  final Value<DateTime?> lastReadAt;
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
  static Insertable<ChapterDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? mangaId,
    Expression<String>? title,
    Expression<String>? volume,
    Expression<String>? chapter,
    Expression<String>? translatedLanguage,
    Expression<String>? scanlationGroup,
    Expression<String>? webUrl,
    Expression<DateTime>? readableAt,
    Expression<DateTime>? publishAt,
    Expression<DateTime>? lastReadAt,
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

  ChapterTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? id,
      Value<String?>? mangaId,
      Value<String?>? title,
      Value<String?>? volume,
      Value<String?>? chapter,
      Value<String?>? translatedLanguage,
      Value<String?>? scanlationGroup,
      Value<String?>? webUrl,
      Value<DateTime?>? readableAt,
      Value<DateTime?>? publishAt,
      Value<DateTime?>? lastReadAt,
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
      lastReadAt: lastReadAt ?? this.lastReadAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
      map['readable_at'] = Variable<DateTime>(readableAt.value);
    }
    if (publishAt.present) {
      map['publish_at'] = Variable<DateTime>(publishAt.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
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

class $LibraryTablesTable extends LibraryTables
    with TableInfo<$LibraryTablesTable, LibraryDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _mangaIdMeta =
      const VerificationMeta('mangaId');
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
      'manga_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [createdAt, updatedAt, mangaId];
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
    if (data.containsKey('manga_id')) {
      context.handle(_mangaIdMeta,
          mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta));
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mangaId};
  @override
  LibraryDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String mangaId;
  const LibraryDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.mangaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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

  factory LibraryDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  LibraryDrift copyWith(
          {DateTime? createdAt, DateTime? updatedAt, String? mangaId}) =>
      LibraryDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        mangaId: mangaId ?? this.mangaId,
      );
  LibraryDrift copyWithCompanion(LibraryTablesCompanion data) {
    return LibraryDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryDrift(')
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
      (other is LibraryDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.mangaId == this.mangaId);
}

class LibraryTablesCompanion extends UpdateCompanion<LibraryDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> mangaId;
  final Value<int> rowid;
  const LibraryTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String mangaId,
    this.rowid = const Value.absent(),
  }) : mangaId = Value(mangaId);
  static Insertable<LibraryDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
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

  LibraryTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? mangaId,
      Value<int>? rowid}) {
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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

class $MangaTablesTable extends MangaTables
    with TableInfo<$MangaTablesTable, MangaDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {webUrl, source},
        {webUrl},
      ];
  @override
  MangaDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  final DateTime createdAt;
  final DateTime updatedAt;
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
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
          {DateTime? createdAt,
          DateTime? updatedAt,
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
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
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
  static Insertable<MangaDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
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
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, name, source];
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
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id, name, source},
      ];
  @override
  TagDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
    );
  }

  @override
  $TagTablesTable createAlias(String alias) {
    return $TagTablesTable(attachedDatabase, alias);
  }
}

class TagDrift extends DataClass implements Insertable<TagDrift> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final String name;
  final String? source;
  const TagDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
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
      name: Value(name),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
    );
  }

  factory TagDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String?>(source),
    };
  }

  TagDrift copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
          String? id,
          String? name,
          Value<String?> source = const Value.absent()}) =>
      TagDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        source: source.present ? source.value : this.source,
      );
  TagDrift copyWithCompanion(TagTablesCompanion data) {
    return TagDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, name, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source);
}

class TagTablesCompanion extends UpdateCompanion<TagDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> source;
  final Value<int> rowid;
  const TagTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TagDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String?>? source,
      Value<int>? rowid}) {
    return TagTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('TagTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
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
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
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
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {tagId, mangaId},
      ];
  @override
  RelationshipTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipTable(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
  final DateTime createdAt;
  final DateTime updatedAt;
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
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tagId: serializer.fromJson<String>(json['tagId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tagId': serializer.toJson<String>(tagId),
      'mangaId': serializer.toJson<String>(mangaId),
    };
  }

  RelationshipTable copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
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
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
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
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
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
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
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
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
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
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, type, source, chapterId, mangaId, imageUrl];
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
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
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
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
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
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final JobTypeEnum type;
  final String? source;
  final String? chapterId;
  final String? mangaId;
  final String? imageUrl;
  const JobDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.type,
      this.source,
      this.chapterId,
      this.mangaId,
      this.imageUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
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
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
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
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory JobDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      type: $JobTablesTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      source: serializer.fromJson<String?>(json['source']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      mangaId: serializer.fromJson<String?>(json['mangaId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'type': serializer
          .toJson<String>($JobTablesTable.$convertertype.toJson(type)),
      'source': serializer.toJson<String?>(source),
      'chapterId': serializer.toJson<String?>(chapterId),
      'mangaId': serializer.toJson<String?>(mangaId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  JobDrift copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
          int? id,
          JobTypeEnum? type,
          Value<String?> source = const Value.absent(),
          Value<String?> chapterId = const Value.absent(),
          Value<String?> mangaId = const Value.absent(),
          Value<String?> imageUrl = const Value.absent()}) =>
      JobDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        type: type ?? this.type,
        source: source.present ? source.value : this.source,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        mangaId: mangaId.present ? mangaId.value : this.mangaId,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
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
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
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
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      createdAt, updatedAt, id, type, source, chapterId, mangaId, imageUrl);
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
          other.imageUrl == this.imageUrl);
}

class JobTablesCompanion extends UpdateCompanion<JobDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<JobTypeEnum> type;
  final Value<String?> source;
  final Value<String?> chapterId;
  final Value<String?> mangaId;
  final Value<String?> imageUrl;
  const JobTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageUrl = const Value.absent(),
  });
  JobTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required JobTypeEnum type,
    this.source = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.imageUrl = const Value.absent(),
  }) : type = Value(type);
  static Insertable<JobDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? source,
    Expression<String>? chapterId,
    Expression<String>? mangaId,
    Expression<String>? imageUrl,
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
    });
  }

  JobTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? id,
      Value<JobTypeEnum>? type,
      Value<String?>? source,
      Value<String?>? chapterId,
      Value<String?>? mangaId,
      Value<String?>? imageUrl}) {
    return JobTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      chapterId: chapterId ?? this.chapterId,
      mangaId: mangaId ?? this.mangaId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
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
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }
}

class $CacheTablesTable extends CacheTables
    with TableInfo<$CacheTablesTable, CacheDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.timestamp());
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relativePath', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eTagMeta = const VerificationMeta('eTag');
  @override
  late final GeneratedColumn<String> eTag = GeneratedColumn<String>(
      'e_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _validTillMeta =
      const VerificationMeta('validTill');
  @override
  late final GeneratedColumn<DateTime> validTill = GeneratedColumn<DateTime>(
      'valid_till', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _touchedMeta =
      const VerificationMeta('touched');
  @override
  late final GeneratedColumn<DateTime> touched = GeneratedColumn<DateTime>(
      'touched', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<int> length = GeneratedColumn<int>(
      'length', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        updatedAt,
        id,
        url,
        key,
        relativePath,
        eTag,
        validTill,
        touched,
        length
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_tables';
  @override
  VerificationContext validateIntegrity(Insertable<CacheDrift> instance,
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
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('relativePath')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relativePath']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('e_tag')) {
      context.handle(
          _eTagMeta, eTag.isAcceptableOrUnknown(data['e_tag']!, _eTagMeta));
    }
    if (data.containsKey('valid_till')) {
      context.handle(_validTillMeta,
          validTill.isAcceptableOrUnknown(data['valid_till']!, _validTillMeta));
    } else if (isInserting) {
      context.missing(_validTillMeta);
    }
    if (data.containsKey('touched')) {
      context.handle(_touchedMeta,
          touched.isAcceptableOrUnknown(data['touched']!, _touchedMeta));
    }
    if (data.containsKey('length')) {
      context.handle(_lengthMeta,
          length.isAcceptableOrUnknown(data['length']!, _lengthMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheDrift(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relativePath'])!,
      eTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}e_tag']),
      validTill: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}valid_till'])!,
      touched: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}touched']),
      length: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}length']),
    );
  }

  @override
  $CacheTablesTable createAlias(String alias) {
    return $CacheTablesTable(attachedDatabase, alias);
  }
}

class CacheDrift extends DataClass implements Insertable<CacheDrift> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String url;
  final String key;
  final String relativePath;
  final String? eTag;
  final DateTime validTill;
  final DateTime? touched;
  final int? length;
  const CacheDrift(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.url,
      required this.key,
      required this.relativePath,
      this.eTag,
      required this.validTill,
      this.touched,
      this.length});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['key'] = Variable<String>(key);
    map['relativePath'] = Variable<String>(relativePath);
    if (!nullToAbsent || eTag != null) {
      map['e_tag'] = Variable<String>(eTag);
    }
    map['valid_till'] = Variable<DateTime>(validTill);
    if (!nullToAbsent || touched != null) {
      map['touched'] = Variable<DateTime>(touched);
    }
    if (!nullToAbsent || length != null) {
      map['length'] = Variable<int>(length);
    }
    return map;
  }

  CacheTablesCompanion toCompanion(bool nullToAbsent) {
    return CacheTablesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      url: Value(url),
      key: Value(key),
      relativePath: Value(relativePath),
      eTag: eTag == null && nullToAbsent ? const Value.absent() : Value(eTag),
      validTill: Value(validTill),
      touched: touched == null && nullToAbsent
          ? const Value.absent()
          : Value(touched),
      length:
          length == null && nullToAbsent ? const Value.absent() : Value(length),
    );
  }

  factory CacheDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheDrift(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      key: serializer.fromJson<String>(json['key']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      eTag: serializer.fromJson<String?>(json['eTag']),
      validTill: serializer.fromJson<DateTime>(json['validTill']),
      touched: serializer.fromJson<DateTime?>(json['touched']),
      length: serializer.fromJson<int?>(json['length']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'key': serializer.toJson<String>(key),
      'relativePath': serializer.toJson<String>(relativePath),
      'eTag': serializer.toJson<String?>(eTag),
      'validTill': serializer.toJson<DateTime>(validTill),
      'touched': serializer.toJson<DateTime?>(touched),
      'length': serializer.toJson<int?>(length),
    };
  }

  CacheDrift copyWith(
          {DateTime? createdAt,
          DateTime? updatedAt,
          int? id,
          String? url,
          String? key,
          String? relativePath,
          Value<String?> eTag = const Value.absent(),
          DateTime? validTill,
          Value<DateTime?> touched = const Value.absent(),
          Value<int?> length = const Value.absent()}) =>
      CacheDrift(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        url: url ?? this.url,
        key: key ?? this.key,
        relativePath: relativePath ?? this.relativePath,
        eTag: eTag.present ? eTag.value : this.eTag,
        validTill: validTill ?? this.validTill,
        touched: touched.present ? touched.value : this.touched,
        length: length.present ? length.value : this.length,
      );
  CacheDrift copyWithCompanion(CacheTablesCompanion data) {
    return CacheDrift(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      key: data.key.present ? data.key.value : this.key,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      eTag: data.eTag.present ? data.eTag.value : this.eTag,
      validTill: data.validTill.present ? data.validTill.value : this.validTill,
      touched: data.touched.present ? data.touched.value : this.touched,
      length: data.length.present ? data.length.value : this.length,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheDrift(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('key: $key, ')
          ..write('relativePath: $relativePath, ')
          ..write('eTag: $eTag, ')
          ..write('validTill: $validTill, ')
          ..write('touched: $touched, ')
          ..write('length: $length')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, url, key,
      relativePath, eTag, validTill, touched, length);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheDrift &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.url == this.url &&
          other.key == this.key &&
          other.relativePath == this.relativePath &&
          other.eTag == this.eTag &&
          other.validTill == this.validTill &&
          other.touched == this.touched &&
          other.length == this.length);
}

class CacheTablesCompanion extends UpdateCompanion<CacheDrift> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> url;
  final Value<String> key;
  final Value<String> relativePath;
  final Value<String?> eTag;
  final Value<DateTime> validTill;
  final Value<DateTime?> touched;
  final Value<int?> length;
  const CacheTablesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.key = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.eTag = const Value.absent(),
    this.validTill = const Value.absent(),
    this.touched = const Value.absent(),
    this.length = const Value.absent(),
  });
  CacheTablesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String url,
    required String key,
    required String relativePath,
    this.eTag = const Value.absent(),
    required DateTime validTill,
    this.touched = const Value.absent(),
    this.length = const Value.absent(),
  })  : url = Value(url),
        key = Value(key),
        relativePath = Value(relativePath),
        validTill = Value(validTill);
  static Insertable<CacheDrift> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? key,
    Expression<String>? relativePath,
    Expression<String>? eTag,
    Expression<DateTime>? validTill,
    Expression<DateTime>? touched,
    Expression<int>? length,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (key != null) 'key': key,
      if (relativePath != null) 'relativePath': relativePath,
      if (eTag != null) 'e_tag': eTag,
      if (validTill != null) 'valid_till': validTill,
      if (touched != null) 'touched': touched,
      if (length != null) 'length': length,
    });
  }

  CacheTablesCompanion copyWith(
      {Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? id,
      Value<String>? url,
      Value<String>? key,
      Value<String>? relativePath,
      Value<String?>? eTag,
      Value<DateTime>? validTill,
      Value<DateTime?>? touched,
      Value<int?>? length}) {
    return CacheTablesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      url: url ?? this.url,
      key: key ?? this.key,
      relativePath: relativePath ?? this.relativePath,
      eTag: eTag ?? this.eTag,
      validTill: validTill ?? this.validTill,
      touched: touched ?? this.touched,
      length: length ?? this.length,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (relativePath.present) {
      map['relativePath'] = Variable<String>(relativePath.value);
    }
    if (eTag.present) {
      map['e_tag'] = Variable<String>(eTag.value);
    }
    if (validTill.present) {
      map['valid_till'] = Variable<DateTime>(validTill.value);
    }
    if (touched.present) {
      map['touched'] = Variable<DateTime>(touched.value);
    }
    if (length.present) {
      map['length'] = Variable<int>(length.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheTablesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('key: $key, ')
          ..write('relativePath: $relativePath, ')
          ..write('eTag: $eTag, ')
          ..write('validTill: $validTill, ')
          ..write('touched: $touched, ')
          ..write('length: $length')
          ..write(')'))
        .toString();
  }
}

class $DioCacheTablesTable extends DioCacheTables
    with TableInfo<$DioCacheTablesTable, DioCacheDrift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DioCacheTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta =
      const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cache_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cacheControlMeta =
      const VerificationMeta('cacheControl');
  @override
  late final GeneratedColumn<String> cacheControl = GeneratedColumn<String>(
      'cache_control', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<Uint8List> content = GeneratedColumn<Uint8List>(
      'content', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _eTagMeta = const VerificationMeta('eTag');
  @override
  late final GeneratedColumn<String> eTag = GeneratedColumn<String>(
      'e_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresMeta =
      const VerificationMeta('expires');
  @override
  late final GeneratedColumn<DateTime> expires = GeneratedColumn<DateTime>(
      'expires', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _headersMeta =
      const VerificationMeta('headers');
  @override
  late final GeneratedColumn<Uint8List> headers = GeneratedColumn<Uint8List>(
      'headers', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
      'last_modified', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxStaleMeta =
      const VerificationMeta('maxStale');
  @override
  late final GeneratedColumn<DateTime> maxStale = GeneratedColumn<DateTime>(
      'max_stale', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _requestDateMeta =
      const VerificationMeta('requestDate');
  @override
  late final GeneratedColumn<DateTime> requestDate = GeneratedColumn<DateTime>(
      'request_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _responseDateMeta =
      const VerificationMeta('responseDate');
  @override
  late final GeneratedColumn<DateTime> responseDate = GeneratedColumn<DateTime>(
      'response_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusCodeMeta =
      const VerificationMeta('statusCode');
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
      'status_code', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        cacheKey,
        date,
        cacheControl,
        content,
        eTag,
        expires,
        headers,
        lastModified,
        maxStale,
        priority,
        requestDate,
        responseDate,
        url,
        statusCode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dio_cache_tables';
  @override
  VerificationContext validateIntegrity(Insertable<DioCacheDrift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta,
          cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('cache_control')) {
      context.handle(
          _cacheControlMeta,
          cacheControl.isAcceptableOrUnknown(
              data['cache_control']!, _cacheControlMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('e_tag')) {
      context.handle(
          _eTagMeta, eTag.isAcceptableOrUnknown(data['e_tag']!, _eTagMeta));
    }
    if (data.containsKey('expires')) {
      context.handle(_expiresMeta,
          expires.isAcceptableOrUnknown(data['expires']!, _expiresMeta));
    }
    if (data.containsKey('headers')) {
      context.handle(_headersMeta,
          headers.isAcceptableOrUnknown(data['headers']!, _headersMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    if (data.containsKey('max_stale')) {
      context.handle(_maxStaleMeta,
          maxStale.isAcceptableOrUnknown(data['max_stale']!, _maxStaleMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('request_date')) {
      context.handle(
          _requestDateMeta,
          requestDate.isAcceptableOrUnknown(
              data['request_date']!, _requestDateMeta));
    }
    if (data.containsKey('response_date')) {
      context.handle(
          _responseDateMeta,
          responseDate.isAcceptableOrUnknown(
              data['response_date']!, _responseDateMeta));
    } else if (isInserting) {
      context.missing(_responseDateMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
          _statusCodeMeta,
          statusCode.isAcceptableOrUnknown(
              data['status_code']!, _statusCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DioCacheDrift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DioCacheDrift(
      cacheKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date']),
      cacheControl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_control']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}content']),
      eTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}e_tag']),
      expires: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires']),
      headers: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}headers']),
      lastModified: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_modified']),
      maxStale: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}max_stale']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      requestDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}request_date']),
      responseDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}response_date'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      statusCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status_code']),
    );
  }

  @override
  $DioCacheTablesTable createAlias(String alias) {
    return $DioCacheTablesTable(attachedDatabase, alias);
  }
}

class DioCacheDrift extends DataClass implements Insertable<DioCacheDrift> {
  final String cacheKey;
  final DateTime? date;
  final String? cacheControl;
  final Uint8List? content;
  final String? eTag;
  final DateTime? expires;
  final Uint8List? headers;
  final String? lastModified;
  final DateTime? maxStale;
  final int priority;
  final DateTime? requestDate;
  final DateTime responseDate;
  final String url;
  final int? statusCode;
  const DioCacheDrift(
      {required this.cacheKey,
      this.date,
      this.cacheControl,
      this.content,
      this.eTag,
      this.expires,
      this.headers,
      this.lastModified,
      this.maxStale,
      required this.priority,
      this.requestDate,
      required this.responseDate,
      required this.url,
      this.statusCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || cacheControl != null) {
      map['cache_control'] = Variable<String>(cacheControl);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<Uint8List>(content);
    }
    if (!nullToAbsent || eTag != null) {
      map['e_tag'] = Variable<String>(eTag);
    }
    if (!nullToAbsent || expires != null) {
      map['expires'] = Variable<DateTime>(expires);
    }
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<Uint8List>(headers);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || maxStale != null) {
      map['max_stale'] = Variable<DateTime>(maxStale);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || requestDate != null) {
      map['request_date'] = Variable<DateTime>(requestDate);
    }
    map['response_date'] = Variable<DateTime>(responseDate);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || statusCode != null) {
      map['status_code'] = Variable<int>(statusCode);
    }
    return map;
  }

  DioCacheTablesCompanion toCompanion(bool nullToAbsent) {
    return DioCacheTablesCompanion(
      cacheKey: Value(cacheKey),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      cacheControl: cacheControl == null && nullToAbsent
          ? const Value.absent()
          : Value(cacheControl),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      eTag: eTag == null && nullToAbsent ? const Value.absent() : Value(eTag),
      expires: expires == null && nullToAbsent
          ? const Value.absent()
          : Value(expires),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      maxStale: maxStale == null && nullToAbsent
          ? const Value.absent()
          : Value(maxStale),
      priority: Value(priority),
      requestDate: requestDate == null && nullToAbsent
          ? const Value.absent()
          : Value(requestDate),
      responseDate: Value(responseDate),
      url: Value(url),
      statusCode: statusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(statusCode),
    );
  }

  factory DioCacheDrift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DioCacheDrift(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      date: serializer.fromJson<DateTime?>(json['date']),
      cacheControl: serializer.fromJson<String?>(json['cacheControl']),
      content: serializer.fromJson<Uint8List?>(json['content']),
      eTag: serializer.fromJson<String?>(json['eTag']),
      expires: serializer.fromJson<DateTime?>(json['expires']),
      headers: serializer.fromJson<Uint8List?>(json['headers']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      maxStale: serializer.fromJson<DateTime?>(json['maxStale']),
      priority: serializer.fromJson<int>(json['priority']),
      requestDate: serializer.fromJson<DateTime?>(json['requestDate']),
      responseDate: serializer.fromJson<DateTime>(json['responseDate']),
      url: serializer.fromJson<String>(json['url']),
      statusCode: serializer.fromJson<int?>(json['statusCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'date': serializer.toJson<DateTime?>(date),
      'cacheControl': serializer.toJson<String?>(cacheControl),
      'content': serializer.toJson<Uint8List?>(content),
      'eTag': serializer.toJson<String?>(eTag),
      'expires': serializer.toJson<DateTime?>(expires),
      'headers': serializer.toJson<Uint8List?>(headers),
      'lastModified': serializer.toJson<String?>(lastModified),
      'maxStale': serializer.toJson<DateTime?>(maxStale),
      'priority': serializer.toJson<int>(priority),
      'requestDate': serializer.toJson<DateTime?>(requestDate),
      'responseDate': serializer.toJson<DateTime>(responseDate),
      'url': serializer.toJson<String>(url),
      'statusCode': serializer.toJson<int?>(statusCode),
    };
  }

  DioCacheDrift copyWith(
          {String? cacheKey,
          Value<DateTime?> date = const Value.absent(),
          Value<String?> cacheControl = const Value.absent(),
          Value<Uint8List?> content = const Value.absent(),
          Value<String?> eTag = const Value.absent(),
          Value<DateTime?> expires = const Value.absent(),
          Value<Uint8List?> headers = const Value.absent(),
          Value<String?> lastModified = const Value.absent(),
          Value<DateTime?> maxStale = const Value.absent(),
          int? priority,
          Value<DateTime?> requestDate = const Value.absent(),
          DateTime? responseDate,
          String? url,
          Value<int?> statusCode = const Value.absent()}) =>
      DioCacheDrift(
        cacheKey: cacheKey ?? this.cacheKey,
        date: date.present ? date.value : this.date,
        cacheControl:
            cacheControl.present ? cacheControl.value : this.cacheControl,
        content: content.present ? content.value : this.content,
        eTag: eTag.present ? eTag.value : this.eTag,
        expires: expires.present ? expires.value : this.expires,
        headers: headers.present ? headers.value : this.headers,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        maxStale: maxStale.present ? maxStale.value : this.maxStale,
        priority: priority ?? this.priority,
        requestDate: requestDate.present ? requestDate.value : this.requestDate,
        responseDate: responseDate ?? this.responseDate,
        url: url ?? this.url,
        statusCode: statusCode.present ? statusCode.value : this.statusCode,
      );
  DioCacheDrift copyWithCompanion(DioCacheTablesCompanion data) {
    return DioCacheDrift(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      date: data.date.present ? data.date.value : this.date,
      cacheControl: data.cacheControl.present
          ? data.cacheControl.value
          : this.cacheControl,
      content: data.content.present ? data.content.value : this.content,
      eTag: data.eTag.present ? data.eTag.value : this.eTag,
      expires: data.expires.present ? data.expires.value : this.expires,
      headers: data.headers.present ? data.headers.value : this.headers,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      maxStale: data.maxStale.present ? data.maxStale.value : this.maxStale,
      priority: data.priority.present ? data.priority.value : this.priority,
      requestDate:
          data.requestDate.present ? data.requestDate.value : this.requestDate,
      responseDate: data.responseDate.present
          ? data.responseDate.value
          : this.responseDate,
      url: data.url.present ? data.url.value : this.url,
      statusCode:
          data.statusCode.present ? data.statusCode.value : this.statusCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DioCacheDrift(')
          ..write('cacheKey: $cacheKey, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url, ')
          ..write('statusCode: $statusCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      cacheKey,
      date,
      cacheControl,
      $driftBlobEquality.hash(content),
      eTag,
      expires,
      $driftBlobEquality.hash(headers),
      lastModified,
      maxStale,
      priority,
      requestDate,
      responseDate,
      url,
      statusCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DioCacheDrift &&
          other.cacheKey == this.cacheKey &&
          other.date == this.date &&
          other.cacheControl == this.cacheControl &&
          $driftBlobEquality.equals(other.content, this.content) &&
          other.eTag == this.eTag &&
          other.expires == this.expires &&
          $driftBlobEquality.equals(other.headers, this.headers) &&
          other.lastModified == this.lastModified &&
          other.maxStale == this.maxStale &&
          other.priority == this.priority &&
          other.requestDate == this.requestDate &&
          other.responseDate == this.responseDate &&
          other.url == this.url &&
          other.statusCode == this.statusCode);
}

class DioCacheTablesCompanion extends UpdateCompanion<DioCacheDrift> {
  final Value<String> cacheKey;
  final Value<DateTime?> date;
  final Value<String?> cacheControl;
  final Value<Uint8List?> content;
  final Value<String?> eTag;
  final Value<DateTime?> expires;
  final Value<Uint8List?> headers;
  final Value<String?> lastModified;
  final Value<DateTime?> maxStale;
  final Value<int> priority;
  final Value<DateTime?> requestDate;
  final Value<DateTime> responseDate;
  final Value<String> url;
  final Value<int?> statusCode;
  final Value<int> rowid;
  const DioCacheTablesCompanion({
    this.cacheKey = const Value.absent(),
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    this.priority = const Value.absent(),
    this.requestDate = const Value.absent(),
    this.responseDate = const Value.absent(),
    this.url = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DioCacheTablesCompanion.insert({
    required String cacheKey,
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    required int priority,
    this.requestDate = const Value.absent(),
    required DateTime responseDate,
    required String url,
    this.statusCode = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : cacheKey = Value(cacheKey),
        priority = Value(priority),
        responseDate = Value(responseDate),
        url = Value(url);
  static Insertable<DioCacheDrift> custom({
    Expression<String>? cacheKey,
    Expression<DateTime>? date,
    Expression<String>? cacheControl,
    Expression<Uint8List>? content,
    Expression<String>? eTag,
    Expression<DateTime>? expires,
    Expression<Uint8List>? headers,
    Expression<String>? lastModified,
    Expression<DateTime>? maxStale,
    Expression<int>? priority,
    Expression<DateTime>? requestDate,
    Expression<DateTime>? responseDate,
    Expression<String>? url,
    Expression<int>? statusCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (date != null) 'date': date,
      if (cacheControl != null) 'cache_control': cacheControl,
      if (content != null) 'content': content,
      if (eTag != null) 'e_tag': eTag,
      if (expires != null) 'expires': expires,
      if (headers != null) 'headers': headers,
      if (lastModified != null) 'last_modified': lastModified,
      if (maxStale != null) 'max_stale': maxStale,
      if (priority != null) 'priority': priority,
      if (requestDate != null) 'request_date': requestDate,
      if (responseDate != null) 'response_date': responseDate,
      if (url != null) 'url': url,
      if (statusCode != null) 'status_code': statusCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DioCacheTablesCompanion copyWith(
      {Value<String>? cacheKey,
      Value<DateTime?>? date,
      Value<String?>? cacheControl,
      Value<Uint8List?>? content,
      Value<String?>? eTag,
      Value<DateTime?>? expires,
      Value<Uint8List?>? headers,
      Value<String?>? lastModified,
      Value<DateTime?>? maxStale,
      Value<int>? priority,
      Value<DateTime?>? requestDate,
      Value<DateTime>? responseDate,
      Value<String>? url,
      Value<int?>? statusCode,
      Value<int>? rowid}) {
    return DioCacheTablesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      date: date ?? this.date,
      cacheControl: cacheControl ?? this.cacheControl,
      content: content ?? this.content,
      eTag: eTag ?? this.eTag,
      expires: expires ?? this.expires,
      headers: headers ?? this.headers,
      lastModified: lastModified ?? this.lastModified,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      url: url ?? this.url,
      statusCode: statusCode ?? this.statusCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (cacheControl.present) {
      map['cache_control'] = Variable<String>(cacheControl.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List>(content.value);
    }
    if (eTag.present) {
      map['e_tag'] = Variable<String>(eTag.value);
    }
    if (expires.present) {
      map['expires'] = Variable<DateTime>(expires.value);
    }
    if (headers.present) {
      map['headers'] = Variable<Uint8List>(headers.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (maxStale.present) {
      map['max_stale'] = Variable<DateTime>(maxStale.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (requestDate.present) {
      map['request_date'] = Variable<DateTime>(requestDate.value);
    }
    if (responseDate.present) {
      map['response_date'] = Variable<DateTime>(responseDate.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DioCacheTablesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url, ')
          ..write('statusCode: $statusCode, ')
          ..write('rowid: $rowid')
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
  late final $CacheTablesTable cacheTables = $CacheTablesTable(this);
  late final $DioCacheTablesTable dioCacheTables = $DioCacheTablesTable(this);
  late final MangaDao mangaDao = MangaDao(this as AppDatabase);
  late final ChapterDao chapterDao = ChapterDao(this as AppDatabase);
  late final LibraryDao libraryDao = LibraryDao(this as AppDatabase);
  late final JobDao jobDao = JobDao(this as AppDatabase);
  late final ImageDao imageDao = ImageDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final CacheDao cacheDao = CacheDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
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
        cacheTables,
        dioCacheTables
      ];
}

typedef $$ImageTablesTableCreateCompanionBuilder = ImageTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  required int order,
  required String chapterId,
  required String webUrl,
  Value<int> rowid,
});
typedef $$ImageTablesTableUpdateCompanionBuilder = ImageTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<int> order,
  Value<String> chapterId,
  Value<String> webUrl,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webUrl => $composableBuilder(
      column: $table.webUrl, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get webUrl =>
      $composableBuilder(column: $table.webUrl, builder: (column) => column);
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> webUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            order: order,
            chapterId: chapterId,
            webUrl: webUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            required int order,
            required String chapterId,
            required String webUrl,
            Value<int> rowid = const Value.absent(),
          }) =>
              ImageTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            order: order,
            chapterId: chapterId,
            webUrl: webUrl,
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<String?> mangaId,
  Value<String?> title,
  Value<String?> volume,
  Value<String?> chapter,
  Value<String?> translatedLanguage,
  Value<String?> scanlationGroup,
  Value<String?> webUrl,
  Value<DateTime?> readableAt,
  Value<DateTime?> publishAt,
  Value<DateTime?> lastReadAt,
  Value<int> rowid,
});
typedef $$ChapterTablesTableUpdateCompanionBuilder = ChapterTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<String?> mangaId,
  Value<String?> title,
  Value<String?> volume,
  Value<String?> chapter,
  Value<String?> translatedLanguage,
  Value<String?> scanlationGroup,
  Value<String?> webUrl,
  Value<DateTime?> readableAt,
  Value<DateTime?> publishAt,
  Value<DateTime?> lastReadAt,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
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

  ColumnFilters<DateTime> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publishAt => $composableBuilder(
      column: $table.publishAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
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

  ColumnOrderings<DateTime> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publishAt => $composableBuilder(
      column: $table.publishAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
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

  GeneratedColumn<DateTime> get readableAt => $composableBuilder(
      column: $table.readableAt, builder: (column) => column);

  GeneratedColumn<DateTime> get publishAt =>
      $composableBuilder(column: $table.publishAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> volume = const Value.absent(),
            Value<String?> chapter = const Value.absent(),
            Value<String?> translatedLanguage = const Value.absent(),
            Value<String?> scanlationGroup = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<DateTime?> readableAt = const Value.absent(),
            Value<DateTime?> publishAt = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
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
            lastReadAt: lastReadAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> volume = const Value.absent(),
            Value<String?> chapter = const Value.absent(),
            Value<String?> translatedLanguage = const Value.absent(),
            Value<String?> scanlationGroup = const Value.absent(),
            Value<String?> webUrl = const Value.absent(),
            Value<DateTime?> readableAt = const Value.absent(),
            Value<DateTime?> publishAt = const Value.absent(),
            Value<DateTime?> lastReadAt = const Value.absent(),
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
            lastReadAt: lastReadAt,
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String mangaId,
  Value<int> rowid,
});
typedef $$LibraryTablesTableUpdateCompanionBuilder = LibraryTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> mangaId,
  Value<int> rowid,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> mangaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            mangaId: mangaId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            required String mangaId,
            Value<int> rowid = const Value.absent(),
          }) =>
              LibraryTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            mangaId: mangaId,
            rowid: rowid,
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
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
typedef $$MangaTablesTableUpdateCompanionBuilder = MangaTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  required String name,
  Value<String?> source,
  Value<int> rowid,
});
typedef $$TagTablesTableUpdateCompanionBuilder = TagTablesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String?> source,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            source: source,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            required String name,
            Value<String?> source = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            source: source,
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  required String tagId,
  required String mangaId,
  Value<int> rowid,
});
typedef $$RelationshipTablesTableUpdateCompanionBuilder
    = RelationshipTablesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
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
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  required JobTypeEnum type,
  Value<String?> source,
  Value<String?> chapterId,
  Value<String?> mangaId,
  Value<String?> imageUrl,
});
typedef $$JobTablesTableUpdateCompanionBuilder = JobTablesCompanion Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  Value<JobTypeEnum> type,
  Value<String?> source,
  Value<String?> chapterId,
  Value<String?> mangaId,
  Value<String?> imageUrl,
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
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
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

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
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

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
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

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
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
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<JobTypeEnum> type = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
          }) =>
              JobTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
            imageUrl: imageUrl,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            required JobTypeEnum type,
            Value<String?> source = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String?> mangaId = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
          }) =>
              JobTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            source: source,
            chapterId: chapterId,
            mangaId: mangaId,
            imageUrl: imageUrl,
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
typedef $$CacheTablesTableCreateCompanionBuilder = CacheTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  required String url,
  required String key,
  required String relativePath,
  Value<String?> eTag,
  required DateTime validTill,
  Value<DateTime?> touched,
  Value<int?> length,
});
typedef $$CacheTablesTableUpdateCompanionBuilder = CacheTablesCompanion
    Function({
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> id,
  Value<String> url,
  Value<String> key,
  Value<String> relativePath,
  Value<String?> eTag,
  Value<DateTime> validTill,
  Value<DateTime?> touched,
  Value<int?> length,
});

class $$CacheTablesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheTablesTable> {
  $$CacheTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eTag => $composableBuilder(
      column: $table.eTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get validTill => $composableBuilder(
      column: $table.validTill, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get touched => $composableBuilder(
      column: $table.touched, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnFilters(column));
}

class $$CacheTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTablesTable> {
  $$CacheTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eTag => $composableBuilder(
      column: $table.eTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get validTill => $composableBuilder(
      column: $table.validTill, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get touched => $composableBuilder(
      column: $table.touched, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get length => $composableBuilder(
      column: $table.length, builder: (column) => ColumnOrderings(column));
}

class $$CacheTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTablesTable> {
  $$CacheTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<String> get eTag =>
      $composableBuilder(column: $table.eTag, builder: (column) => column);

  GeneratedColumn<DateTime> get validTill =>
      $composableBuilder(column: $table.validTill, builder: (column) => column);

  GeneratedColumn<DateTime> get touched =>
      $composableBuilder(column: $table.touched, builder: (column) => column);

  GeneratedColumn<int> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);
}

class $$CacheTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CacheTablesTable,
    CacheDrift,
    $$CacheTablesTableFilterComposer,
    $$CacheTablesTableOrderingComposer,
    $$CacheTablesTableAnnotationComposer,
    $$CacheTablesTableCreateCompanionBuilder,
    $$CacheTablesTableUpdateCompanionBuilder,
    (CacheDrift, BaseReferences<_$AppDatabase, $CacheTablesTable, CacheDrift>),
    CacheDrift,
    PrefetchHooks Function()> {
  $$CacheTablesTableTableManager(_$AppDatabase db, $CacheTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<String?> eTag = const Value.absent(),
            Value<DateTime> validTill = const Value.absent(),
            Value<DateTime?> touched = const Value.absent(),
            Value<int?> length = const Value.absent(),
          }) =>
              CacheTablesCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            url: url,
            key: key,
            relativePath: relativePath,
            eTag: eTag,
            validTill: validTill,
            touched: touched,
            length: length,
          ),
          createCompanionCallback: ({
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> id = const Value.absent(),
            required String url,
            required String key,
            required String relativePath,
            Value<String?> eTag = const Value.absent(),
            required DateTime validTill,
            Value<DateTime?> touched = const Value.absent(),
            Value<int?> length = const Value.absent(),
          }) =>
              CacheTablesCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            url: url,
            key: key,
            relativePath: relativePath,
            eTag: eTag,
            validTill: validTill,
            touched: touched,
            length: length,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CacheTablesTable,
    CacheDrift,
    $$CacheTablesTableFilterComposer,
    $$CacheTablesTableOrderingComposer,
    $$CacheTablesTableAnnotationComposer,
    $$CacheTablesTableCreateCompanionBuilder,
    $$CacheTablesTableUpdateCompanionBuilder,
    (CacheDrift, BaseReferences<_$AppDatabase, $CacheTablesTable, CacheDrift>),
    CacheDrift,
    PrefetchHooks Function()>;
typedef $$DioCacheTablesTableCreateCompanionBuilder = DioCacheTablesCompanion
    Function({
  required String cacheKey,
  Value<DateTime?> date,
  Value<String?> cacheControl,
  Value<Uint8List?> content,
  Value<String?> eTag,
  Value<DateTime?> expires,
  Value<Uint8List?> headers,
  Value<String?> lastModified,
  Value<DateTime?> maxStale,
  required int priority,
  Value<DateTime?> requestDate,
  required DateTime responseDate,
  required String url,
  Value<int?> statusCode,
  Value<int> rowid,
});
typedef $$DioCacheTablesTableUpdateCompanionBuilder = DioCacheTablesCompanion
    Function({
  Value<String> cacheKey,
  Value<DateTime?> date,
  Value<String?> cacheControl,
  Value<Uint8List?> content,
  Value<String?> eTag,
  Value<DateTime?> expires,
  Value<Uint8List?> headers,
  Value<String?> lastModified,
  Value<DateTime?> maxStale,
  Value<int> priority,
  Value<DateTime?> requestDate,
  Value<DateTime> responseDate,
  Value<String> url,
  Value<int?> statusCode,
  Value<int> rowid,
});

class $$DioCacheTablesTableFilterComposer
    extends Composer<_$AppDatabase, $DioCacheTablesTable> {
  $$DioCacheTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cacheControl => $composableBuilder(
      column: $table.cacheControl, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eTag => $composableBuilder(
      column: $table.eTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expires => $composableBuilder(
      column: $table.expires, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get maxStale => $composableBuilder(
      column: $table.maxStale, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get responseDate => $composableBuilder(
      column: $table.responseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statusCode => $composableBuilder(
      column: $table.statusCode, builder: (column) => ColumnFilters(column));
}

class $$DioCacheTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $DioCacheTablesTable> {
  $$DioCacheTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cacheControl => $composableBuilder(
      column: $table.cacheControl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eTag => $composableBuilder(
      column: $table.eTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expires => $composableBuilder(
      column: $table.expires, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get headers => $composableBuilder(
      column: $table.headers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get maxStale => $composableBuilder(
      column: $table.maxStale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get responseDate => $composableBuilder(
      column: $table.responseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statusCode => $composableBuilder(
      column: $table.statusCode, builder: (column) => ColumnOrderings(column));
}

class $$DioCacheTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DioCacheTablesTable> {
  $$DioCacheTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get cacheControl => $composableBuilder(
      column: $table.cacheControl, builder: (column) => column);

  GeneratedColumn<Uint8List> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get eTag =>
      $composableBuilder(column: $table.eTag, builder: (column) => column);

  GeneratedColumn<DateTime> get expires =>
      $composableBuilder(column: $table.expires, builder: (column) => column);

  GeneratedColumn<Uint8List> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);

  GeneratedColumn<DateTime> get maxStale =>
      $composableBuilder(column: $table.maxStale, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get requestDate => $composableBuilder(
      column: $table.requestDate, builder: (column) => column);

  GeneratedColumn<DateTime> get responseDate => $composableBuilder(
      column: $table.responseDate, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get statusCode => $composableBuilder(
      column: $table.statusCode, builder: (column) => column);
}

class $$DioCacheTablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DioCacheTablesTable,
    DioCacheDrift,
    $$DioCacheTablesTableFilterComposer,
    $$DioCacheTablesTableOrderingComposer,
    $$DioCacheTablesTableAnnotationComposer,
    $$DioCacheTablesTableCreateCompanionBuilder,
    $$DioCacheTablesTableUpdateCompanionBuilder,
    (
      DioCacheDrift,
      BaseReferences<_$AppDatabase, $DioCacheTablesTable, DioCacheDrift>
    ),
    DioCacheDrift,
    PrefetchHooks Function()> {
  $$DioCacheTablesTableTableManager(
      _$AppDatabase db, $DioCacheTablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DioCacheTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DioCacheTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DioCacheTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cacheKey = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            Value<String?> cacheControl = const Value.absent(),
            Value<Uint8List?> content = const Value.absent(),
            Value<String?> eTag = const Value.absent(),
            Value<DateTime?> expires = const Value.absent(),
            Value<Uint8List?> headers = const Value.absent(),
            Value<String?> lastModified = const Value.absent(),
            Value<DateTime?> maxStale = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime?> requestDate = const Value.absent(),
            Value<DateTime> responseDate = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int?> statusCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DioCacheTablesCompanion(
            cacheKey: cacheKey,
            date: date,
            cacheControl: cacheControl,
            content: content,
            eTag: eTag,
            expires: expires,
            headers: headers,
            lastModified: lastModified,
            maxStale: maxStale,
            priority: priority,
            requestDate: requestDate,
            responseDate: responseDate,
            url: url,
            statusCode: statusCode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cacheKey,
            Value<DateTime?> date = const Value.absent(),
            Value<String?> cacheControl = const Value.absent(),
            Value<Uint8List?> content = const Value.absent(),
            Value<String?> eTag = const Value.absent(),
            Value<DateTime?> expires = const Value.absent(),
            Value<Uint8List?> headers = const Value.absent(),
            Value<String?> lastModified = const Value.absent(),
            Value<DateTime?> maxStale = const Value.absent(),
            required int priority,
            Value<DateTime?> requestDate = const Value.absent(),
            required DateTime responseDate,
            required String url,
            Value<int?> statusCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DioCacheTablesCompanion.insert(
            cacheKey: cacheKey,
            date: date,
            cacheControl: cacheControl,
            content: content,
            eTag: eTag,
            expires: expires,
            headers: headers,
            lastModified: lastModified,
            maxStale: maxStale,
            priority: priority,
            requestDate: requestDate,
            responseDate: responseDate,
            url: url,
            statusCode: statusCode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DioCacheTablesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DioCacheTablesTable,
    DioCacheDrift,
    $$DioCacheTablesTableFilterComposer,
    $$DioCacheTablesTableOrderingComposer,
    $$DioCacheTablesTableAnnotationComposer,
    $$DioCacheTablesTableCreateCompanionBuilder,
    $$DioCacheTablesTableUpdateCompanionBuilder,
    (
      DioCacheDrift,
      BaseReferences<_$AppDatabase, $DioCacheTablesTable, DioCacheDrift>
    ),
    DioCacheDrift,
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
  $$CacheTablesTableTableManager get cacheTables =>
      $$CacheTablesTableTableManager(_db, _db.cacheTables);
  $$DioCacheTablesTableTableManager get dioCacheTables =>
      $$DioCacheTablesTableTableManager(_db, _db.dioCacheTables);
}
