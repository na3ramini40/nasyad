import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/place.dart';

class DeviceSearchHit extends Equatable {
  const DeviceSearchHit({required this.device, required this.pathSegments});

  final Device device;
  final List<String> pathSegments;

  @override
  List<Object?> get props => [device, pathSegments];
}

class SearchResults extends Equatable {
  const SearchResults({
    required this.devices,
    required this.birthdays,
    required this.places,
  });

  final List<DeviceSearchHit> devices;
  final List<Birthday> birthdays;
  final List<Place> places;

  bool get isEmpty => devices.isEmpty && birthdays.isEmpty && places.isEmpty;

  @override
  List<Object?> get props => [devices, birthdays, places];
}
