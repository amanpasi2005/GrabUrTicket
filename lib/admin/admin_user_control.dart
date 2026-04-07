import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserControl extends StatelessWidget {
  const AdminUserControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Control"),
        backgroundColor: Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              final isBlocked = data['isBlocked'] == true;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['email'] ?? 'User'),
                  subtitle: Text(
                    isBlocked ? "BLOCKED" : "ACTIVE",
                    style: TextStyle(
                      color: isBlocked ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isBlocked ? Colors.green : Colors.red,
                    ),
                    child: Text(isBlocked ? "UNBLOCK" : "BLOCK"),
                    onPressed: () {
                      doc.reference.update({
                        'isBlocked': !isBlocked,
                        'blockedAt': isBlocked
                            ? null
                            : FieldValue.serverTimestamp(),
                        'blockedReason': isBlocked
                            ? ""
                            : "Violation of terms",
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
