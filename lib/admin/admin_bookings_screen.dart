import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        title: const Text(
          "All Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data =
              bookings[index].data() as Map<String, dynamic>;

              final movie = (data['movieTitle'] ?? 'Movie').toString();
              final theatre = (data['theatre'] ?? 'Theatre').toString();
              final date = (data['showDate'] ?? '').toString();
              final time = (data['showTime'] ?? '').toString();
              final seats = (data['seats'] ?? '').toString();

              // ✅ FIXED AMOUNT LOGIC
              int amount = 0;
              if (data['amount'] != null && data['amount'] is num) {
                amount = (data['amount'] as num).toInt();
              }

              final bool isPremium = amount == 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("🎬 Theatre: $theatre"),
                      if (date.isNotEmpty || time.isNotEmpty)
                        Text("🕒 $date • $time"),

                      if (seats.isNotEmpty)
                        Text("💺 Seats: $seats"),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Chip(
                            label: Text(
                              isPremium
                                  ? "Premium Booking"
                                  : "Paid Booking",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                            isPremium ? Colors.purple : Colors.green,
                          ),
                          const Spacer(),
                          Text(
                            isPremium ? "₹0" : "₹$amount",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
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
