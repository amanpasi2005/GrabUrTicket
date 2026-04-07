import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/model/constants.dart';
import 'package:graburticket/screens/seatselections.dart';
import 'package:graburticket/services/ai_recommendation_service.dart';
import 'package:graburticket/services/location_service.dart';
import 'package:graburticket/services/distance_service.dart';
import 'package:geolocator/geolocator.dart';

class ShowTiming extends StatefulWidget {
  const ShowTiming({
    super.key,
    required this.movieIndex,
    required this.bookingId,
  });

  final int movieIndex;
  final String bookingId;


  @override
  State<ShowTiming> createState() => _ShowTimingState();
}

class _ShowTimingState extends State<ShowTiming> {

  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;
  String selectedTime = "";
  String selectedTheatre = "";
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    loadUserLocation();
  }

  Future<void> loadUserLocation() async {
    try {
      userPosition = await LocationService.getUserLocation();
      setState(() {});
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  /// ================= GENERATE NEXT 7 DAYS =================
  List<Map<String, String>> generateDates() {

    final now = DateTime.now();

    return List.generate(7, (index) {

      final date = now.add(Duration(days: index));

      return {
        "day": ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][date.weekday % 7],
        "date": date.day.toString().padLeft(2, '0'),
        "month": ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][date.month - 1],
        "fullDate": "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}"
      };

    });

  }

  /// ================= SELECTED DATE =================
  String get selectedDateValue {

    final dates = generateDates();
    return dates[selectedDateIndex]["fullDate"]!;

  }

  Map<String, dynamic> getSeatStatus(int totalSeats, int bookedSeats) {

    final available = totalSeats - bookedSeats;
    final percent = available / totalSeats;

    if (percent > 0.5) {
      return {
        "color": Colors.green,
        "text": "Available"
      };
    }

    if (percent > 0.25) {
      return {
        "color": Colors.orange,
        "text": "Filling Fast"
      };
    }

    return {
      "color": Colors.red,
      "text": "Almost Full"
    };
  }

  @override
  Widget build(BuildContext context) {

    final movie = movieData[widget.movieIndex];
    final dates = generateDates();

    return Column(
      children: [

        /// ================= DATE SELECTOR =================
        SizedBox(
          height: 80,
          child: ListView.builder(
            itemCount: dates.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {

              final date = dates[index];
              final selected = selectedDateIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDateIndex = index;
                    selectedTimeIndex = -1;
                  });
                },
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(date['day']!,
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.grey)),
                      Text(
                        date['date']!,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontFamily: primaryFont,
                        ),
                      ),
                      Text(date['month']!,
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.grey)),
                    ],
                  ),
                ),
              );

            },
          ),
        ),

        const Divider(),

        /// ================= MOVIE META =================
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(movie['language']?.toString() ?? "",
                  style: TextStyle(fontFamily: primaryFont)),
              const SizedBox(width: 4),
              Text(". ${movie['screenType']?.toString() ?? ""}"),
            ],
          ),
        ),

        const Divider(),

        /// ================= SHOWTIMES =================
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("showtimes")
              .where("movieTitle", isEqualTo: movie['title'] ?? "")
              .where("date", isEqualTo: selectedDateValue)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No shows available"),
              );
            }

            final docs = snapshot.data!.docs;

            List theatres = docs.map((doc) {

              final data = doc.data() as Map<String, dynamic>;

              int totalSeats = data["totalSeats"] ?? 120;
              int bookedSeats = data["bookedSeats"] ?? 0;

              double distance = 0;

              if (userPosition != null) {

                double lat = (data["lat"] as num?)?.toDouble() ?? 0.0;
                double lng = (data["lng"] as num?)?.toDouble() ?? 0.0;

                distance = DistanceService.calculateDistance(
                  userPosition!.latitude,
                  userPosition!.longitude,
                  lat,
                  lng,
                );
              }

              return {
                "name": data["theatreName"]?.toString() ?? "",
                "times": data["times"],
                "totalSeats": totalSeats,
                "bookedSeats": bookedSeats,
                "availableSeats": totalSeats - bookedSeats,
                "distance": distance
              };

            }).toList();

            List<String> favouriteTheatres = [];

            final recommended =
            AIRecommendationService.recommendTheatre(
                theatres,
                favouriteTheatres);

            return Column(
                children: [

                /// ⭐ Recommended Theatre Banner
                if (recommended != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [

                  const Icon(Icons.star, color: Colors.orange),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Recommended for you",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(recommended["name"]),

                        const Text(
                          "Best seats available",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Theatre List
            ...docs.map((doc) {

                final data = doc.data() as Map<String, dynamic>;
                final String theatre = data["theatreName"]?.toString() ?? "Unknown Theatre";
                final times = List<String>.from(data["times"] ?? []);

                final totalSeats = data["totalSeats"] ?? 120;
                final bookedSeats = data["bookedSeats"] ?? 0;

                final seatStatus = getSeatStatus(totalSeats, bookedSeats);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🎬 Theatre Header
                      Row(
                        children: [

                          const Icon(Icons.theaters, color: Colors.red),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  theatre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (userPosition != null)
                                  Text(
                                    "${DistanceService.calculateDistance(
                                      userPosition!.latitude,
                                      userPosition!.longitude,
                                      (data["lat"] as num?)?.toDouble() ?? 0.0,
                                      (data["lng"] as num?)?.toDouble() ?? 0.0,
                                    ).toStringAsFixed(1)} km away",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),

                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Seats Available",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                              ),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 6),

                      /// ⭐ Theatre Info Row
                      Row(
                        children: const [

                          Icon(Icons.star, color: Colors.orange, size: 16),
                          SizedBox(width: 3),
                          Text("4.3", style: TextStyle(fontSize: 12)),

                          SizedBox(width: 12),

                          Icon(Icons.local_taxi, size: 16, color: Colors.blue),
                          SizedBox(width: 3),
                          Text("Ride Available",
                              style: TextStyle(fontSize: 11, color: Colors.blue)),

                        ],
                      ),

                      const SizedBox(height: 14),

                      /// ⏰ Showtimes
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: times.map((time) {

                          final selected = selectedTime == time;

                          return GestureDetector(
                            onTap: () async {

                              setState(() {
                                selectedTime = time;
                                selectedTheatre = theatre;
                              });

                              await FirebaseFirestore.instance
                                  .collection("bookings")
                                  .doc(widget.bookingId)
                                  .set({

                                "showDate": dates[selectedDateIndex]["day"],
                                "showTime": time,
                                "theatre": theatre,
                                "showDateValue": selectedDateValue,
                                "showTimeValue": time,

                              }, SetOptions(merge: true));

                            },
                            child: Container(
                              width: 90,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? kPrimary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kPrimary),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    seatStatus["text"],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: seatStatus["color"],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );

                        }).toList(),
                      ),

                    ],
                  ),
                );

              }).toList(),
            ],
            );

          },
        ),

        const SizedBox(height: 10),

        /// ================= CONTINUE BUTTON =================
        if (selectedTime.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Seatselections(
                        movie: movieData[widget.movieIndex],
                      ),
                    ),
                  );

                },
                child: const Text("Select Seats"),
              ),
            ),
          ),

      ],
    );
  }
}