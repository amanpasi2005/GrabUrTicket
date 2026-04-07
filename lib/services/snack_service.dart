import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SnackService {
  final _firestore = FirebaseFirestore.instance;

  Future<String> placeSnackOrder({
    required String bookingId,
    required String movieTitle,
    required String theatre,
    required String seatNumber,
    required List<Map<String, dynamic>> items,
    required int deliveryAfterMinutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    int total = 0;
    for (var item in items) {
      total += (item['price'] as int) * (item['qty'] as int);
    }

    final docRef =
    await _firestore.collection('snack_orders').add({
      'userId': user.uid,
      'bookingId': bookingId,
      'movieTitle': movieTitle,
      'theatre': theatre,
      'seatNumber': seatNumber,
      'items': items,
      'totalAmount': total,
      'deliveryAfterMinutes': deliveryAfterMinutes,
      'status': 'preparing',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id; // ✅ THIS FIXES YOUR ERROR
    simulateSnackProgress(docRef.id);
  }

  Future<void> simulateSnackProgress(String orderId) async {
    final ref = _firestore.collection('snack_orders').doc(orderId);

    await Future.delayed(const Duration(minutes: 2));
    await ref.update({'status': 'ready'});

    await Future.delayed(const Duration(minutes: 2));
    await ref.update({'status': 'on_the_way'});

    await Future.delayed(const Duration(minutes: 2));
    await ref.update({'status': 'delivered'});
  }


}
