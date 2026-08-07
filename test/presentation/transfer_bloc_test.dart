import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/usecases/device/get_all_devices_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';
import 'package:nasyad/presentation/transfer/bloc/transfer_bloc.dart';

import '../helpers/fake_log_photo_storage.dart';
import '../helpers/fake_repositories.dart';
import '../helpers/fake_transfer_file_actions.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;
  late FakeTransferFileActions files;
  late TransferBloc bloc;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    files = FakeTransferFileActions();
    bloc = TransferBloc(
      getAllDevices: GetAllDevicesUsecase(devices),
      exportData: ExportDataUsecase(devices, logs, FakeLogPhotoStorage()),
      importData: ImportDataUsecase(devices),
      fileActions: files,
    );
  });

  tearDown(() async {
    await bloc.close();
    await devices.dispose();
    await logs.dispose();
  });

  test('loads devices on start', () async {
    devices.devices.add(sampleDevice());
    bloc.add(const TransferStarted());
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TransferState>()
            .having((s) => s.status, 'status', TransferStatus.ready)
            .having((s) => s.devices, 'devices', hasLength(1)),
      ),
    );
  });

  test('scope and device selection update canExport', () async {
    devices.devices.add(sampleDevice());
    bloc.add(const TransferStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(const TransferScopeChanged(ExportScopeKind.one));
    bloc.add(const TransferDeviceToggled('device-1'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.scope, ExportScopeKind.one);
    expect(bloc.state.selectedIds, {'device-1'});
    expect(bloc.state.canExport, isTrue);
  });

  test('share export succeeds', () async {
    devices.devices.add(sampleDevice());
    bloc.add(const TransferStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(const TransferShareRequested(noDevicesMessage: 'none'));
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TransferState>().having(
          (s) => s.feedback,
          'feedback',
          TransferFeedback.exportShared,
        ),
      ),
    );
    expect(files.lastSharedContent, isNotNull);
  });

  test('import preview and confirm', () async {
    final content = BundleCodec.encodeJson(sampleBundle());
    files.pickedFile = (content: content, name: 'backup.json');

    bloc.add(const TransferStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(const TransferPickImportRequested(invalidFileMessage: 'bad'));
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TransferState>().having(
          (s) => s.importPreview?.deviceCount,
          'preview',
          1,
        ),
      ),
    );

    bloc.add(const TransferImportConfirmed(invalidFileMessage: 'bad'));
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TransferState>().having(
          (s) => s.feedback,
          'feedback',
          TransferFeedback.importSuccess,
        ),
      ),
    );
  });

  test('format change updates state', () async {
    bloc.add(const TransferFormatChanged(ExportFormat.csv));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.format, ExportFormat.csv);
  });
}
