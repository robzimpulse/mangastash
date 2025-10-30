import 'package:core_environment/core_environment.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTimezoneUseCase extends Mock implements GetTimeZoneUseCase {
  void setLocal({required String timezone, Duration delay = Duration.zero}) {
    when(
      () => local(),
    ).thenAnswer((_) => Future.delayed(delay, () => timezone));
  }

  void setLocalError({
    required Exception error,
    Duration delay = Duration.zero,
  }) {
    when(
      () => local(),
    ).thenAnswer((_) => Future.delayed(delay, () => throw error));
  }

  void setAvailable({
    required List<String> timezones,
    Duration delay = Duration.zero,
  }) {
    when(
      () => available(),
    ).thenAnswer((_) => Future.delayed(delay, () => timezones));
  }

  void setAvailableErrror({
    required Exception error,
    Duration delay = Duration.zero,
  }) {
    when(
      () => available(),
    ).thenAnswer((_) => Future.delayed(delay, () => throw error));
  }
}
