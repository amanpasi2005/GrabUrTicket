import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminResellControl extends StatelessWidget {
  const AdminResellControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resell / Exchange Approvals"),
        backgroundColor: Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ticket_resales')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No pending requests"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String type =
              (data['type'] ?? 'resell').toString();

              final bool isExchange = type == 'exchange';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ---------------- HEADER ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['movieTitle'] ?? 'Movie',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(
                              isExchange ? "EXCHANGE" : "RESELL",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                            isExchange ? Colors.orange : Colors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // ---------------- DETAILS ----------------
                      if (!isExchange) ...[
                        Text("🎬 ${data['theatre']}"),
                        Text(
                            "📅 ${data['showDate']} • ${data['showTime']}"),
                        Text("💺 Seats: ${data['seats']}"),
                        const SizedBox(height: 6),
                        Text(
                          "₹${data['resellPrice']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],

                      if (isExchange) ...[
                        Text(
                          "Old: ${data['oldShowDate']} • ${data['oldShowTime']}",
                        ),
                        Text(
                          "New: ${data['newShowDate']} • ${data['newShowTime']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Exchange Fee: ₹${data['exchangeFee']}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const Divider(height: 20),

                      // ---------------- ACTIONS ----------------
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await doc.reference.update({
                                  'status': 'rejected',
                                  'approvedBy': FirebaseAuth.instance.currentUser!.uid,
                                  'approvedAt': FieldValue.serverTimestamp(),
                                });

                                // 🔔 NOTIFICATION – REJECTED
                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .add({
                                  'userId': data['sellerId'] ?? data['userId'],
                                  'title': 'Request Rejected',
                                  'message':
                                  'Your ${isExchange ? 'exchange' : 'resell'} request for ${data['movieTitle']} was rejected.',
                                  'type': isExchange ? 'exchange' : 'resell',
                                  'read': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                              },

                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                // ✅ APPLY EXCHANGE
                                if (isExchange) {
                                  await FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(data['bookingId'])
                                      .update({
                                    'showDate': data['newShowDate'],
                                    'showTime': data['newShowTime'],
                                  });
                                }

                                // ✅ APPROVE REQUEST
                                await doc.reference.update({
                                  'status': 'approved',
                                  'approvedBy': FirebaseAuth.instance.currentUser!.uid,
                                  'approvedAt': FieldValue.serverTimestamp(),
                                });

                                // 🔔 NOTIFICATION – APPROVED
                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .add({
                                  'userId': data['sellerId'] ?? data['userId'],
                                  'title': isExchange
                                      ? 'Exchange Approved'
                                      : 'Resell Approved',
                                  'message': isExchange
                                      ? 'Your ticket time exchange for ${data['movieTitle']} has been approved.'
                                      : 'Your ticket for ${data['movieTitle']} is now live for resell.',
                                  'type': isExchange ? 'exchange' : 'resell',
                                  'read': false,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                              },
                              child: const Text("Approve"),
                            ),
                          ),
                        ],
                      ),
                    ],
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
