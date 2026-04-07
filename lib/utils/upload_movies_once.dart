import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/constants.dart';

class MovieUploader {
  static Future<void> uploadMoviesOnce() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (final movie in movieData) {
      final String title = movie['title'];

      // Use title as document ID (safe & readable)
      final docId =
      title.toLowerCase().replaceAll(' ', '_').replaceAll(':', '');

      final docRef = firestore.collection('movies').doc(docId);

      batch.set(docRef, {
        'title': movie['title'],
        'imageUrl': movie['imageUrl'],
        'bigPicture': movie['bigPicture'],
        'rating': movie['rating'],
        'ratingCount': movie['ratingCount'],
        'metadata': movie['metadata'],
        'screenType': movie['screenType'],
        'language': movie['language'],
        'about': movie['about'],

        // 🔥 last minute deal fields
        'lastMinuteDeal': false,
        'discountPercent': 0,

        // meta
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
