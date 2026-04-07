import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDailyRevenueScreen extends StatelessWidget {
  const AdminDailyRevenueScreen({super.key});

  Future<Map<String, int>> _loadDailyRevenue() async {
    final snap =
    await FirebaseFirestore.instance.collection('bookings').get();

    Map<String, int> dailyRevenue = {};

    for (var doc in snap.docs) {
      final data = doc.data();

      if (data['createdAt'] != null && data['amount'] != null) {
        final Timestamp ts = data['createdAt'];
        final DateTime date = ts.toDate();
        final String dayKey = DateFormat('dd MMM yyyy').format(date);

        final num amount = data['amount'];

        dailyRevenue[dayKey] =
            (dailyRevenue[dayKey] ?? 0) + amount.toInt();
      }
    }

    return dailyRevenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Daily Revenue"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadDailyRevenue(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final revenueMap = snapshot.data!;

          if (revenueMap.isEmpty) {
            return const Center(child: Text("No revenue data"));
          }

          final entries = revenueMap.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(entry.key),
                  trailing: Text(
                    "₹${entry.value}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
