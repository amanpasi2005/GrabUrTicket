import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/components/seatselections/seatListing.dart';
import 'package:graburticket/services/location_service.dart';
import 'package:graburticket/services/distance_service.dart';
import 'package:graburticket/services/ai_recommendation_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class CinemaTimings extends StatefulWidget {
  final Map<String, dynamic> movie;

  const CinemaTimings({super.key, required this.movie});

  @override
  State<CinemaTimings> createState() => _CinemaTimingsState();
}

class _CinemaTimingsState extends State<CinemaTimings> {
  Position? userPosition;

  int selectedDateIndex = 0;
  List<Map<String, dynamic>> dateOptions = [];

  @override
  void initState() {
    super.initState();
    loadUserLocation();
    dateOptions = generateDateOptions();
  }

  /// 📅 Generate 7 days
  List<Map<String, dynamic>> generateDateOptions() {
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));

      return {
        "day": getDayName(date),
        "date": date.day.toString(),
        "month": getMonthName(date),
        "value": formatDate(date),
      };
    });
  }

  String getDayName(DateTime date) {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return days[date.weekday % 7];
  }

  String getMonthName(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[date.month - 1];
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadUserLocation() async {
    try {
      userPosition = await LocationService.getUserLocation();
      setState(() {});
    } catch (e) {
      debugPrint("Location error: $e");
    }
    print("USER LAT: ${userPosition?.latitude}");
    print("USER LNG: ${userPosition?.longitude}");
  }

  /// 🎯 Smart showtime color
  Color getShowtimeColor(String time) {
    try {
      final hour = int.parse(time.split(":")[0]);

      if (hour < 12) return Colors.green;
      if (hour < 17) return Colors.orange;
      return Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// 📅 Date selector UI
  Widget buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dateOptions.length,
        itemBuilder: (context, index) {
          final item = dateOptions[index];
          final isSelected = selectedDateIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
            },
            child: Container(
              width: 75,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.shade300,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item["day"],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["date"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    item["month"],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = dateOptions[selectedDateIndex]["value"];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Select Showtime"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("showtimes")
            .where("movieTitle", isEqualTo: widget.movie["title"])
            .snapshots(),
        builder: (context, showtimeSnapshot) {

          if (!showtimeSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final showDocs = showtimeSnapshot.data!.docs;

          /// 🎯 Map showtimes
          Map<String, List<String>> theatreShowMap = {};

          for (var doc in showDocs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data["date"] != selectedDate) continue;

            theatreShowMap[data["theatreName"]] =
            List<String>.from(data["times"] ?? []);
          }

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection("theatres").get(),
            builder: (context, theatreSnapshot) {

              if (!theatreSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final theatreDocs = theatreSnapshot.data!.docs;

              List<Map<String, dynamic>> theatres = theatreDocs.map((doc) {

                final data = doc.data() as Map<String, dynamic>;
                final name = data["name"];

                if (!theatreShowMap.containsKey(name)) return null;

                double distance = 0;

                if (userPosition != null &&
                    data["lat"] != null &&
                    data["lng"] != null) {

                  double lat = data["lat"].toDouble();
                  double lng = data["lng"].toDouble();

                  /// 🚨 FIX: avoid wrong coordinates
                  if (lat > 8 && lat < 37 && lng > 68 && lng < 97) {
                    distance = DistanceService.calculateDistance(
                      userPosition!.latitude,
                      userPosition!.longitude,
                      lat,
                      lng,
                    );
                  }
                }

                return {
                  "name": name,
                  "city": data["city"],
                  "distance": distance,
                  "lat": data["lat"],
                  "lng": data["lng"],
                  "times": theatreShowMap[name],
                };

              }).whereType<Map<String, dynamic>>().toList();

              theatres.sort((a, b) =>
                  (a["distance"] ?? 0).compareTo(b["distance"] ?? 0));

              final recommended =
              AIRecommendationService.recommendTheatre(theatres, []);

              return ListView(
                children: [

                  /// 🎬 Movie header
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.movie["imageUrl"],
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie["title"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.movie["metadata"] ?? "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 📅 Dates
                  buildDateSelector(),

                  /// ⭐ Recommendation
                  if (recommended != null)
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text("Recommended: ${recommended["name"]}"),
                    ),

                  /// 🎭 Theatres
                  ...theatres.map((theatre) {

                    return Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black12)
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [
                              const Icon(Icons.theaters, color: Colors.red),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(theatre["name"]),
                                    Text(
                                      theatre["city"],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    userPosition == null
                                        ? "Locating..."
                                        : "${theatre["distance"].toStringAsFixed(1)} km",
                                    style: const TextStyle(color: Colors.green),
                                  ),

                                  const SizedBox(height: 4),

                                  GestureDetector(
                                    onTap: () {
                                      openMap(
                                        theatre["lat"],
                                        theatre["lng"],
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.directions, size: 16, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text(
                                          "Route",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (theatre["times"] as List)
                                .map<Widget>((timing) {

                              final color = getShowtimeColor(timing);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SeatsListings(
                                        theatreCity: theatre["name"],
                                        movieTitle: widget.movie["title"],
                                        movieMetadata: widget.movie["metadata"],
                                        showDateLabel:
                                        dateOptions[selectedDateIndex]["day"],
                                        showDateValue: selectedDate,
                                        showTimeLabel: timing,
                                        showTimeValue: timing,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color),
                                    color: color.withOpacity(.08),
                                  ),
                                  child: Text(
                                    timing,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  if (theatres.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text("No shows available")),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}