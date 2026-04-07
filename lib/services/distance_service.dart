import 'package:geolocator/geolocator.dart';

class DistanceService {

  static double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng) {

    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // KM
  }
}