import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/services/ride_scheduler.dart';
import 'package:intl/intl.dart';

class AdminRidesScreen extends StatelessWidget {
  const AdminRidesScreen({super.key});

  // 🔥 AUTO ASSIGN NEAREST DRIVER
  Future<void> _assignDriverAuto(String rideId) async {
    final rideDoc = await FirebaseFirestore.instance
        .collection('ride_schedules')
        .doc(rideId)
        .get();

    final ride = rideDoc.data();

    if (ride == null) return;

    final result = await RideScheduler.findNearestDriver(
      userLat: ride['pickupLat'],
      userLng: ride['pickupLng'],
    );

    if (result == null) {
      print("No driver found");
      return;
    }

    final driver = result['data'];

    await FirebaseFirestore.instance
        .collection('ride_schedules')
        .doc(rideId)
        .update({
      'driverName': driver['name'],
      'driverPhone': driver['phone'],
      'vehicleNumber': driver['vehicle'],
      'driverLat': driver['lat'],
      'driverLng': driver['lng'],
      'status': 'driver_assigned',
    });

    // optional movement simulation
    RideScheduler.startDriverSimulation(rideId);
  }

  // 🔧 MANUAL LOCATION UPDATE (OPTIONAL)
  void _updateDriverLocation(BuildContext context, String rideId) {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Driver Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: "Latitude"),
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: "Longitude"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('ride_schedules')
                    .doc(rideId)
                    .update({
                  'driverLat': double.parse(latController.text),
                  'driverLng': double.parse(lngController.text),
                });

                Navigator.pop(context);
              },
              child: const Text("Update Location"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Schedules"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_schedules')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No rides scheduled"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final pickupTime = data['pickupTime'] != null
                  ? DateFormat('dd MMM yyyy • hh:mm a')
                  .format((data['pickupTime'] as Timestamp).toDate())
                  : 'N/A';

              final String rideLabel =
              data['rideDirection'] == "goToTheatre"
                  ? "🚗 Going to Theatre"
                  : "🏠 Returning Home";

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['movieTitle'] ?? 'Movie',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text("🎬 Theatre: ${data['theatre']}"),

                      Text(
                        rideLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      Text("🚕 Pickup: $pickupTime"),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${data['status']}",
                        style: TextStyle(
                          color: data['status'] == 'scheduled'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Divider(),

                      Text(
                        "👤 User ID: ${data['userId']}",
                        style: const TextStyle(fontSize: 11),
                      ),

                      Text(
                        "🎟 Booking ID: ${data['bookingId']}",
                        style: const TextStyle(fontSize: 11),
                      ),

                      // 🔥 DRIVER ASSIGN BUTTON
                      if (data['driverName'] == null)
                        ElevatedButton(
                          onPressed: () {
                            _assignDriverAuto(docs[index].id);
                          },
                          child: const Text("Auto Assign Driver"),
                        )
                      else ...[
                        const Text(
                          "Driver Assigned",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: () {
                            _updateDriverLocation(
                                context, docs[index].id);
                          },
                          child: const Text("Update Driver Location"),
                        ),
                      ]
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