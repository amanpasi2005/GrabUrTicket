import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  bool sending = false;
  late TabController _tabController;

  String selectedCity = 'ALL';

  final List<String> cities = [
    'ALL',
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Pune',
  ];

  DateTime? scheduledAt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> sendNotification() async {
    if (titleController.text.isEmpty ||
        messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => sending = true);

    final notifRef =
    FirebaseFirestore.instance.collection('notifications').doc();

    final bool isScheduled = scheduledAt != null;

    await notifRef.set({
      'title': titleController.text.trim(),
      'message': messageController.text.trim(),
      'city': selectedCity,
      'isActive': true,
      'status': isScheduled ? 'scheduled' : 'sent',
      'sendAt': scheduledAt,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Analytics init (already done in B)
    await FirebaseFirestore.instance
        .collection('notification_analytics')
        .doc(notifRef.id)
        .set({
      'sentCount': 0,
      'openCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔔 PUSH TO USER INBOX (ONLY IF NOT SCHEDULED)
    if (!isScheduled) {
      final usersSnap =
      await FirebaseFirestore.instance.collection('users').get();

      int sentCount = 0;

      for (var userDoc in usersSnap.docs) {
        final user = userDoc.data();
        final uid = userDoc.id;

        if (selectedCity == 'ALL' || user['city'] == selectedCity) {
          await FirebaseFirestore.instance
              .collection('user_notifications')
              .doc(uid)
              .collection('items')
              .add({
            'notificationId': notifRef.id, // ⭐ ADD THIS
            'title': titleController.text.trim(),
            'message': messageController.text.trim(),
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });


          sentCount++;
        }
      }

      // Update analytics sent count
      await FirebaseFirestore.instance
          .collection('notification_analytics')
          .doc(notifRef.id)
          .update({
        'sentCount': FieldValue.increment(sentCount),
      });
    }


    setState(() {
      sending = false;
      scheduledAt = null;
      selectedCity = 'ALL';
    });

    titleController.clear();
    messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isScheduled
              ? "Notification scheduled ⏰"
              : "Notification sent ✅",
        ),
      ),
    );

    _tabController.animateTo(1);
  }


  Future<void> disableNotification(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'isActive': false});
  }

  Future<void> sendScheduledNow(
      String notificationId,
      String city,
      ) async {
    final usersSnap =
    await FirebaseFirestore.instance.collection('users').get();

    final notifSnap = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .get();

    if (!notifSnap.exists) return;

    final notifData = notifSnap.data() as Map<String, dynamic>;

    int sentCount = 0;

    for (var userDoc in usersSnap.docs) {
      final user = userDoc.data();
      final uid = userDoc.id;

      if (city == 'ALL' || user['city'] == city) {
        await FirebaseFirestore.instance
            .collection('user_notifications')
            .doc(uid)
            .collection('items')
            .add({
          'title': notifData['title'],
          'message': notifData['message'],
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        sentCount++;
      }
    }

    // Mark notification as sent
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({
      'status': 'sent',
    });

    // Update analytics
    await FirebaseFirestore.instance
        .collection('notification_analytics')
        .doc(notificationId)
        .update({
      'sentCount': FieldValue.increment(sentCount),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Scheduled notification sent manually ✅"),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Admin Notifications"),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Send"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ================= SEND TAB =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items: cities
                      .map(
                        (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedCity = v);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Target City",
                    border: OutlineInputBorder(),
                  ),
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    scheduledAt == null
                        ? "Schedule (Optional)"
                        : "Scheduled: ${scheduledAt!.toLocal()}",
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );

                    if (date == null) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time == null) return;

                    setState(() {
                      scheduledAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Notification Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Notification Message",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sending ? null : sendNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: sending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Send Notification",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= HISTORY TAB =================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("No notifications yet"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final isActive = data['isActive'] == true;
                  final createdAt =
                  (data['createdAt'] as Timestamp?)?.toDate();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE + STATUS
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  isActive ? "ACTIVE" : "DISABLED",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: isActive ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(data['message'] ?? ''),

                          if (data['status'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Status: ${data['status']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: data['status'] == 'scheduled'
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          if (data['sendAt'] != null)
                            Text(
                              "Scheduled for: ${(data['sendAt'] as Timestamp).toDate()}",
                              style: const TextStyle(fontSize: 12),
                            ),

                          if (createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Sent: ${createdAt.toLocal()}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // 📊 ANALYTICS
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('notification_analytics')
                                .doc(doc.id)
                                .get(),
                            builder: (context, snap) {
                              if (!snap.hasData || !snap.data!.exists) {
                                return const SizedBox();
                              }

                              final a = snap.data!.data() as Map<String, dynamic>;

                              return Row(
                                children: [
                                  Text("📤 Sent: ${a['sentCount'] ?? 0}",
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 16),
                                  Text("👁 Opened: ${a['openCount'] ?? 0}",
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🔘 ACTION BUTTONS (NO OVERFLOW)
                          Row(
                            children: [
                              if (data['status'] == 'scheduled')
                                ElevatedButton(
                                  onPressed: () => sendScheduledNow(
                                    doc.id,
                                    data['city'] ?? 'ALL',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text(
                                    "SEND NOW",
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),

                              const Spacer(),

                              if (isActive)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => disableNotification(doc.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
