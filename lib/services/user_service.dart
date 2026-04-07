import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection("users");

  Future<void> saveUser(String uid, String name, String email) async {
    return users.doc(uid).set({
      "name": name,
      "email": email,
      "createdAt": DateTime.now(),
    });
  }
}
