import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../use_case/list_tag_use_case.dart';
import '../use_case/listen_list_tag_use_case.dart';

class TagsManager implements ListenListTagUseCase {
  final _listTagsSubject = BehaviorSubject<List<Tag>>();

  final ListTagUseCase _listTagUseCase;

  TagsManager({
    required ListTagUseCase listTagUseCase,
  })  : _listTagUseCase = listTagUseCase {
    _update(Timer.periodic(const Duration(minutes: 5), _update));
  }

  @override
  ValueStream<List<Tag>> get listTagsStream => _listTagsSubject.stream;

  void _update(Timer t) async {
    final result = await _listTagUseCase.execute();

    if (result is Success<List<Tag>>) {
      _listTagsSubject.add(result.data);
    }
  }
}
