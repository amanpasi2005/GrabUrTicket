import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPeakShowtimeScreen extends StatelessWidget {
  const AdminPeakShowtimeScreen({super.key});

  Future<Map<String, int>> _loadShowtimeStats() async {
    final snap =
    await FirebaseFirestore.instance.collection('bookings').get();

    Map<String, int> showtimeCount = {};

    for (var doc in snap.docs) {
      final data = doc.data();

      if (data['showTime'] != null) {
        final String time = data['showTime'];
        showtimeCount[time] = (showtimeCount[time] ?? 0) + 1;
      }
    }

    return showtimeCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Peak Show Times"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadShowtimeStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          if (stats.isEmpty) {
            return const Center(child: Text("No booking data"));
          }

          final sorted = stats.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final entry = sorted[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    child: const Icon(Icons.schedule, color: Colors.orange),
                  ),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "${entry.value} bookings",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
