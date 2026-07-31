import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository repository;
  late HomeBloc bloc;

  setUp(() {
    repository = FakeDeviceRepository();
    bloc = HomeBloc(WatchDeviceSummariesUsecase(repository));
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('starts as HomeInitial', () {
    expect(bloc.state, const HomeInitial());
  });

  test('emits loading then loaded on start', () async {
    expectLater(
      bloc.stream,
      emitsInOrder([
        const HomeLoading(),
        isA<HomeLoaded>().having((s) => s.summaries, 'summaries', hasLength(1)),
      ]),
    );

    bloc.add(const HomeStarted());
    await Future<void>.delayed(Duration.zero);
    repository.emitSummaries([sampleSummary()]);
  });

  test('emits error when watch fails', () async {
    expectLater(
      bloc.stream,
      emitsThrough(isA<HomeError>()),
    );

    bloc.add(const HomeStarted());
    await Future<void>.delayed(Duration.zero);
    repository.emitError(Exception('boom'));
  });
}
