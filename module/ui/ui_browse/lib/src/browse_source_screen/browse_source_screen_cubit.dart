import 'package:domain_manga/domain_manga.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'package:core_storage/core_storage.dart';
import 'package:drift/drift.dart';

import 'browse_source_screen_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenState>
    with AutoSubscriptionMixin {
  final UpdateSourcesUseCase _updateSourceUseCase;
  final CustomSourceDao _customSourceDao;

  BrowseSourceScreenCubit({
    BrowseSourceScreenState initialState = const BrowseSourceScreenState(),
    required ListenSourcesUseCase listenSourceUseCase,
    required UpdateSourcesUseCase updateSourceUseCase,
    required CustomSourceDao customSourceDao,
  })  : _updateSourceUseCase = updateSourceUseCase,
        _customSourceDao = customSourceDao,
        super(initialState) {
    addSubscription(
      listenSourceUseCase.sourceStateStream.distinct().listen(_updateSources),
    );
  }

  void _updateSources(List<SourceExternal> sources) {
    emit(state.copyWith(sources: sources));
  }

  /// **Purpose:**
  /// Downloads, tests, and saves a custom source script.
  /// 
  /// **Usage:**
  /// Provide a raw script [url] containing Dart scraper logic. This uses Dio to download
  /// the script, validates it by parsing it into a [CustomSourceExternal], saves it via 
  /// [_customSourceDao], and finally calls [_updateSourceUseCase] to force a UI refresh.
  Future<void> addCustomSource(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final code = response.data.toString();
        // Test it
        final customSource = CustomSourceExternal.fromScript(code);
        // Insert into DB
        await _customSourceDao.insertSource(
          CustomSourceTablesCompanion.insert(
            name: customSource.name,
            baseUrl: customSource.baseUrl,
            iconUrl: Value(customSource.iconUrl),
            scriptUrl: url,
            scriptCode: code,
          ),
        );
        // Add to global list if not already there
        if (!Sources.values.any((s) => s.name == customSource.name)) {
          Sources.values.add(customSource);
        }
        // Force refresh
        await _updateSourceUseCase.updateSources(sources: Sources.values);
      } else {
        // Handle error? Just throw for now
        throw Exception('Failed to load script');
      }
    } catch (e) {
      rethrow;
    }
  }
}
