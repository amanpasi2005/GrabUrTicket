import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BookedTicketScreen extends StatefulWidget {
  final String bookingId;

  const BookedTicketScreen({super.key, required this.bookingId});

  @override
  State<BookedTicketScreen> createState() => _BookedTicketScreenState();
}

class _BookedTicketScreenState extends State<BookedTicketScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Your Ticket"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final b = snapshot.data!.data() as Map<String, dynamic>;

          String seats = (b['seats'] is List)
              ? (b['seats'] as List).join(", ")
              : (b['seats'] ?? '').toString();

          return Center(
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: _ticketCard(
                  movie: b['movieTitle'] ?? 'Movie',
                  theatre: b['theatre'] ?? '',
                  date: b['showDate'] ?? '',
                  time: b['showTime'] ?? '',
                  seats: seats,
                  amount: (b['amount'] ?? '').toString(),
                  bookingId: widget.bookingId,
                  posterUrl: b['posterUrl'] ?? b['moviePoster'] ?? '',
                  snacks: b['snacks'] ?? [],
                  autoRideEnabled: b['autoRideEnabled'] == true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ticketCard({
    required String movie,
    required String theatre,
    required String date,
    required String time,
    required String seats,
    required String amount,
    required String bookingId,
    required String posterUrl,
    required List snacks,
    required bool autoRideEnabled,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // 🎬 Poster
            Positioned.fill(
              child: posterUrl.isNotEmpty
                  ? Image.network(posterUrl, fit: BoxFit.cover)
                  : Container(color: Colors.black),
            ),

            // 🔴 Red overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xCC000000),
                      Color(0xAA7A0000),
                      Color(0xFF000000),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "GRAB UR TICKET",
                    style: TextStyle(
                      color: Colors.redAccent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(movie,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text("$date • $time",
                      style: const TextStyle(color: Colors.white70)),
                  Text(theatre,
                      style: const TextStyle(color: Colors.white70)),

                  _perforatedDivider(),

                  Row(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SfBarcodeGenerator(
                          value: bookingId,
                          symbology: QRCode(),
                          showValue: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _info("Seats", seats),
                            const SizedBox(height: 8),
                            _info("Booking ID", bookingId),
                            const SizedBox(height: 12),
                            Text(
                              "₹ $amount",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🚕 Ride Section
                  _rideSection(bookingId, autoRideEnabled),

                  const SizedBox(height: 12),

                  // 🍿 Snacks Section
                  FutureBuilder<Map<String,dynamic>>(
                    future: getSnackData(bookingId),
                    builder: (context,snap){

                      List items = snap.data?["items"] ?? [];
                      int snackTotal = snap.data?["total"] ?? 0;

                      String snackText = items.isEmpty
                          ? "No snacks selected"
                          : items.map((s)=>"• ${s['name']} x${s['qty']}").join("\n");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if(snackTotal > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const Text(
                                    "Price Breakdown",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Ticket Price",
                                          style: TextStyle(color: Colors.white70)),
                                      Text("₹ $amount",
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Snacks",
                                          style: TextStyle(color: Colors.white70)),
                                      Text("₹ $snackTotal",
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),

                                  const Divider(color: Colors.white24),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total Paid",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("₹ ${int.parse(amount) + snackTotal}",
                                        style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          _statusCard(
                            Icons.fastfood,
                            snackText,
                            Colors.orangeAccent,
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🚕 Ride
  Widget _rideSection(String bookingId, bool enabled) {
    if (!enabled) {
      return _statusCard(Icons.local_taxi, "Auto ride not enabled", Colors.redAccent);
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('ride_schedules')
          .doc(bookingId)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return _statusCard(Icons.local_taxi, "Ride not scheduled yet", Colors.orange);
        }

        final ride = snap.data!.data() as Map<String, dynamic>;
        final time = (ride['pickupTime'] as Timestamp).toDate();

        return _statusCard(
          Icons.local_taxi,
          "Ride scheduled at ${TimeOfDay.fromDateTime(time).format(context)}",
          Colors.greenAccent,
        );
      },
    );
  }

  // 🍿 Snacks
  Widget _snacksSection(String bookingId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('snack_orders')
          .where('bookingId', isEqualTo: bookingId)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _statusCard(
            Icons.fastfood,
            "No snacks selected",
            Colors.white54,
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final List items = data['items'] ?? [];

        if (items.isEmpty) {
          return _statusCard(
            Icons.fastfood,
            "No snacks selected",
            Colors.white54,
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Snacks",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ...items.map(
                    (s) => Text(
                  "• ${s['name']} × ${s['qty']}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getSnackData(String bookingId) async {

    final snap = await FirebaseFirestore.instance
        .collection('snack_orders')
        .where('bookingId', isEqualTo: bookingId)
        .get();

    if (snap.docs.isEmpty) {
      return {
        "items": [],
        "total": 0
      };
    }

    final data = snap.docs.first.data();
    final List items = data['items'] ?? [];

    int total = 0;

    for (var s in items) {
      int price = s['price'] ?? 0;
      int qty = s['qty'] ?? 0;
      total += price * qty;
    }

    return {
      "items": items,
      "total": total
    };
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _perforatedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(
          30,
              (i) => Expanded(
            child: Container(
              height: 2,
              color: i.isEven ? Colors.redAccent.withOpacity(0.6) : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
