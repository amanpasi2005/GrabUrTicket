import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isUserBlocked() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return true;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!doc.exists) return false;

  final data = doc.data()!;
  return data['isBlocked'] == true;
}
