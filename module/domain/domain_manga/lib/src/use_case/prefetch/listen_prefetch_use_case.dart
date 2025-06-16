import 'package:core_storage/core_storage.dart';

abstract class ListenPrefetchUseCase {

  Stream<Set<String>> get chapterIdsStream;

  Stream<Set<String>> get mangaIdsStream;

  Stream<List<JobModel>> get jobsStream;
}