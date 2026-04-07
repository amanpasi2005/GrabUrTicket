import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLastMinuteDeals extends StatefulWidget {
  const AdminLastMinuteDeals({super.key});

  @override
  State<AdminLastMinuteDeals> createState() => _AdminLastMinuteDealsState();
}

class _AdminLastMinuteDealsState extends State<AdminLastMinuteDeals> {
  bool enabled = false;
  double discount = 20;

  final docRef = FirebaseFirestore.instance
      .collection('admin_settings')
      .doc('last_minute_deals');

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;

      double d = (data['discountPercent'] ?? 20).toDouble();

      // 🔥 Prevent Slider Crash (must be between 5 and 50)
      if (d < 5) d = 5;
      if (d > 50) d = 50;

      setState(() {
        enabled = data['enabled'] ?? false;
        discount = d;
      });
    }
  }

  Future<void> saveSettings() async {
    await docRef.set({
      'enabled': enabled,
      'discountPercent': discount.toInt(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Last Minute Deals updated ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Last Minute Deals"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle
            SwitchListTile(
              title: const Text(
                "Enable Last Minute Deals",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                "Apply discount close to show time",
              ),
              value: enabled,
              onChanged: (v) => setState(() => enabled = v),
            ),

            const SizedBox(height: 30),

            // Discount slider
            Text(
              "Discount Percentage",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Slider(
              value: discount,
              min: 5,
              max: 50,
              divisions: 9,
              label: "${discount.toInt()}%",
              onChanged: enabled
                  ? (v) => setState(() => discount = v)
                  : null,
            ),

            const SizedBox(height: 30),

            const Text(
              "Select Movies for Last Minute Deals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('movies').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No movies found"));
                  }

                  final movies = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final doc = movies[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final bool isDeal = data['lastMinuteDeal'] ?? false;

                      int movieDiscount =
                      (data['discountPercent'] ?? discount).toInt();

                      // 🔥 Prevent crash from invalid values
                      if (movieDiscount < 5) movieDiscount = 5;
                      if (movieDiscount > 50) movieDiscount = 50;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Movie Poster
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data['imageUrl'],
                                  width: 55,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        const Text("Deal"),
                                        Switch(
                                          value: isDeal,
                                          onChanged: (value) async {
                                            await FirebaseFirestore.instance
                                                .collection('movies')
                                                .doc(doc.id)
                                                .update({
                                              'lastMinuteDeal': value,
                                              'discountPercent':
                                              value ? movieDiscount : 0,
                                            });
                                          },
                                        ),
                                      ],
                                    ),

                                    if (isDeal)
                                      Row(
                                        children: [
                                          const Text("Discount"),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Slider(
                                              value:
                                              movieDiscount.toDouble(),
                                              min: 5,
                                              max: 50,
                                              divisions: 9,
                                              label: "$movieDiscount%",
                                              onChanged: (v) async {
                                                await FirebaseFirestore.instance
                                                    .collection('movies')
                                                    .doc(doc.id)
                                                    .update({
                                                  'discountPercent':
                                                  v.toInt(),
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Center(
              child: Text(
                "${discount.toInt()}% OFF",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Save Settings",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
