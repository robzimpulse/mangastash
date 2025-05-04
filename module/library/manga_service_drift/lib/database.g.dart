// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MangaTablesTable extends MangaTables with TableInfo<$MangaTablesTable, MangaTable>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MangaTablesTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'manga_tables';
@override
Set<GeneratedColumn> get $primaryKey => const {};@override MangaTable map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return MangaTable();
}
@override
$MangaTablesTable createAlias(String alias) {
return $MangaTablesTable(attachedDatabase, alias);}}class MangaTable extends DataClass implements Insertable<MangaTable> 
{
const MangaTable({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MangaTablesCompanion toCompanion(bool nullToAbsent) {
return MangaTablesCompanion();
}
factory MangaTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return MangaTable();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}MangaTable copyWith({}) => MangaTable();MangaTable copyWithCompanion(MangaTablesCompanion data) {
return MangaTable(
);
}
@override
String toString() {return (StringBuffer('MangaTable(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is MangaTable);
}class MangaTablesCompanion extends UpdateCompanion<MangaTable> {
final Value<int> rowid;
const MangaTablesCompanion({this.rowid = const Value.absent(),});
MangaTablesCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<MangaTable> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MangaTablesCompanion copyWith({Value<int>? rowid}) {
return MangaTablesCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MangaTablesCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $MangaChapterTablesTable extends MangaChapterTables with TableInfo<$MangaChapterTablesTable, MangaChapterTable>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MangaChapterTablesTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'manga_chapter_tables';
@override
Set<GeneratedColumn> get $primaryKey => const {};@override MangaChapterTable map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return MangaChapterTable();
}
@override
$MangaChapterTablesTable createAlias(String alias) {
return $MangaChapterTablesTable(attachedDatabase, alias);}}class MangaChapterTable extends DataClass implements Insertable<MangaChapterTable> 
{
const MangaChapterTable({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MangaChapterTablesCompanion toCompanion(bool nullToAbsent) {
return MangaChapterTablesCompanion();
}
factory MangaChapterTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return MangaChapterTable();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}MangaChapterTable copyWith({}) => MangaChapterTable();MangaChapterTable copyWithCompanion(MangaChapterTablesCompanion data) {
return MangaChapterTable(
);
}
@override
String toString() {return (StringBuffer('MangaChapterTable(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is MangaChapterTable);
}class MangaChapterTablesCompanion extends UpdateCompanion<MangaChapterTable> {
final Value<int> rowid;
const MangaChapterTablesCompanion({this.rowid = const Value.absent(),});
MangaChapterTablesCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<MangaChapterTable> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MangaChapterTablesCompanion copyWith({Value<int>? rowid}) {
return MangaChapterTablesCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MangaChapterTablesCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $MangaChapterImageTablesTable extends MangaChapterImageTables with TableInfo<$MangaChapterImageTablesTable, MangaChapterImageTable>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MangaChapterImageTablesTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'manga_chapter_image_tables';
@override
Set<GeneratedColumn> get $primaryKey => const {};@override MangaChapterImageTable map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return MangaChapterImageTable();
}
@override
$MangaChapterImageTablesTable createAlias(String alias) {
return $MangaChapterImageTablesTable(attachedDatabase, alias);}}class MangaChapterImageTable extends DataClass implements Insertable<MangaChapterImageTable> 
{
const MangaChapterImageTable({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MangaChapterImageTablesCompanion toCompanion(bool nullToAbsent) {
return MangaChapterImageTablesCompanion();
}
factory MangaChapterImageTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return MangaChapterImageTable();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}MangaChapterImageTable copyWith({}) => MangaChapterImageTable();MangaChapterImageTable copyWithCompanion(MangaChapterImageTablesCompanion data) {
return MangaChapterImageTable(
);
}
@override
String toString() {return (StringBuffer('MangaChapterImageTable(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is MangaChapterImageTable);
}class MangaChapterImageTablesCompanion extends UpdateCompanion<MangaChapterImageTable> {
final Value<int> rowid;
const MangaChapterImageTablesCompanion({this.rowid = const Value.absent(),});
MangaChapterImageTablesCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<MangaChapterImageTable> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MangaChapterImageTablesCompanion copyWith({Value<int>? rowid}) {
return MangaChapterImageTablesCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MangaChapterImageTablesCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
class $MangaTagTablesTable extends MangaTagTables with TableInfo<$MangaTagTablesTable, MangaTagTable>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$MangaTagTablesTable(this.attachedDatabase, [this._alias]);
@override
List<GeneratedColumn> get $columns => [];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'manga_tag_tables';
@override
Set<GeneratedColumn> get $primaryKey => const {};@override MangaTagTable map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return MangaTagTable();
}
@override
$MangaTagTablesTable createAlias(String alias) {
return $MangaTagTablesTable(attachedDatabase, alias);}}class MangaTagTable extends DataClass implements Insertable<MangaTagTable> 
{
const MangaTagTable({});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};return map; 
}
MangaTagTablesCompanion toCompanion(bool nullToAbsent) {
return MangaTagTablesCompanion();
}
factory MangaTagTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return MangaTagTable();}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
};}MangaTagTable copyWith({}) => MangaTagTable();MangaTagTable copyWithCompanion(MangaTagTablesCompanion data) {
return MangaTagTable(
);
}
@override
String toString() {return (StringBuffer('MangaTagTable(')..write(')')).toString();}
@override
 int get hashCode => identityHashCode(this);@override
bool operator ==(Object other) => identical(this, other) || (other is MangaTagTable);
}class MangaTagTablesCompanion extends UpdateCompanion<MangaTagTable> {
final Value<int> rowid;
const MangaTagTablesCompanion({this.rowid = const Value.absent(),});
MangaTagTablesCompanion.insert({this.rowid = const Value.absent(),});
static Insertable<MangaTagTable> custom({Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (rowid != null)'rowid': rowid,});
}MangaTagTablesCompanion copyWith({Value<int>? rowid}) {
return MangaTagTablesCompanion(rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('MangaTagTablesCompanion(')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $MangaTablesTable mangaTables = $MangaTablesTable(this);
late final $MangaChapterTablesTable mangaChapterTables = $MangaChapterTablesTable(this);
late final $MangaChapterImageTablesTable mangaChapterImageTables = $MangaChapterImageTablesTable(this);
late final $MangaTagTablesTable mangaTagTables = $MangaTagTablesTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [mangaTables, mangaChapterTables, mangaChapterImageTables, mangaTagTables];
}
typedef $$MangaTablesTableCreateCompanionBuilder = MangaTablesCompanion Function({Value<int> rowid,});
typedef $$MangaTablesTableUpdateCompanionBuilder = MangaTablesCompanion Function({Value<int> rowid,});
class $$MangaTablesTableFilterComposer extends Composer<
        _$AppDatabase,
        $MangaTablesTable> {
        $$MangaTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTablesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $MangaTablesTable> {
        $$MangaTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTablesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $MangaTablesTable> {
        $$MangaTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTablesTableTableManager extends RootTableManager    <_$AppDatabase,
    $MangaTablesTable,
    MangaTable,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaTable,BaseReferences<_$AppDatabase,$MangaTablesTable,MangaTable>),
    MangaTable,
    PrefetchHooks Function()
    > {
    $$MangaTablesTableTableManager(_$AppDatabase db, $MangaTablesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$MangaTablesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$MangaTablesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$MangaTablesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaTablesCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaTablesCompanion.insert(rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$MangaTablesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $MangaTablesTable,
    MangaTable,
    $$MangaTablesTableFilterComposer,
    $$MangaTablesTableOrderingComposer,
    $$MangaTablesTableAnnotationComposer,
    $$MangaTablesTableCreateCompanionBuilder,
    $$MangaTablesTableUpdateCompanionBuilder,
    (MangaTable,BaseReferences<_$AppDatabase,$MangaTablesTable,MangaTable>),
    MangaTable,
    PrefetchHooks Function()
    >;typedef $$MangaChapterTablesTableCreateCompanionBuilder = MangaChapterTablesCompanion Function({Value<int> rowid,});
typedef $$MangaChapterTablesTableUpdateCompanionBuilder = MangaChapterTablesCompanion Function({Value<int> rowid,});
class $$MangaChapterTablesTableFilterComposer extends Composer<
        _$AppDatabase,
        $MangaChapterTablesTable> {
        $$MangaChapterTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterTablesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $MangaChapterTablesTable> {
        $$MangaChapterTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterTablesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $MangaChapterTablesTable> {
        $$MangaChapterTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterTablesTableTableManager extends RootTableManager    <_$AppDatabase,
    $MangaChapterTablesTable,
    MangaChapterTable,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (MangaChapterTable,BaseReferences<_$AppDatabase,$MangaChapterTablesTable,MangaChapterTable>),
    MangaChapterTable,
    PrefetchHooks Function()
    > {
    $$MangaChapterTablesTableTableManager(_$AppDatabase db, $MangaChapterTablesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$MangaChapterTablesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$MangaChapterTablesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$MangaChapterTablesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaChapterTablesCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaChapterTablesCompanion.insert(rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$MangaChapterTablesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $MangaChapterTablesTable,
    MangaChapterTable,
    $$MangaChapterTablesTableFilterComposer,
    $$MangaChapterTablesTableOrderingComposer,
    $$MangaChapterTablesTableAnnotationComposer,
    $$MangaChapterTablesTableCreateCompanionBuilder,
    $$MangaChapterTablesTableUpdateCompanionBuilder,
    (MangaChapterTable,BaseReferences<_$AppDatabase,$MangaChapterTablesTable,MangaChapterTable>),
    MangaChapterTable,
    PrefetchHooks Function()
    >;typedef $$MangaChapterImageTablesTableCreateCompanionBuilder = MangaChapterImageTablesCompanion Function({Value<int> rowid,});
typedef $$MangaChapterImageTablesTableUpdateCompanionBuilder = MangaChapterImageTablesCompanion Function({Value<int> rowid,});
class $$MangaChapterImageTablesTableFilterComposer extends Composer<
        _$AppDatabase,
        $MangaChapterImageTablesTable> {
        $$MangaChapterImageTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterImageTablesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $MangaChapterImageTablesTable> {
        $$MangaChapterImageTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterImageTablesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $MangaChapterImageTablesTable> {
        $$MangaChapterImageTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaChapterImageTablesTableTableManager extends RootTableManager    <_$AppDatabase,
    $MangaChapterImageTablesTable,
    MangaChapterImageTable,
    $$MangaChapterImageTablesTableFilterComposer,
    $$MangaChapterImageTablesTableOrderingComposer,
    $$MangaChapterImageTablesTableAnnotationComposer,
    $$MangaChapterImageTablesTableCreateCompanionBuilder,
    $$MangaChapterImageTablesTableUpdateCompanionBuilder,
    (MangaChapterImageTable,BaseReferences<_$AppDatabase,$MangaChapterImageTablesTable,MangaChapterImageTable>),
    MangaChapterImageTable,
    PrefetchHooks Function()
    > {
    $$MangaChapterImageTablesTableTableManager(_$AppDatabase db, $MangaChapterImageTablesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$MangaChapterImageTablesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$MangaChapterImageTablesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$MangaChapterImageTablesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaChapterImageTablesCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaChapterImageTablesCompanion.insert(rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$MangaChapterImageTablesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $MangaChapterImageTablesTable,
    MangaChapterImageTable,
    $$MangaChapterImageTablesTableFilterComposer,
    $$MangaChapterImageTablesTableOrderingComposer,
    $$MangaChapterImageTablesTableAnnotationComposer,
    $$MangaChapterImageTablesTableCreateCompanionBuilder,
    $$MangaChapterImageTablesTableUpdateCompanionBuilder,
    (MangaChapterImageTable,BaseReferences<_$AppDatabase,$MangaChapterImageTablesTable,MangaChapterImageTable>),
    MangaChapterImageTable,
    PrefetchHooks Function()
    >;typedef $$MangaTagTablesTableCreateCompanionBuilder = MangaTagTablesCompanion Function({Value<int> rowid,});
typedef $$MangaTagTablesTableUpdateCompanionBuilder = MangaTagTablesCompanion Function({Value<int> rowid,});
class $$MangaTagTablesTableFilterComposer extends Composer<
        _$AppDatabase,
        $MangaTagTablesTable> {
        $$MangaTagTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTagTablesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $MangaTagTablesTable> {
        $$MangaTagTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTagTablesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $MangaTagTablesTable> {
        $$MangaTagTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          
        }
      class $$MangaTagTablesTableTableManager extends RootTableManager    <_$AppDatabase,
    $MangaTagTablesTable,
    MangaTagTable,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (MangaTagTable,BaseReferences<_$AppDatabase,$MangaTagTablesTable,MangaTagTable>),
    MangaTagTable,
    PrefetchHooks Function()
    > {
    $$MangaTagTablesTableTableManager(_$AppDatabase db, $MangaTagTablesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$MangaTagTablesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$MangaTagTablesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$MangaTagTablesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaTagTablesCompanion(rowid: rowid,),
        createCompanionCallback: ({Value<int> rowid = const Value.absent(),})=> MangaTagTablesCompanion.insert(rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$MangaTagTablesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $MangaTagTablesTable,
    MangaTagTable,
    $$MangaTagTablesTableFilterComposer,
    $$MangaTagTablesTableOrderingComposer,
    $$MangaTagTablesTableAnnotationComposer,
    $$MangaTagTablesTableCreateCompanionBuilder,
    $$MangaTagTablesTableUpdateCompanionBuilder,
    (MangaTagTable,BaseReferences<_$AppDatabase,$MangaTagTablesTable,MangaTagTable>),
    MangaTagTable,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$MangaTablesTableTableManager get mangaTables => $$MangaTablesTableTableManager(_db, _db.mangaTables);
$$MangaChapterTablesTableTableManager get mangaChapterTables => $$MangaChapterTablesTableTableManager(_db, _db.mangaChapterTables);
$$MangaChapterImageTablesTableTableManager get mangaChapterImageTables => $$MangaChapterImageTablesTableTableManager(_db, _db.mangaChapterImageTables);
$$MangaTagTablesTableTableManager get mangaTagTables => $$MangaTagTablesTableTableManager(_db, _db.mangaTagTables);
}
