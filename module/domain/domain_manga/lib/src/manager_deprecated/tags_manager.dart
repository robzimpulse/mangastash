import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../use_case_deprecated/list_tag_use_case.dart';
import '../use_case_deprecated/listen_list_tag_use_case.dart';

class TagsManagerDeprecated implements ListenListTagUseCaseDeprecated {
  final _listTagsSubject = BehaviorSubject<List<MangaTagDeprecated>>();

  final ListTagUseCaseDeprecated _listTagUseCase;

  TagsManagerDeprecated({
    required ListTagUseCaseDeprecated listTagUseCase,
  }) : _listTagUseCase = listTagUseCase {
    _update(Timer.periodic(const Duration(minutes: 5), _update));
  }

  @override
  ValueStream<List<MangaTagDeprecated>> get listTagsStream => _listTagsSubject.stream;

  void _update(Timer t) async {
    final result = await _listTagUseCase.execute();

    if (result is Success<List<MangaTagDeprecated>>) {
      _listTagsSubject.add(result.data);
    }
  }
}
