import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(child: Text("Login to see notifications"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear all",
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final snap = await FirebaseFirestore.instance
                  .collection('user_notifications')
                  .doc(uid)
                  .collection('items')
                  .get();

              for (var doc in snap.docs) {
                await doc.reference.delete();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All notifications cleared 🧹")),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_notifications')
            .doc(uid)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.docs.isEmpty) return const Center(child: Text("No notifications yet"));

          final docs = snap.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final read = data['read'] == true;

              return Card(
                color: read ? Colors.white : Colors.orange.withOpacity(0.15),
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(data['message'] ?? ''),
                  trailing: read ? null : const Icon(Icons.circle, size: 10, color: Colors.red),
                  onTap: () async {
                    final notifId = data['notificationId'];
                    final alreadyRead = data['read'] == true;

                    // If already read → do nothing
                    if (alreadyRead) return;

                    // Mark as read
                    await FirebaseFirestore.instance
                        .collection('user_notifications')
                        .doc(uid)
                        .collection('items')
                        .doc(docs[i].id)
                        .update({'read': true});

                    // Increment openCount ONLY ON FIRST OPEN
                    if (notifId != null) {
                      await FirebaseFirestore.instance
                          .collection('notification_analytics')
                          .doc(notifId)
                          .update({
                        'openCount': FieldValue.increment(1),
                      });
                    }
                  },


                ),
              );
            },
          );
        },
      ),
    );
  }
}
