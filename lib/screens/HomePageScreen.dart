import 'package:flutter/material.dart';
import 'package:graburticket/screens/booked_ticket_screen.dart';
import 'package:graburticket/screens/notification_screen.dart';
import 'package:graburticket/screens/resell_exchange_page.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';
import 'premium_pass_page.dart';
import 'package:graburticket/components/homepage/bestevents.dart';
import 'package:graburticket/components/homepage/newreleases.dart';
import 'package:graburticket/components/homepage/premierMovies.dart';
import 'package:graburticket/components/homepage/topcarousel.dart';

import 'package:graburticket/model/constants.dart';
import 'package:graburticket/screens/search_page.dart';
import 'package:graburticket/screens/qrcode_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/screens/login_page.dart';
import 'package:graburticket/screens/moviesdata.dart';
import 'package:graburticket/screens/snack_selection_page.dart';
import 'package:graburticket/components/last_minute_deals_section.dart';



class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  int _selectedIndex = 0;

  // Bottom navigation pages
  final List<Widget> _bottomPages = [
    const HomeContent(),   // Home
    const MoviesPage(), // Movies
    const ResellExchangePage(),
    const AiPickPage(),    // AI Pick
    const NotificationScreen(),
    const ProfilePage(),   // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _bottomPages[_selectedIndex],

      // --------------------------
      // BOTTOM NAVIGATION BAR
      // --------------------------
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.video_play),
            label: "Movies",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Resell",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI Pick",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------
