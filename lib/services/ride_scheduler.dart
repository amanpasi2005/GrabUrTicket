import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class RideScheduler {
  static const int exitBufferMinutes = 15;

  static Future<void> scheduleRide({
    required String bookingId,
    required String movieTitle,
    required String theatre,
    required String movieMetadata,

    required String showDateValue,
    required String showTimeValue,

    required String rideType,
    required String pickupLocation,
    required String dropLocation,
    required double distanceKm,
    required String rideDirection,
  }) async {

    final bookingSnap = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (!bookingSnap.exists) return;

    final data = bookingSnap.data()!;
    final bool autoRideEnabled = data['autoRideEnabled'] == true;

    if (!autoRideEnabled) return;

    final String dateValue = showDateValue;
    final String timeValue = showTimeValue;

    final DateTime startDateTime =
    _parseDateAndTime(dateValue, timeValue);

    final int durationMinutes = _parseDuration(movieMetadata);

    DateTime pickupTime;

    if (rideDirection == "goToTheatre") {
      // pickup BEFORE movie starts
      pickupTime = startDateTime.subtract(
        const Duration(minutes: 30),
      );
    } else {
      // return AFTER movie ends
      pickupTime = startDateTime.add(
        Duration(minutes: durationMinutes + exitBufferMinutes),
      );
    }

    final double fare = _calculateFare(rideType, distanceKm);

    await FirebaseFirestore.instance
        .collection('ride_schedules')
        .doc("${bookingId}_$rideDirection")
        .set({
      'bookingId': bookingId,
      'movieTitle': movieTitle,
      'theatre': theatre,
      'userId': bookingSnap.data()?['userId'],

      'rideType': rideType,
      'rideDirection': rideDirection, // NEW

      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,

      'estimatedDistance': distanceKm,
      'estimatedFare': fare,

      'pickupTime': pickupTime,
      'status': 'scheduled',

      'driverName': null,
      'driverPhone': null,
      'vehicleNumber': null,

      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🚀 AUTO DRIVER ASSIGNMENT
    Future.delayed(const Duration(seconds: 3), () async {

      final result = await _findNearestDriver();

      if (result == null) return;

      final driver = result['data'];
      final driverId = result['id'];

      await FirebaseFirestore.instance
          .collection('ride_schedules')
          .doc("${bookingId}_$rideDirection")
          .update({

        'driverName': driver['name'],
        'driverPhone': driver['phone'],
        'vehicleNumber': driver['vehicle'],
        'status': 'driver_assigned',

        // optional (for map)
        'driverLat': driver['lat'],
        'driverLng': driver['lng'],
      });

      // 🔥 mark driver busy
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        'isAvailable': false,
      });

      // 🚀 start movement simulation
      startDriverSimulation("${bookingId}_$rideDirection");

    });

  }

  // =================================================

  static double _calculateFare(String type, double distance) {
    double rate = 10;

    switch (type) {
      case 'bike':
        rate = 8;
        break;
      case 'auto':
        rate = 12;
        break;
      case 'mini':
        rate = 15;
        break;
      case 'prime':
        rate = 20;
        break;
    }

    return distance * rate;
  }

  // =================================================

  static DateTime _parseDateAndTime(String date, String time) {

    try {

      DateTime parsedDate = DateTime.parse(date);

      int hour = 18;
      int minute = 0;

      /// CASE 1: Time like "09:30"
      if (time.contains(":") && !time.toLowerCase().contains("am") && !time.toLowerCase().contains("pm")) {

        final parts = time.split(":");

        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);

      }

      /// CASE 2: Words like "Morning"
      else if (time.toLowerCase().contains("morning")) {
        hour = 9;
      }

      else if (time.toLowerCase().contains("afternoon")) {
        hour = 14;
      }

      else if (time.toLowerCase().contains("evening")) {
        hour = 18;
      }

      else if (time.toLowerCase().contains("night")) {
        hour = 21;
      }

      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        hour,
        minute,
      );

    } catch (e) {

      print("Date parse error: $e");

      return DateTime.now().add(const Duration(minutes: 30));

    }
  }

  // =================================================

  static int _parseDuration(String metadata) {
    int hours = 0;
    int minutes = 0;

    final h = RegExp(r'(\d+)h').firstMatch(metadata);
    final m = RegExp(r'(\d+)m').firstMatch(metadata);

    if (h != null) hours = int.parse(h.group(1)!);
    if (m != null) minutes = int.parse(m.group(1)!);

    return (hours * 60) + minutes;
  }

  static void startDriverSimulation(String rideId) {

    double driverLat = 19.0900;
    double driverLng = 72.8800;

    const double pickupLat = 19.0760;
    const double pickupLng = 72.8777;

    const step = 0.0005;

    Future.doWhile(() async {

      await Future.delayed(const Duration(seconds: 3));

      if ((driverLat - pickupLat).abs() < 0.0005 &&
          (driverLng - pickupLng).abs() < 0.0005) {

        await FirebaseFirestore.instance
            .collection('ride_schedules')
            .doc(rideId)
            .update({
          'status': 'arrived',
        });

        return false;
      }

      if (driverLat > pickupLat) driverLat -= step;
      if (driverLat < pickupLat) driverLat += step;

      if (driverLng > pickupLng) driverLng -= step;
      if (driverLng < pickupLng) driverLng += step;

      await FirebaseFirestore.instance
          .collection('ride_schedules')
          .doc(rideId)
          .update({
        'driverLat': driverLat,
        'driverLng': driverLng,
      });

      return true;
    });
  }

  static double _calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const double R = 6371;

    final dLat = (lat2 - lat1) * 3.141592653589793 / 180;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180;

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(lat1 * 3.141592653589793 / 180) *
                cos(lat2 * 3.141592653589793 / 180) *
                (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  static Future<Map<String, dynamic>?> _findNearestDriver() async {

    final snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('isAvailable', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return null;

    Map<String, dynamic>? nearestDriver;
    String? nearestDriverId;

    double minDistance = double.infinity;

    // 👉 TEMP USER LOCATION (Mumbai)
    const userLat = 19.0760;
    const userLng = 72.8777;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final driverLat = data['lat'];
      final driverLng = data['lng'];

      final distance = _calculateDistance(
        userLat,
        userLng,
        driverLat,
        driverLng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestDriver = data;
        nearestDriverId = doc.id;
      }
    }

    if (nearestDriver == null) return null;

    return {
      "data": nearestDriver,
      "id": nearestDriverId
    };
  }

  static Future<Map<String, dynamic>?> findNearestDriver({
    required double userLat,
    required double userLng,
  }) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('isAvailable', isEqualTo: true)
        .get();

    double minDistance = double.infinity;
    Map<String, dynamic>? nearestDriver;
    String? nearestDriverId;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final driverLat = data['lat'];
      final driverLng = data['lng'];

      final distance = _calculateDistance(
        userLat,
        userLng,
        driverLat,
        driverLng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestDriver = data;
        nearestDriverId = doc.id;
      }
    }

    if (nearestDriver == null) return null;

    return {
      'data': nearestDriver,
      'id': nearestDriverId,
    };
  }
}