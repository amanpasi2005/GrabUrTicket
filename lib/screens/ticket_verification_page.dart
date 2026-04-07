import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qrcode_page.dart';

class TicketVerificationPage extends StatefulWidget {
  const TicketVerificationPage({super.key});

  @override
  State<TicketVerificationPage> createState() =>
      _TicketVerificationPageState();
}

class _TicketVerificationPageState
    extends State<TicketVerificationPage> {

  String resultText = "Press Scan to verify ticket";
  Color resultColor = Colors.white;

  Future<void> scanTicket() async {

    final qrData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScanPage(),
      ),
    );

    if (qrData == null) return;

    await verifyTicket(qrData);
  }

  Future<void> verifyTicket(String qrData) async {

    try {

      final parts = qrData.split("|");
      final bookingId = parts[0];

      final doc = await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .get();

      if (!doc.exists) {

        setState(() {
          resultText = "❌ Invalid Ticket";
          resultColor = Colors.red;
        });

        return;
      }

      final data = doc.data()!;

      if (data["isUsed"] == true) {

        setState(() {
          resultText = "⚠️ Ticket Already Used";
          resultColor = Colors.orange;
        });

        return;
      }

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .update({
        "isUsed": true,
        "checkedAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        resultText = "✅ Ticket Valid - Entry Allowed";
        resultColor = Colors.green;
      });

    } catch (e) {

      setState(() {
        resultText = "Error verifying ticket";
        resultColor = Colors.red;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Ticket Verification"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: Colors.grey[400],
            ),

            const SizedBox(height: 30),

            Text(
              resultText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan Ticket"),
                onPressed: scanTicket,
              ),
            ),

          ],
        ),
      ),
    );
  }
}