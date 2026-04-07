import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/admin/admin_showtimes_screen.dart';
import 'package:graburticket/admin/admin_theatres_screen.dart';
import 'package:graburticket/screens/ticket_verification_page.dart';
import '../screens/login_page.dart';

import 'admin_bookings_screen.dart';
import 'admin_last_minute_deals.dart';
import 'admin_resell_control.dart';
import 'admin_rides_screen.dart';
import 'admin_premium_users_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_user_control.dart';
import 'admin_notifications_screen.dart';


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB00020), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
              );
            },
          )
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------- HEADER --------
            const Text(
              "Welcome, Admin 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Control & monitor Grab Ur Ticket",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // -------- STATS --------
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    title: "Bookings",
                    icon: Icons.confirmation_number,
                    collection: "bookings",
                    gradient: [Colors.green, Colors.black],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: "Revenue",
                    icon: Icons.currency_rupee,
                    collection: "bookings",
                    isRevenue: true,
                    gradient: [Colors.orange, Colors.black],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // -------- ACTIONS --------
            const Text(
              "Admin Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _AdminTile(
                  title: "All Bookings",
                  icon: Icons.list_alt,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminBookingsScreen()),
                  ),
                ),
                _AdminTile(
                  title: "Last Minute Deals",
                  icon: Icons.local_offer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLastMinuteDeals()),
                  ),
                ),
                _AdminTile(
                  title: "Resell Control",
                  icon: Icons.swap_horiz,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminResellControl()),
                  ),
                ),
                _AdminTile(
                  title: "Ride Schedules",
                  icon: Icons.local_taxi,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminRidesScreen()),
                  ),
                ),
                _AdminTile(
                  title: "Premium Users",
                  icon: Icons.workspace_premium,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPremiumUsersScreen()),
                  ),
                ),
                _AdminTile(
                  title: "Analytics",
                  icon: Icons.analytics,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
                  ),
                ),
                _AdminTile(
                  title: "User Control",
                  icon: Icons.block,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUserControl()),
                  ),
                ),
                _AdminTile(
                  title: "Notifications",
                  icon: Icons.notifications_active,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()),
                  ),
                ),
                _AdminTile(
                  title: "Scan Tickets",
                  icon: Icons.qr_code_scanner,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TicketVerificationPage(),
                    ),
                  ),
                ),
                _AdminTile(
                  title: "Manage Theatres",
                  icon: Icons.theaters,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminTheatresScreen()),
                  ),
                ),
                _AdminTile(
                  title: "Manage Showtimes",
                  icon: Icons.schedule,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminShowtimesScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// ===================================================
// PREMIUM STAT CARD
// ===================================================
class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String collection;
  final bool isRevenue;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.collection,
    required this.gradient,
    this.isRevenue = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        int revenue = 0;

        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
          if (isRevenue) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['amount'] is num) {
                revenue += (data['amount'] as num).toInt();
              }
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.15),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    isRevenue ? "₹$revenue" : count.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================
// MODERN ADMIN TILE
// ===================================================
class _AdminTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1A),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
