import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'HomePageScreen.dart';

class ShowTicket extends StatefulWidget {
  final String bookingId;
  const ShowTicket({super.key, required this.bookingId});

  @override
  State<ShowTicket> createState() => _ShowTicketState();
}

class _ShowTicketState extends State<ShowTicket>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  final GlobalKey _ticketKey = GlobalKey();


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getRemainingTime(DateTime pickup) {

    final now = DateTime.now();

    final diff = pickup.difference(now);

    if (diff.isNegative) {
      return "Driver arriving";
    }

    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;

    if (minutes <= 0) {
      return "$seconds sec";
    }

    return "$minutes min $seconds sec";
  }

  double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {

    const double R = 6371;

    final dLat = (lat2 - lat1) * 3.141592653589793 / 180;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180;

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(lat1 * 3.141592653589793 / 180) *
                cos(lat2 * 3.141592653589793 / 180) *
                (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final bool isUsed = data['isUsed'] == true;

          final int amount = data['amount'] ?? 0;
          final bool discountApplied = data['discountApplied'] ?? false;
          final int discountPercent = data['discountPercent'] ?? 0;

          int originalPrice = amount;

          if (discountApplied && discountPercent > 0) {
            originalPrice =
                (amount * 100 / (100 - discountPercent)).round();
          }


          final bool usedPremium = data['usedPremium'] == true;
          final bool autoRideEnabled = data['autoRideEnabled'] == true;
          final bool isResold = data['isResold'] == true;




          return Center(
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: RepaintBoundary(
                  key: _ticketKey,
                  child: _ticketCard(
                    movie: data['movieTitle'] ?? 'Movie',
                    theatre: data['theatre'] ?? '',
                    date: data['showDate'] ?? '',
                    time: data['showTime'] ?? '',
                    seats: (data['seats'] is List)
                        ? (data['seats'] as List).join(", ")
                        : (data['seats'] ?? ''),
                    isUsed: isUsed,
                    usedPremium: usedPremium,
                    autoRideEnabled: autoRideEnabled,
                    isResold: isResold,
                    amount: amount,
                    discountApplied: discountApplied,
                    discountPercent: discountPercent,
                    originalPrice: originalPrice,
                  ),
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
    required bool isUsed,
    required bool usedPremium,
    required bool autoRideEnabled,
    required bool isResold,

    required int amount,
    required bool discountApplied,
    required int discountPercent,
    required int originalPrice,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFFB00020), Color(0xFF000000)],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🎬 MOVIE INFO
                    Text(movie,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    if (isResold)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "RESELL / EXCHANGE TICKET",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (isUsed)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "TICKET USED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    Text('$date • $time',
                        style: const TextStyle(color: Colors.white70)),
                    Text(theatre,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),

                    Text(
                      "Booking ID: ${widget.bookingId}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR + BASIC INFO
                    Row(
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: SfBarcodeGenerator(
                            value:
                            "${widget.bookingId}|$movie|$theatre|$seats|$date|$time",
                            symbology: QRCode(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoRow("Seats", seats),
                              const SizedBox(height: 10),
                              infoRow(
                                "Booking",
                                usedPremium
                                    ? "Premium Pass Used"
                                    : "Paid Booking",
                              ),
                              const SizedBox(height: 10),

                              // 💰 PRICE INFO
                              if (discountApplied) ...[
                                Text(
                                  "Ticket Price: ₹$originalPrice",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  "Paid: ₹$amount",
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "🔥 Last Minute Deal • $discountPercent% OFF",
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else
                                Text(
                                  "Paid: ₹$amount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    FutureBuilder<Map<String, dynamic>>(
                      future: getSnackData(),
                      builder: (context, snap) {

                        List items = snap.data?["items"] ?? [];
                        int snackTotal = snap.data?["total"] ?? 0;

                        String snackText = items.isEmpty
                            ? "No snacks added"
                            : items.map((s) => "${s['name']} x${s['qty']}").join(", ");

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Container(
                              padding: const EdgeInsets.all(14),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  _priceRow("Ticket Price", "₹$originalPrice"),

                                  if (discountApplied)
                                    _priceRow(
                                      "Last Minute Deal ($discountPercent% OFF)",
                                      "- ₹${originalPrice - amount}",
                                      valueColor: Colors.greenAccent,
                                    ),

                                  const Divider(color: Colors.white24),

                                  _priceRow("Snacks", "₹$snackTotal"),

                                  const Divider(color: Colors.white24),

                                  _priceRow(
                                    "Total Paid",
                                    "₹${amount + snackTotal}",
                                    isBold: true,
                                    valueColor: Colors.greenAccent,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            infoRow("Snacks", snackText),
                          ],
                        );
                      },
                    ),




                    const SizedBox(height: 14),

                    // 🚕 AUTO RIDE STATUS
                    if (!autoRideEnabled)
                      _statusBox(
                        icon: Icons.block,
                        text: "Auto ride booking disabled",
                        color: Colors.redAccent,
                      ),

                    if (autoRideEnabled)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('ride_schedules')
                            .where('bookingId', isEqualTo: widget.bookingId)
                            .snapshots(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return _statusBox(
                              icon: Icons.local_taxi,
                              text: "Loading rides...",
                              color: Colors.orange,
                            );
                          }

                          final rides = snapshot.data!.docs;

                          if (rides.isEmpty) {
                            return _statusBox(
                              icon: Icons.local_taxi,
                              text: "Ride not scheduled yet",
                              color: Colors.orange,
                            );
                          }

                          return Column(
                            children: rides.map((doc) {

                              final ride = doc.data() as Map<String, dynamic>;

                              final pickupTime =
                              (ride['pickupTime'] as Timestamp).toDate();

                              String label =
                              ride['rideDirection'] == "goToTheatre"
                                  ? "🚗 Going to Theatre"
                                  : "🏠 Returning Home";

                              final driverName = ride['driverName'];
                              final driverPhone = ride['driverPhone'];
                              final vehicle = ride['vehicleNumber'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.greenAccent),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Pickup at ${TimeOfDay.fromDateTime(pickupTime).format(context)}",
                                      style: const TextStyle(color: Colors.white),
                                    ),

                                    const SizedBox(height: 6),

                                    if (driverName != null) ...[
                                      Text("Driver: $driverName",
                                          style: const TextStyle(color: Colors.white70)),

                                      Text("Vehicle: $vehicle",
                                          style: const TextStyle(color: Colors.white70)),

                                      if (driverPhone != null)
                                        Text("Phone: $driverPhone",
                                            style: const TextStyle(color: Colors.white70)),
                                    ] else
                                      const Text(
                                        "Finding driver...",
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                  ],
                                ),
                              );

                            }).toList(),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Share.share(
                                "🎟 Grab Ur Ticket\n\n"
                                    "Movie: $movie\n"
                                    "Theatre: $theatre\n"
                                    "Date: $date\n"
                                    "Time: $time\n"
                                    "Seats: $seats\n\n"
                                    "Booking ID: ${widget.bookingId}",
                              );
                            },
                            icon: const Icon(Icons.share,
                                color: Colors.white),
                            label: const Text("Share",
                                style:
                                TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _downloadTicket,
                            icon: const Icon(Icons.download),
                            label: const Text("Download"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const HomePageScreen()),
                                (_) => false,
                          );
                        },
                        child: const Text("Back to Home"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white54, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<Map<String, dynamic>> getSnackData() async {

    final snap = await FirebaseFirestore.instance
        .collection('snack_orders')
        .where('bookingId', isEqualTo: widget.bookingId)
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

  Widget _priceRow(
      String label,
      String value, {
        bool isBold = false,
        Color valueColor = Colors.white,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _statusBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTicket() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) return;

      final boundary =
      _ticketKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      Directory dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File(
        '${dir.path}/GrabUrTicket_${widget.bookingId}.png',
      );

      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket downloaded ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download ticket ❌")),
      );
    }
  }

}
