abstract class ListenPrefetchUseCase {
  Stream<Map<String, Set<String>>> get prefetchedStream;
}