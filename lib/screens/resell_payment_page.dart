import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/constants.dart';
import 'showticket.dart';

/// 🔥 PLATFORM COMMISSION (CHANGE LATER IF NEEDED)
const int PLATFORM_FEE = 20;

class ResellPaymentPage extends StatefulWidget {
  final String resaleId;
  final int amount;

  const ResellPaymentPage({
    super.key,
    required this.resaleId,
    required this.amount,
  });

  @override
  State<ResellPaymentPage> createState() => _ResellPaymentPageState();
}

class _ResellPaymentPageState extends State<ResellPaymentPage> {
  late Razorpay _razorpay;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // =========================
  // OPEN RAZORPAY
  // =========================
  void _openRazorpay() {
    final int totalAmount = widget.amount + PLATFORM_FEE;

    final options = {
      'key': 'rzp_test_Bonc0fLChoIiQP', // ✅ YOUR TEST KEY
      'amount': totalAmount * 100, // in paise
      'name': 'GrabUrTicket',
      'description': 'Resell Ticket Purchase',
      'prefill': {
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      },
      'theme': {
        'color': '#E53935',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay error: $e");
    }
  }

  // =========================
  // PAYMENT SUCCESS
  // =========================
  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final resaleRef = FirebaseFirestore.instance
        .collection('ticket_resales')
        .doc(widget.resaleId);

    final resaleSnap = await resaleRef.get();
    final resaleData = resaleSnap.data();

    if (resaleData == null || resaleData['status'] != 'available') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket already sold")),
        );
      }
      return;
    }

    // =========================
    // 1️⃣ CREATE BOOKING
    // =========================
    final bookingRef =
    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'movieTitle': resaleData['movieTitle'],
      'theatre': resaleData['theatre'],
      'showDate': resaleData['showDate'],
      'showTime': resaleData['showTime'],
      'seats': resaleData['seats'],

      // 💰 PAYMENT BREAKDOWN
      'ticketAmount': widget.amount,
      'platformFee': PLATFORM_FEE,
      'totalPaid': widget.amount + PLATFORM_FEE,

      'paymentId': response.paymentId,
      'resellPurchase': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // =========================
    // 2️⃣ CREATE SELLER PAYOUT
    // =========================
    await FirebaseFirestore.instance
        .collection('seller_payouts')
        .add({
      'sellerId': resaleData['sellerId'], // must exist in ticket_resales
      'resaleId': widget.resaleId,
      'bookingId': bookingRef.id,
      'amount': widget.amount, // seller gets ticket price
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'paidAt': null,
    });


    // =========================
    // 2️⃣ SAVE PLATFORM EARNING
    // =========================
    await FirebaseFirestore.instance
        .collection('platform_earnings')
        .add({
      'resaleId': widget.resaleId,
      'bookingId': bookingRef.id,
      'amount': PLATFORM_FEE,
      'paymentId': response.paymentId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // =========================
    // 3️⃣ UPDATE RESELL STATUS
    // =========================
    await resaleRef.update({
      'status': 'sold',
      'buyerId': user.uid,
      'soldAt': FieldValue.serverTimestamp(),
      'paymentId': response.paymentId,
    });

    // =========================
    // 4️⃣ NAVIGATE TO TICKET
    // =========================
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ShowTicket(bookingId: bookingRef.id),
        ),
            (_) => false,
      );
    }
  }

  // =========================
  // PAYMENT FAILED
  // =========================
  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed ❌")),
    );
  }

  void _handleWallet(ExternalWalletResponse response) {}

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Purchase"),
        backgroundColor: kPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Text(
              "Ticket: ₹${widget.amount}\n"
                  "Platform Fee: ₹$PLATFORM_FEE\n"
                  "Total: ₹${widget.amount + PLATFORM_FEE}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loading ? null : _openRazorpay,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Pay & Get Ticket",
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
