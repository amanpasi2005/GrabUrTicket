import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final _bookings = FirebaseFirestore.instance.collection("bookings");

  Future<void> saveBooking({
    required String userId,
    required String movieTitle,
    required String theatre,
    required String showDate,
    required String showTime,
    required String seats,
    required int amount,
    required String paymentId,
  }) async {
    await _bookings.add({
      "userId": userId,
      "movieTitle": movieTitle,
      "theatre": theatre,
      "showDate": showDate,
      "showTime": showTime,
      "seats": seats,
      "amount": amount,
      "paymentId": paymentId,
      "createdAt": DateTime.now(),
    });
  }
}
