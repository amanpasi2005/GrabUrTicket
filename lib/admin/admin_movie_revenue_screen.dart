import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMovieRevenueScreen extends StatelessWidget {
  const AdminMovieRevenueScreen({super.key});

  Future<Map<String, int>> _loadMovieRevenue() async {
    final snap =
    await FirebaseFirestore.instance.collection('bookings').get();

    Map<String, int> movieRevenue = {};

    for (var doc in snap.docs) {
      final data = doc.data();

      if (data['movieTitle'] != null && data['amount'] != null) {
        final String movie = data['movieTitle'];
        final num amount = data['amount']; // Firestore gives num

        movieRevenue[movie] =
            (movieRevenue[movie] ?? 0) + amount.toInt();
      }
    }

    return movieRevenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Movie Revenue"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadMovieRevenue(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final revenueMap = snapshot.data!;

          if (revenueMap.isEmpty) {
            return const Center(child: Text("No revenue data"));
          }

          final movies = revenueMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final entry = movies[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.15),
                    child: const Icon(Icons.movie, color: Colors.blue),
                  ),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "₹${entry.value}",
                    style: const TextStyle(
                      fontSize: 16,
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
