import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/constants.dart';

class PremiumPassPage extends StatefulWidget {
  const PremiumPassPage({super.key});

  @override
  State<PremiumPassPage> createState() => _PremiumPassPageState();
}

class _PremiumPassPageState extends State<PremiumPassPage> {
  late Razorpay _razorpay;
  bool isLoading = false;

  final int premiumPrice = 199; // ₹199
  final int freeMovies = 2;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_Bonc0fLChoIiQP',
      'amount': premiumPrice * 100,
      'name': 'Grab Ur Ticket',
      'description': 'Premium Movie Pass',
    };

    _razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'premiumPass': {
        'isActive': true,
        'remainingMovies': freeMovies,
        'startDate': now,
        'endDate': now.add(const Duration(days: 30)),
      }
    }, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Premium Activated!")),
      );
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Pass"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.black],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🎟️ Premium Movie Pass",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "• Watch $freeMovies movies FREE every month\n"
                        "• Valid for 30 days\n"
                        "• Works in your city theatres",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Buy for ₹$premiumPrice",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
