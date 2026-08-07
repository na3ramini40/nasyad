import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';
import 'package:nasyad/domain/services/transfer/transfer_data_handler.dart';

class PlaceTransferHandler implements TransferDataHandler {
  PlaceTransferHandler(this._places);

  final PlaceRepository _places;

  @override
  String get key => TransferSectionKey.places;

  @override
  Future<void> collectInto(
    ExportBundleDraft draft, {
    required ExportScopeKind scope,
    required List<String> deviceIds,
  }) async {
    // Global kind — always export all places regardless of device scope.
    draft.places = await _places.getAllPlaces();
  }

  @override
  bool hasDataIn(ExportBundle bundle) => bundle.places.isNotEmpty;

  @override
  Future<void> applyFrom(ExportBundle bundle) async {
    for (final place in bundle.places) {
      await _places.upsertPlace(place);
    }
  }
}
