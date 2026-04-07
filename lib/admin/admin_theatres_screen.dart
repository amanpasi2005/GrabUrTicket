import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/admin/admin_map_picker.dart';

class AdminTheatresScreen extends StatefulWidget {
  const AdminTheatresScreen({super.key});

  @override
  State<AdminTheatresScreen> createState() => _AdminTheatresScreenState();
}

class _AdminTheatresScreenState extends State<AdminTheatresScreen> {

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  double? lat;
  double? lng;

  bool isSaving = false;

  /// ================= ADD THEATRE =================
  Future<void> addTheatre() async {

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter theatre name")),
      );
      return;
    }

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick theatre location")),
      );
      return;
    }

    try {

      setState(() => isSaving = true);

      await FirebaseFirestore.instance.collection("theatres").add({

        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),

        "lat": lat,
        "lng": lng,

        "supportsSeatDelivery": true,
        "createdAt": FieldValue.serverTimestamp()

      });

      nameController.clear();
      addressController.clear();
      cityController.clear();

      lat = null;
      lng = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Theatre added successfully")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {
      setState(() => isSaving = false);
    }
  }

  /// ================= DELETE THEATRE =================
  Future<void> deleteTheatre(String id) async {

    await FirebaseFirestore.instance
        .collection("theatres")
        .doc(id)
        .delete();
  }

  /// ================= MAP PICKER =================
  Future<void> pickLocation() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminMapPicker(),
      ),
    );

    if (result != null) {
      setState(() {
        lat = result.latitude;
        lng = result.longitude;
      });
    }
  }

  /// ================= DISPOSE =================
  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Manage Theatres"),
      ),

      body: Column(
        children: [

          /// ================= ADD THEATRE FORM =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Theatre Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "City",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// MAP PICKER
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: Text(
                      lat == null
                          ? "Pick Theatre Location"
                          : "Location Selected",
                    ),
                    onPressed: pickLocation,
                  ),

                  if (lat != null && lng != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Selected Location: $lat , $lng",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  const SizedBox(height: 12),

                  /// ADD BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : addTheatre,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text("Add Theatre"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          /// ================= THEATRE LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("theatres")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No theatres added yet"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data["name"] ?? "Unknown Theatre";
                    final address = data["address"] ?? "";
                    final city = data["city"] ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6),
                      child: ListTile(

                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text("$address $city"),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => deleteTheatre(doc.id),
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}