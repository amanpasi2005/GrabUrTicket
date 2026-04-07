import 'package:flutter/material.dart';
import 'package:graburticket/screens/showTicket.dart';
import '../services/snack_service.dart';
import '../model/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/utils/price_calculator.dart';
import 'package:graburticket/services/ride_scheduler.dart';

class SnackSelectionPage extends StatefulWidget {
  final String bookingId;
  final String movieTitle;
  final String theatre;
  final String seatNumber;
  final int ticketPrice;

  const SnackSelectionPage({
    super.key,
    required this.bookingId,
    required this.movieTitle,
    required this.theatre,
    required this.seatNumber,
    required this.ticketPrice,
  });

  @override
  State<SnackSelectionPage> createState() => _SnackSelectionPageState();
}

class _SnackSelectionPageState extends State<SnackSelectionPage> {
  late int baseTicketPrice;
  int seatCount = 0;
  int originalTotal = 0;
  int finalTicketAmount = 0;

  bool discountApplied = false;
  int discountPercent = 0;
  bool priceLoaded = false;

  int popcornQty = 0;
  int cokeQty = 0;
  int deliveryMinutes = 10;

  bool autoRideEnabled = true;
  String rideOption = "none";

  final snackService = SnackService();

  Future<void> loadTicketPrice() async {
    seatCount = widget.seatNumber.split(',').length;
    originalTotal = baseTicketPrice * seatCount;

    try {
      final query = await FirebaseFirestore.instance
          .collection('movies')
          .where('title', isEqualTo: widget.movieTitle)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        discountApplied = data['lastMinuteDeal'] ?? false;
        discountPercent = data['discountPercent'] ?? 0;
      }
    } catch (e) {
      print("Price loading error: $e");
    }

    finalTicketAmount = PriceCalculator.applyDiscount(
      originalPrice: originalTotal,
      isDeal: discountApplied,
      discountPercent: discountPercent,
    );

    setState(() {
      priceLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    baseTicketPrice = widget.ticketPrice;
    loadTicketPrice();
  }

  /// 🔹 FETCH MOVIE METADATA AND SCHEDULE RIDE
  Future<void> scheduleRideIfNeeded() async {

    if (rideOption == "none") return;

    final bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get();

    if (!bookingDoc.exists) return;

    final booking = bookingDoc.data();
    if (booking == null) return;

    final movieQuery = await FirebaseFirestore.instance
        .collection('movies')
        .where('title', isEqualTo: widget.movieTitle)
        .limit(1)
        .get();

    String metadata = "";

    if (movieQuery.docs.isNotEmpty) {
      metadata = movieQuery.docs.first.data()['metadata'] ?? "";
    }

    /// PICKUP RIDE (HOME → THEATRE)
    if (rideOption == "pickup" || rideOption == "both") {

      await RideScheduler.scheduleRide(
        bookingId: widget.bookingId,
        movieTitle: widget.movieTitle,
        theatre: widget.theatre,
        movieMetadata: metadata,
        showDateValue: booking['showDateValue'] ?? "",
        showTimeValue: booking['showTimeValue'] ?? "",
        rideType: "auto",
        pickupLocation: "Home",
        dropLocation: widget.theatre,
        distanceKm: 5,
        rideDirection: "goToTheatre",
      );

    }

    /// RETURN RIDE (THEATRE → HOME)
    if (rideOption == "drop" || rideOption == "both") {

      await RideScheduler.scheduleRide(
        bookingId: widget.bookingId,
        movieTitle: widget.movieTitle,
        theatre: widget.theatre,
        movieMetadata: metadata,
        showDateValue: booking['showDateValue'] ?? "",
        showTimeValue: booking['showTimeValue'] ?? "",
        rideType: "auto",
        pickupLocation: widget.theatre,
        dropLocation: "Home",
        distanceKm: 5,
        rideDirection: "returnHome",
      );

    }
  }

  Future<void> saveBookingUpdate() async {

    autoRideEnabled = rideOption != "none";

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({
      'autoRideEnabled': autoRideEnabled,
      'amount': finalTicketAmount,
      'discountApplied': discountApplied,
      'discountPercent': discountPercent,
    });
  }

  @override
  Widget build(BuildContext context) {
    int seatCount = widget.seatNumber.split(',').length;
    int originalTotal = baseTicketPrice * seatCount;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Snacks")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
          children: [
            snackTile("🍿 Popcorn", 150, popcornQty, (v) {
              setState(() => popcornQty = v);
            }),
            snackTile("🥤 Coke", 80, cokeQty, (v) {
              setState(() => cokeQty = v);
            }),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                value: deliveryMinutes,
                items: const [
                  DropdownMenuItem(value: 5, child: Text("After 5 minutes")),
                  DropdownMenuItem(value: 10, child: Text("After 10 minutes")),
                  DropdownMenuItem(value: 15, child: Text("After 15 minutes")),
                ],
                onChanged: (v) => setState(() => deliveryMinutes = v!),
                decoration: const InputDecoration(
                  labelText: "Delivery Time",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🚕 RIDE TOGGLE
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ride Options",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            rideOptionCard(
              title: "No Ride",
              subtitle: "I will travel myself",
              value: "none",
              icon: Icons.close,
            ),

            rideOptionCard(
              title: "Pickup to Theatre",
              subtitle: "Auto from home to theatre",
              value: "pickup",
              icon: Icons.directions_car,
            ),

            rideOptionCard(
              title: "Return Home",
              subtitle: "Auto after movie ends",
              value: "drop",
              icon: Icons.home,
            ),

            rideOptionCard(
              title: "Pickup + Drop",
              subtitle: "Complete round trip ride",
              value: "both",
              icon: Icons.swap_horiz,
            ),

            if (!priceLoaded)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),

                  if (discountApplied) ...[
                    Text(
                      "Ticket Price: ₹$originalTotal",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Final Price: ₹$finalTicketAmount",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      "You saved ₹${originalTotal - finalTicketAmount} ($discountPercent% OFF)",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ] else
                    Text(
                      "Ticket Price: ₹$originalTotal",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 12),
                ],
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                /// ❌ SKIP SNACKS
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await saveBookingUpdate();
                      try {
                        await scheduleRideIfNeeded();
                      } catch (e) {
                        print("Ride scheduling failed: $e");
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShowTicket(bookingId: widget.bookingId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Skip Snacks"),
                  ),
                ),

                const SizedBox(width: 12),

                /// ✅ ADD SNACKS
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await snackService.placeSnackOrder(
                        bookingId: widget.bookingId,
                        movieTitle: widget.movieTitle,
                        theatre: widget.theatre,
                        seatNumber: widget.seatNumber,
                        deliveryAfterMinutes: deliveryMinutes,
                        items: [
                          if (popcornQty > 0)
                            {
                              'name': 'Popcorn',
                              'price': 150,
                              'qty': popcornQty
                            },
                          if (cokeQty > 0)
                            {'name': 'Coke', 'price': 80, 'qty': cokeQty},
                        ],
                      );

                      await saveBookingUpdate();
                      try {
                        await scheduleRideIfNeeded();
                      } catch (e) {
                        print("Ride scheduling failed: $e");
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShowTicket(bookingId: widget.bookingId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Add Snacks"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget snackTile(
      String title, int price, int qty, Function(int) onChange) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text("₹$price"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: qty > 0 ? () => onChange(qty - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text(qty.toString()),
            IconButton(
              onPressed: () => onChange(qty + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget rideOptionCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    bool selected = rideOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          rideOption = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: rideOption,
              activeColor: Colors.green,
              onChanged: (v) {
                setState(() {
                  rideOption = v!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}