import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/constants.dart';
import 'resell_payment_page.dart';

class ResellExchangePage extends StatelessWidget {
  const ResellExchangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Resell / Exchange Tickets"),
          backgroundColor: kPrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Available"),
              Tab(text: "My Tickets"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AvailableResellTickets(),
            MyTicketsForResell(),
          ],
        ),
      ),
    );
  }
}

// =======================================================
//  TAB 1 → BUY OTHER USERS' RESOLD TICKETS
// =======================================================
class AvailableResellTickets extends StatelessWidget {
  const AvailableResellTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ticket_resales')
          .where('status', isEqualTo: 'available')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No tickets available"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final movie = (data['movieTitle'] ?? '').toString();
            final theatre = (data['theatre'] ?? '').toString();
            final date = (data['showDate'] ?? '').toString();
            final time = (data['showTime'] ?? '').toString();
            final seats = (data['seats'] ?? '').toString();
            final price = data['resellPrice'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  movie,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🎬 $theatre"),
                    Text("📅 $date • $time"),
                    Text("💺 Seats: $seats"),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResellPaymentPage(
                              resaleId: doc.id,
                              amount: price,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                      ),
                      child: const Text("Buy"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =======================================================
//  TAB 2 → MY TICKETS → RESELL MY OWN BOOKING
// =======================================================
class MyTicketsForResell extends StatelessWidget {
  const MyTicketsForResell({super.key});

  static const int adminFee = 20; // 🔐 FIXED ADMIN FEE

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please login"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No bookings found"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final bookingDoc = docs[index];
            final data = bookingDoc.data() as Map<String, dynamic>;

            final movie = (data['movieTitle'] ?? '').toString();
            final theatre = (data['theatre'] ?? '').toString();
            final date = (data['showDate'] ?? '').toString();
            final time = (data['showTime'] ?? '').toString();
            final seats = (data['seats'] ?? '').toString();
            final int amount = data['amount'] ?? 0;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("🎬 $theatre"),
                    Text("📅 $date • $time"),
                    Text("💺 Seats: $seats"),
                    Text("💰 Paid: ₹$amount"),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                        ),
                        child: const Text("Resell / Exchange"),
                        onPressed: () {
                          _openResellDialog(
                            context: context,
                            bookingId: bookingDoc.id,
                            movie: movie,
                            theatre: theatre,
                            date: date,
                            time: time,
                            seats: seats,
                            originalPrice: amount,
                            sellerId: user.uid,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =====================================================
  // RESALE PRICE INPUT DIALOG
  // =====================================================
  void _openResellDialog({
    required BuildContext context,
    required String bookingId,
    required String movie,
    required String theatre,
    required String date,
    required String time,
    required String seats,
    required int originalPrice,
    required String sellerId,
  }) {
    final priceController = TextEditingController(
      text: originalPrice.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Resell Price"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Original price: ₹$originalPrice"),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Your resell price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Admin fee: ₹$adminFee",
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final int resellPrice =
                  int.tryParse(priceController.text) ?? originalPrice;

              final int finalPrice = resellPrice + adminFee;

              // 1️⃣ Disable snacks & ride on original booking
              await FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(bookingId)
                  .update({
                'snacksAllowed': false,
                'autoRideEnabled': false,
                'isResold': true,
              });

              // 2️⃣ Create resell request
              await FirebaseFirestore.instance
                  .collection('ticket_resales')
                  .add({
                'bookingId': bookingId,
                'sellerId': sellerId,
                'movieTitle': movie,
                'theatre': theatre,
                'showDate': date,
                'showTime': time,
                'seats': seats,
                'originalPrice': originalPrice,
                'resellPrice': resellPrice,
                'adminFee': adminFee,
                'finalPrice': finalPrice,
                'type': 'resell',
                'status': 'pending',
                'createdAt': DateTime.now(),
              });


              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Ticket sent for admin approval",
                  ),
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}


class MyTicketsForExchange extends StatelessWidget {
  const MyTicketsForExchange({super.key});

  static const int exchangeFee = 50;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Login required"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No bookings found"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final bookingDoc = docs[index];
            final data = bookingDoc.data() as Map<String, dynamic>;

            final movie = (data['movieTitle'] ?? '').toString();
            final date = (data['showDate'] ?? '').toString();
            final time = (data['showTime'] ?? '').toString();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(movie),
                subtitle: Text("Current: $date • $time"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Exchange"),
                  onPressed: () {
                    _openExchangeDialog(
                      context,
                      bookingId: bookingDoc.id,
                      movie: movie,
                      oldDate: date,
                      oldTime: time,
                      userId: user.uid,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================================================
  // EXCHANGE REQUEST DIALOG
  // ===================================================
  void _openExchangeDialog(
      BuildContext context, {
        required String bookingId,
        required String movie,
        required String oldDate,
        required String oldTime,
        required String userId,
      }) {
    final newDateController = TextEditingController();
    final newTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request Time Exchange"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current: $oldDate • $oldTime"),
            const SizedBox(height: 10),

            TextField(
              controller: newDateController,
              decoration: const InputDecoration(
                labelText: "New Show Date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: newTimeController,
              decoration: const InputDecoration(
                labelText: "New Show Time (e.g. 09:30 PM)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "Exchange fee: ₹$exchangeFee",
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('ticket_resales')
                  .add({
                'type': 'exchange',
                'bookingId': bookingId,
                'userId': userId,
                'movieTitle': movie,
                'oldShowDate': oldDate,
                'oldShowTime': oldTime,
                'newShowDate': newDateController.text.trim(),
                'newShowTime': newTimeController.text.trim(),
                'exchangeFee': exchangeFee,
                'status': 'pending',
                'createdAt': DateTime.now(),
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Exchange request sent for approval"),
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}

