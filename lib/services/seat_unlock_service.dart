import 'package:cloud_firestore/cloud_firestore.dart';

class SeatUnlockService {

  static Future<void> releaseExpiredLocks() async {

    final now = DateTime.now();

    final locks = await FirebaseFirestore.instance
        .collection("seat_locks")
        .get();

    for (var doc in locks.docs) {

      final data = doc.data();

      final Timestamp ts = data['lockedAt'];

      final lockedTime = ts.toDate();

      if (now.difference(lockedTime).inMinutes >= 5) {

        await doc.reference.delete();

      }

    }

  }

}