import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/constants.dart';

class SellerPayoutsPage extends StatelessWidget {
  const SellerPayoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Earnings"),
        backgroundColor: kPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('seller_payouts')
            .where('sellerId', isEqualTo: user!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No earnings yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = data['status'];

              return Card(
                child: ListTile(
                  title: Text("₹${data['amount']}"),
                  subtitle: Text(
                    status == 'paid'
                        ? "Paid"
                        : "Pending payout",
                  ),
                  trailing: Icon(
                    status == 'paid'
                        ? Icons.check_circle
                        : Icons.hourglass_bottom,
                    color:
                    status == 'paid' ? Colors.green : Colors.orange,
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
