import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_daily_revenue_screen.dart';
import 'admin_movie_revenue_screen.dart';
import 'admin_peak_showtime_screen.dart';
import 'admin_charts_screen.dart';



class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  Future<int> _getCount(String collection) async {
    final snap =
    await FirebaseFirestore.instance.collection(collection).get();
    return snap.docs.length;
  }

  Future<int> _getRevenue() async {
    final snap =
    await FirebaseFirestore.instance.collection('bookings').get();

    int total = 0;

    for (var doc in snap.docs) {
      final data = doc.data();

      if (data['amount'] != null) {
        final num value = data['amount']; // Firestore gives num
        total += value.toInt();           // convert to int safely
      }
    }

    return total;
  }


  Future<int> _getPremiumUsers() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('premiumPass.isActive', isEqualTo: true)
        .get();

    return snap.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("App Analytics"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _getCount('users'),
          _getCount('bookings'),
          _getRevenue(),
          _getPremiumUsers(),
          _getCount('ride_schedules'),
          _getCount('last_minute_deals'),
        ]),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _AnalyticsCard(
                title: "Users",
                value: data[0].toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              _AnalyticsCard(
                title: "Bookings",
                value: data[1].toString(),
                icon: Icons.confirmation_number,
                color: Colors.green,
              ),
              _AnalyticsCard(
                title: "Revenue",
                value: "₹${data[2]}",
                icon: Icons.currency_rupee,
                color: Colors.orange,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDailyRevenueScreen(),
                    ),
                  );
                },
                child: _AnalyticsCard(
                  title: "Daily Revenue",
                  value: "View",
                  icon: Icons.bar_chart,
                  color: Colors.teal,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminMovieRevenueScreen(),
                    ),
                  );
                },
                child: _AnalyticsCard(
                  title: "Movie Revenue",
                  value: "View",
                  icon: Icons.movie_filter,
                  color: Colors.indigo,
                ),
              ),


              _AnalyticsCard(
                title: "Premium Users",
                value: data[3].toString(),
                icon: Icons.workspace_premium,
                color: Colors.amber,
              ),
              _AnalyticsCard(
                title: "Rides Scheduled",
                value: data[4].toString(),
                icon: Icons.local_taxi,
                color: Colors.purple,
              ),
              _AnalyticsCard(
                title: "Last Minute Deals",
                value: data[5].toString(),
                icon: Icons.local_offer,
                color: Colors.red,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPeakShowtimeScreen(),
                    ),
                  );
                },
                child: _AnalyticsCard(
                  title: "Peak Show Times",
                  value: "View",
                  icon: Icons.schedule,
                  color: Colors.deepOrange,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminChartsScreen(),
                    ),
                  );
                },
                child: _AnalyticsCard(
                  title: "Charts",
                  value: "View",
                  icon: Icons.bar_chart,
                  color: Colors.deepOrange,
                ),
              ),


            ],
          );
        },
      ),
    );
  }
}

// ================= CARD =================
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 26,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
