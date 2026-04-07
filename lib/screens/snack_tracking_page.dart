import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/screens/showTicket.dart';

class SnackTrackingPage extends StatelessWidget {
  final String orderId;
  final String bookingId;

  const SnackTrackingPage({
    super.key,
    required this.orderId,
    required this.bookingId,
  });


  double _progressFromStatus(String status) {
    switch (status) {
      case 'preparing':
        return 0.25;
      case 'ready':
        return 0.50;
      case 'on_the_way':
        return 0.75;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'preparing':
        return "Preparing your snacks 🍿";
      case 'ready':
        return "Snacks are ready ✅";
      case 'on_the_way':
        return "On the way to your seat 🚶‍♂️";
      case 'delivered':
        return "Delivered to your seat 🎉";
      default:
        return "Processing...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Snack Tracking")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('snack_orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'preparing';
          final progress = _progressFromStatus(status);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _statusText(status),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                ),

                const SizedBox(height: 16),

                Text(
                  "${(progress * 100).toInt()}% completed",
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 40),

                if (status == 'delivered')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowTicket(bookingId: bookingId),
                        ),

                        (route) => false,
                      );
                    },
                    child: const Text("🎟️ View Ticket"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
