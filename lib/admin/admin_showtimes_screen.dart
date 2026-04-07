import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminShowtimesScreen extends StatefulWidget {
  const AdminShowtimesScreen({super.key});

  @override
  State<AdminShowtimesScreen> createState() => _AdminShowtimesScreenState();
}

class _AdminShowtimesScreenState extends State<AdminShowtimesScreen> {

  String? selectedMovie;
  String? selectedTheatre;
  DateTime selectedDate = DateTime.now();

  List<String> times = [];

  final timeController = TextEditingController();

  Future<void> addShowtime() async {

    if (selectedMovie == null || selectedTheatre == null || times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    /// Get theatre details (lat, lng etc.)
    final theatreQuery = await FirebaseFirestore.instance
        .collection("theatres")
        .where("name", isEqualTo: selectedTheatre)
        .limit(1)
        .get();

    double lat = 0;
    double lng = 0;

    if (theatreQuery.docs.isNotEmpty) {
      final theatreData = theatreQuery.docs.first.data();
      lat = (theatreData["lat"] ?? 0).toDouble();
      lng = (theatreData["lng"] ?? 0).toDouble();
    }

    await FirebaseFirestore.instance.collection("showtimes").add({

      "movieTitle": selectedMovie,
      "theatreName": selectedTheatre,

      "date":
      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",

      "times": times,

      /// AUTO GENERATED FIELDS
      "totalSeats": 120,
      "bookedSeats": 0,

      "lat": lat,
      "lng": lng,

      "createdAt": FieldValue.serverTimestamp(),

    });

    setState(() {
      times.clear();
      selectedMovie = null;
      selectedTheatre = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Showtime Added")));
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Showtimes")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// MOVIE DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("movies").snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final movies = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedMovie,
                  hint: const Text("Select Movie"),
                  items: movies.map((doc) {

                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: data["title"],
                      child: Text(data["title"]),
                    );

                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedMovie = value);
                  },
                );

              },
            ),

            const SizedBox(height: 10),

            /// THEATRE DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("theatres").snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final theatres = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedTheatre,
                  hint: const Text("Select Theatre"),
                  items: theatres.map((doc) {

                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: data["name"],
                      child: Text(data["name"]),
                    );

                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedTheatre = value);
                  },
                );

              },
            ),

            const SizedBox(height: 10),

            /// DATE PICKER
            Row(
              children: [

                Expanded(
                  child: Text(
                    "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                ),

                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Select Date"),
                ),

              ],
            ),

            const SizedBox(height: 10),

            /// ADD TIME
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: "Add Time (Example: 09:00 AM)",
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {

                    if (timeController.text.isEmpty) return;

                    setState(() {
                      times.add(timeController.text);
                      timeController.clear();
                    });

                  },
                ),

              ],
            ),

            const SizedBox(height: 10),

            /// SHOW TIMES PREVIEW
            Wrap(
              spacing: 8,
              children: times.map((t) {

                return Chip(
                  label: Text(t),
                  onDeleted: () {
                    setState(() => times.remove(t));
                  },
                );

              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addShowtime,
              child: const Text("Save Showtime"),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text(
              "Existing Showtimes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("showtimes")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      final data = docs[index].data() as Map<String, dynamic>;

                      final timesList = List<String>.from(data["times"] ?? []);

                      return ListTile(
                        title: Text("${data["movieTitle"]} - ${data["theatreName"]}"),
                        subtitle: Text("Date: ${data["date"]}"),
                        trailing: Text("${timesList.length} shows"),
                      );

                    },
                  );

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}