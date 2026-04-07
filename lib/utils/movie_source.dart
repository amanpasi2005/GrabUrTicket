import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/constants.dart';

Future<List<Map<String, dynamic>>> getAllMovies() async {
  final snapshot =
  await FirebaseFirestore.instance.collection('movies').get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  // 🔁 fallback to constants
  return movieData;
}
