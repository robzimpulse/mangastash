import 'package:drift/drift.dart';

import '../../manga_service_drift.dart';
import '../extension/non_empty_string_list_extension.dart';
import '../tables/cache_tables.dart';

part 'cache_dao.g.dart';

@DriftAccessor(
  tables: [
    CacheTables,
  ],
)
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(AppDatabase db) : super(db);

  List<OrderingTerm Function($CacheTablesTable)> get _clauses {
    return [
      (o) => OrderingTerm(expression: o.touched, mode: OrderingMode.desc),
      (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc),
    ];
  }

  SimpleSelectStatement<$CacheTablesTable, CacheDrift> get _selector {
    return select(cacheTables)..orderBy(_clauses);
  }

  DeleteStatement<$CacheTablesTable, CacheDrift> get _deleter {
    return delete(cacheTables);
  }

  UpdateStatement<$CacheTablesTable, CacheDrift> get _updater {
    return update(cacheTables);
  }

  Future<List<CacheDrift>> get all => _selector.get();

  Future<List<CacheDrift>> search({
    String? key,
    Duration? maxAge,
    int? limit,
    int? offset,
  }) {
    final selector = _selector;

    if (key != null) {
      selector.where((f) => f.key.equals(key));
    }

    if (maxAge != null) {
      selector.where(
        (f) => f.touched.isSmallerThanValue(DateTime.now().subtract(maxAge)),
      );
    }

    if (limit != null) {
      selector.limit(limit, offset: offset);
    }

    return transaction(() => selector.get());
  }

  Future<List<CacheDrift>> remove({List<int> ids = const []}) async {
    final selector = _deleter;

    if (ids.distinct.isNotEmpty) {
      selector.where((f) => f.id.isIn(ids.distinct));
    }

    return transaction(() => selector.goAndReturn());
  }

  Future<CacheDrift> add({required CacheTablesCompanion value}) {
    return transaction(
      () => into(cacheTables).insertReturning(
        value,
        onConflict: DoUpdate(
          (old) => value.copyWith(updatedAt: Value(DateTime.timestamp())),
        ),
      ),
    );
  }

  Future<List<CacheDrift>> modify({required CacheTablesCompanion value}) {
    final selector = _updater..whereSamePrimaryKey(value);
    return transaction(() => selector.writeReturning(value));
  }
}
