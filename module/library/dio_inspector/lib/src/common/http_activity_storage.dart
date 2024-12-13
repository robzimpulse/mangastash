import 'package:rxdart/rxdart.dart';

import '../model/http_activity_model.dart';
import '../model/http_error_model.dart';
import '../model/http_response_model.dart';

class HttpActivityStorage {
  final BehaviorSubject<Map<int, HttpActivityModel>> _activities;

  HttpActivityStorage() : _activities = BehaviorSubject.seeded({});

  Stream<List<HttpActivityModel>> get activities {
    return _activities.stream.map((e) => e.values.toList());
  }

  void addActivity({required HttpActivityModel activity}) {
    _activities.add(
      Map.of(_activities.value)..putIfAbsent(activity.id, () => activity),
    );
  }

  void addResponse({required int id, required HttpResponseModel response}) {
    _activities.add(
      Map.of(_activities.value)
        ..update(
          id,
          (value) => value.copyWith(response: response),
        ),
    );
  }

  void addError({required int id, required HttpErrorModel error}) {
    _activities.add(
      Map.of(_activities.value)
        ..update(
          id,
          (value) => value.copyWith(error: error, loading: false),
        ),
    );
  }

  void clear() => _activities.add({});
}
