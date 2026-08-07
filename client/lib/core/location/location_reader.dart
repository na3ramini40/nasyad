import 'package:geolocator/geolocator.dart';
import 'package:nasyad/domain/entities/geo_point.dart';

class LocationReader {
  const LocationReader();

  Future<GeoPoint?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return GeoPoint(latitude: position.latitude, longitude: position.longitude);
  }
}

/// Default map center when GPS is unavailable (Tehran).
const defaultMapCenter = GeoPoint(latitude: 35.6892, longitude: 51.3890);