//  HOME PAGE UI – your original content
// ----------------------------------------
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  bool isPremiumUser = false;
  int remainingMovies = 0;

  Future<void> fetchPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final premium = doc.data()?['premiumPass'];

      if (premium != null &&
          premium['isActive'] == true &&
          premium['remainingMovies'] > 0) {
        setState(() {
          isPremiumUser = true;
          remainingMovies = premium['remainingMovies'];
        });
      } else {
        setState(() {
          isPremiumUser = false;
          remainingMovies = 0;
        });
      }
    });
  }


  // Selected location (default)
  String _selectedLocation = 'Mumbai';

  // List of popular locations
  final List<String> _popularLocations = [
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Kolkata',
    'Chennai',
    'Hyderabad',
    'Pune',
  ];

  // Open bottom sheet for location selection
  void _openLocationSelector() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final TextEditingController manualController =
        TextEditingController(text: _selectedLocation);

        final viewInsets = MediaQuery.of(context).viewInsets;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: viewInsets.bottom + 16, // prevents keyboard overflow
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Popular locations
                ..._popularLocations.map(
                      (city) => ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(city),
                    onTap: () {
                      Navigator.pop(context, city);
                    },
                  ),
                ),

                const Divider(),
                const SizedBox(height: 8),

                const Text(
                  'Or enter manually',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: manualController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your city / area',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    final v = value.trim();
                    if (v.isNotEmpty) {
                      Navigator.pop(context, v);
                    }
                  },
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = manualController.text.trim();
                      if (value.isNotEmpty) {
                        Navigator.pop(context, value);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedLocation = result;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'city': result,
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchPremiumStatus();
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            //  PREMIUM BANNER (NEW)
            if (isPremiumUser)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB00020), // deep red
                      Color(0xFF000000), // black
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PREMIUM PASS ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$remainingMovies Free Movies Left',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),

            // ---------- TOP HEADER ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "It's All Starts Here",
                        style: TextStyle(
                          color: darkColor,
                          fontFamily: primaryFont,
                          fontSize: textContent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // ✅ CLICKABLE LOCATION
                      InkWell(
                        onTap: _openLocationSelector,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: darkColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLocation,
                              style: TextStyle(
                                color: darkColor.withOpacity(0.6),
                                fontFamily: primaryFont,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: darkColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Search
                  IconButton(
                    icon: Icon(Iconsax.search_normal, color: kPrimary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchPage(),
                        ),
                      );
                    },
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ));
                    },
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_none, color: kPrimary),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('user_notifications')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('items')
                              .where('read', isEqualTo: false)
                              .snapshots(),
                          builder: (_, s) {
                            if (!s.hasData || s.data!.docs.isEmpty) return SizedBox();
                            return Positioned(
                              right: 0, top: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: kPrimary,
                              )
                            );
                          },
                        )
                      ],
                    ),
                  ),


                  const SizedBox(width: 10),

                  // QR Scan
                  IconButton(
                    icon: Icon(Iconsax.scan_barcode, color: kPrimary),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QrScanPage(),
                        ),
                      );

                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("QR Result: $result")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            TopCarousel(),
            const SizedBox(height: 20),

            Newreleases(),
            const SizedBox(height: 10),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admin_settings')
                  .doc('last_minute_deals')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return SizedBox();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final bool enabled = data['enabled'] ?? false;

                if (!enabled) return SizedBox(); // HIDE DEALS WHEN OFF

                return const LastMinuteDealsSection();
              },
            ),
            const SizedBox(height: 20),

            BestEvents(),
            const SizedBox(height: 10),

            Premiermovies(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------
//  AI PICK PAGE – Mood based selector
// ----------------------------------------
class AiPickPage extends StatefulWidget {
  const AiPickPage({super.key});

  @override
  State<AiPickPage> createState() => _AiPickPageState();
}

class _AiPickPageState extends State<AiPickPage> {
  final Random _random = Random();

  // Available moods
  final List<String> _moods = [
    'Happy',
    'Sad',
    'Romantic',
    'Thrilling',
    'Chill',
    'Family',
  ];

  // Movie suggestions per mood
  final Map<String, List<String>> _movieSuggestions = {
    'Happy': [
      '3 Idiots',
      'Zindagi Na Milegi Dobara',
      'Munna Bhai M.B.B.S.',
      'Yeh Jawaani Hai Deewani',
    ],
    'Sad': [
      'Tamasha',
      'Kal Ho Naa Ho',
      'Raanjhanaa',
      'Rockstar',
    ],
    'Romantic': [
      'Jab We Met',
      'Dilwale Dulhania Le Jayenge',
      'Ae Dil Hai Mushkil',
      'Aashiqui 2',
    ],
    'Thrilling': [
      'Drishyam',
      'Andhadhun',
      'Kahaani',
      'Special 26',
    ],
    'Chill': [
      'Wake Up Sid',
      'Dear Zindagi',
      'Barfi!',
      'Chhichhore',
    ],
    'Family': [
      'Hum Saath-Saath Hain',
      'Kabhi Khushi Kabhie Gham',
      'Bajrangi Bhaijaan',
      'Badhai Ho',
    ],
  };

  String? _selectedMood;
  String? _aiPick;

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
      _aiPick = null; // reset previous pick
    });
  }

  void _generateAiPick() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a mood first 🙂')),
      );
      return;
    }

    final movies = _movieSuggestions[_selectedMood] ?? [];
    if (movies.isEmpty) return;

    final index = _random.nextInt(movies.length);

    setState(() {
      _aiPick = movies[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AI Pick",
              style: TextStyle(
                fontSize: 24,
                fontFamily: primaryFont,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tell me your mood and I’ll suggest a movie.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "How are you feeling today?",
              style: TextStyle(
                fontSize: 16,
                fontFamily: primaryFont,
                fontWeight: FontWeight.w600,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 10),

            // Mood chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((mood) {
                final bool selected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
                  selected: selected,
                  onSelected: (_) => _selectMood(mood),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : darkColor,
                    fontFamily: primaryFont,
                  ),
                  selectedColor: kPrimary,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateAiPick,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Get AI Pick"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Show AI pick
            if (_aiPick != null) ...[
              Text(
                "Your AI Pick",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: primaryFont,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.movie, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _aiPick ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_selectedMood != null)
                              Text(
                                "Based on mood: $_selectedMood",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Show full list for selected mood
            if (_selectedMood != null) ...[
              Text(
                "More suggestions for $_selectedMood mood",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: primaryFont,
                  fontWeight: FontWeight.w600,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 8),
              ...(_movieSuggestions[_selectedMood] ?? []).map(
                    (movie) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.play_arrow),
                  title: Text(movie),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ----------------------------------------
//  PROFILE PAGE WITH USER + BOOKINGS
// ----------------------------------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String getTicketStatus(String date, String time) {
    try {
      DateTime showDateTime = DateTime.parse("$date $time");
      DateTime now = DateTime.now();

      if (now.isBefore(showDateTime)) {
        return "UPCOMING";
      }

      if (now.isAfter(showDateTime) &&
          now.difference(showDateTime).inHours <= 3) {
        return "ONGOING";
      }

      if (now.difference(showDateTime).inHours > 3 &&
          now.difference(showDateTime).inHours < 24) {
        return "COMPLETED";
      }

      return "EXPIRED";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // -----------------------------
    // NOT LOGGED IN
    // -----------------------------
    if (user == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.user, size: 80),
                const SizedBox(height: 16),
                Text(
                  "You are not logged in",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: primaryFont,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to see your profile and bookings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Login / Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: primaryFont,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }



    // -----------------------------
    // LOGGED IN → LOAD PROFILE + BOOKINGS
    // -----------------------------
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- USER INFO (from users collection) ----
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data =
                snapshot.data?.data() as Map<String, dynamic>?;

                final name = (data?["name"] ?? "User").toString();
                final email =
                (data?["email"] ?? user.email ?? "No email").toString();

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kPrimary.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "U",
                        style: TextStyle(
                          fontSize: 26,
                          color: kPrimary,
                          fontFamily: primaryFont,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: primaryFont,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

// -----------------------------
// 🔔 ADMIN NOTIFICATIONS
// -----------------------------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('isActive', isEqualTo: true)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(); // hide if no notifications
                }

                final docs = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: primaryFont,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications_active,
                            color: Colors.orange,
                          ),
                          title: Text(
                            data['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(data['message'] ?? ''),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),


            const SizedBox(height: 24),

            Text(
              "My Bookings",
              style: TextStyle(
                fontSize: 18,
                fontFamily: primaryFont,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 8),

            // ---- BOOKINGS LIST ----
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("bookings")
                    .where("userId", isEqualTo: user.uid)
                // no orderBy to avoid index for now
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading bookings",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No bookings yet"),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data()
                      as Map<String, dynamic>;

                      // 🔐 safely convert everything to String
                      final movieTitle =
                      (data["movieTitle"] ?? "Movie").toString();
                      final theatre =
                      (data["theatre"] ?? "Cinema").toString();
                      final showDate =
                      (data["showDate"] ?? "").toString();
                      final showTime =
                      (data["showTime"] ?? "").toString();
                      final status = getTicketStatus(showDate, showTime);
                      final seats =
                      (data["seats"] ?? "").toString();

                      int? amount;
                      if (data["amount"] is int) {
                        amount = data["amount"] as int;
                      } else if (data["amount"] != null) {
                        amount = int.tryParse(
                            data["amount"].toString());
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      movieTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == "UPCOMING"
                                          ? Colors.green
                                          : status == "ONGOING"
                                          ? Colors.orange
                                          : status == "COMPLETED"
                                          ? Colors.blue
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("🎬 Theatre: $theatre"),
                              Text("📅 $showDate • $showTime"),
                              Text("💺 Seats: $seats"),
                              if (amount != null) Text("💰 Paid: ₹$amount"),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('ride_schedules')
                                    .where('bookingId', isEqualTo: docs[index].id)
                                    .snapshots(),
                                builder: (context, rideSnap) {

                                  if (!rideSnap.hasData || rideSnap.data!.docs.isEmpty) {
                                    return const Text("🚕 No ride booked");
                                  }

                                  final rides = rideSnap.data!.docs;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: rides.map((r) {

                                      final ride = r.data() as Map<String, dynamic>;

                                      String label =
                                      ride['rideDirection'] == "goToTheatre"
                                          ? "🚗 Going"
                                          : "🏠 Returning";

                                      String status;

                                      switch (ride['status']) {
                                        case 'scheduled':
                                          status = 'Finding driver';
                                          break;
                                        case 'driver_assigned':
                                          status = 'Driver assigned';
                                          break;
                                        case 'arrived':
                                          status = 'Arrived';
                                          break;
                                        default:
                                          status = 'Scheduled';
                                      }

                                      return Text(
                                        "$label • $status",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );

                                    }).toList(),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookedTicketScreen(
                                          bookingId: docs[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.confirmation_number),
                                  label: const Text("Show Ticket"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
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

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PremiumPassPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "🎟️ Buy Premium Pass",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),


            // ---- LOGOUT BUTTON ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Iconsax.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



