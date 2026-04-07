import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/foundation.dart';
import 'package:graburticket/model/constants.dart';
import 'package:graburticket/screens/showTicket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graburticket/screens/snack_selection_page.dart';
import 'package:graburticket/services/seat_unlock_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graburticket/services/ride_scheduler.dart';


class SeatsListings extends StatefulWidget {
  final String theatreCity;
  final String movieTitle;
  final String movieMetadata;

  final String showDateLabel;
  final String showTimeLabel;
  final String showDateValue;
  final String showTimeValue;

  const SeatsListings({
    super.key,
    required this.theatreCity,
    required this.movieTitle,
    required this.movieMetadata,
    required this.showDateLabel,
    required this.showTimeLabel,
    required this.showDateValue,
    required this.showTimeValue,
  });


  @override
  State<SeatsListings> createState() => _SeatsListingsState();
}



class _SeatsListingsState extends State<SeatsListings> {

  String selectedShowDateLabel = 'Today';
  String selectedShowTimeLabel = 'Morning';

  String selectedShowDateValue = '';
  String selectedShowTimeValue = '';

  bool canUsePremium = false;
  String userCity = '';
  int remainingMovies = 0;

  int neededSeats = 1;
  int selectedSeatCount = 0;
  String selectionImages = 'assets/images/bicycle.png';
  int calculatedPrice = 0;
  bool isLoading = false;

  List<String> selectedSeats = [];
  Set<String> soldSeats = {};
  List<String> autoSelectedSeats = [];
  Set<String> previousSoldSeats = {};
  Set<String> flashingSeats = {};
  int seatLayoutVersion = 0;
  int liveViewers = 0;
  late Razorpay _razorpay;

  Map<String, dynamic> seatStatus = {};




  @override
  void initState() {
    super.initState();

    //  RECEIVE REAL SHOW TIME
    selectedShowDateLabel = widget.showDateLabel;
    selectedShowTimeLabel = widget.showTimeLabel;
    selectedShowDateValue = widget.showDateValue;
    selectedShowTimeValue = widget.showTimeValue;

    updateLiveViewer(true);
    checkPremiumEligibility();
    releaseExpiredLocks();
    SeatUnlockService.releaseExpiredLocks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setBottomSheetState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // Ensures the bottom sheet takes only required height
                  children: [
                    Image.asset(
                      selectionImages,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            seatOptions.length,
                                (index) {
                              final seatSelectionOptions = seatOptions[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setBottomSheetState(() {
                                      final chosenSeatDetails =
                                      seatOptions[index];
                                      calculatedPrice = 0;
                                      selectionImages =
                                      chosenSeatDetails['image'];
                                      neededSeats = chosenSeatDetails['number'];
                                      print(chosenSeatDetails);
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: neededSeats == index + 1
                                          ? kPrimary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      seatSelectionOptions['number'].toString(),
                                      style: TextStyle(
                                          color: neededSeats == index + 1
                                              ? Colors.white
                                              : Colors.black,
                                          fontFamily: subtitleFonts),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        setBottomSheetState(() {
                          calculatedPrice = 0;
                          if (!canUsePremium) {
                            calculatedPrice = neededSeats * 200;
                          } else {
                            calculatedPrice = 0;
                          }
                          print(calculatedPrice);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        height: 38,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text(
                          'Select seats',
                          style: TextStyle(
                              color: Colors.white, fontFamily: primaryFont),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    });

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      handlePaymentErrorResponse,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      handlePaymentSuccessResponse,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      handleExternalWalletSelected,
    );

  }

  Future<void> checkPremiumEligibility() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    final premium = data['premiumPass'];

    if (premium != null &&
        premium['isActive'] == true &&
        premium['remainingMovies'] > 0) {
      setState(() {
        canUsePremium = true;
        remainingMovies = premium['remainingMovies'];
      });
    } else {
      setState(() {
        canUsePremium = false;
        remainingMovies = 0;
      });
    }
  }

  int getSeatPrice(String seatNumber) {

    int row = seatNumber.codeUnitAt(0) - 65; // A=0, B=1...

    /// PLATINUM (center rows)
    if (row >= 8 && row <= 14) {
      return 350;
    }

    /// GOLD
    if (row >= 4 && row <= 7) {
      return 250;
    }

    /// SILVER
    return 180;
  }

  bool isHotSeat(String seat) {

    int row = seat.codeUnitAt(0) - 65;
    int col = int.parse(seat.substring(1));

    return row >= 9 && row <= 13 && col >= 13 && col <= 20;
  }

  Color getSeatHeatColor(String seatNumber) {

    int row = seatNumber.codeUnitAt(0) - 65;
    int col = int.parse(seatNumber.substring(1));

    double rowScore = 1 - ((row - 11).abs() / 11);
    double colScore = 1 - ((col - 16).abs() / 16);

    double score = ((rowScore + colScore) / 2) * 100;

    if (score > 85) return Colors.green;
    if (score > 70) return Colors.yellow;
    if (score > 50) return Colors.blue;

    return Colors.grey;
  }


  double calculateSeatExperience() {

    if (selectedSeats.isEmpty) return 0;

    double score = 0;

    for (var seat in selectedSeats) {

      int row = seat.codeUnitAt(0) - 65;
      int col = int.parse(seat.substring(1));

      double rowScore = 1 - ((row - 11).abs() / 11);
      double colScore = 1 - ((col - 16).abs() / 16);

      score += ((rowScore + colScore) / 2) * 100;

    }

    return score / selectedSeats.length;
  }

  String getSeatQuality(double score) {

    if (score > 85) return "🎬 Perfect View";
    if (score > 70) return "👍 Great Seats";
    if (score > 50) return "🙂 Decent View";
    return "⚠ Limited View";

  }

  String getCrowdLevel() {

    int sold = 0;

    seatStatus.forEach((seat, value) {
      if (value == "sold") sold++;
    });

    if (sold > 200) return "🔥 Almost Full";
    if (sold > 120) return "⚠ Filling Fast";
    if (sold > 60) return "🙂 Moderate";
    return "🟢 Plenty of Seats";

  }

  int getAvailableSeats() {

    int sold = 0;

    seatStatus.forEach((seat, value) {
      if (value == "sold") sold++;
    });

    int totalSeats = 0;

    for (int row = 0; row < 22; row++) {

      int curveOffset = (row / 2).floor();

      for (int col = 0; col < 33; col++) {

        if (col < curveOffset) continue;
        if (col > 32 - curveOffset) continue;
        if (col == 16) continue;

        totalSeats++;
      }
    }

    return totalSeats - sold;
  }


  List<List<SeatState>> generateSeatLayout() {

    List<List<SeatState>> layout = [];
    final user = FirebaseAuth.instance.currentUser;

    for (int row = 0; row < 22; row++) {

      List<SeatState> rowSeats = [];

      /// CURVED ROW SHAPE
      int curveOffset = (row / 2).floor();

      for (int col = 0; col < 33; col++) {

        /// LEFT CURVE CUT
        if (col < curveOffset) {
          rowSeats.add(SeatState.disabled);
          continue;
        }

        /// RIGHT CURVE CUT
        if (col > 32 - curveOffset) {
          rowSeats.add(SeatState.disabled);
          continue;
        }

        /// CENTER AISLE
        if (col == 16) {
          rowSeats.add(SeatState.disabled);
          continue;
        }

        String seatNumber = "${String.fromCharCode(65 + row)}${col + 1}";

        /// SOLD / LOCKED CHECK

        /// SELECTED SEATS (HIGHEST PRIORITY)
        if (selectedSeats.contains(seatNumber)) {
          rowSeats.add(SeatState.selected);
          continue;
        }

        /// FLASH EFFECT
        if (flashingSeats.contains(seatNumber)) {
          rowSeats.add(SeatState.selected);
          continue;
        }

        /// SOLD / LOCKED CHECK
        if (seatStatus.containsKey(seatNumber)) {

          var seat = seatStatus[seatNumber];

          /// SOLD
          if (seat == "sold") {
            rowSeats.add(SeatState.sold);
            continue;
          }

          /// LOCKED
          if (seat is Map && seat["status"] == "locked") {

            if (seat["lockedBy"] == user?.uid) {
              Color heatColor = getSeatHeatColor(seatNumber);

              rowSeats.add(SeatState.unselected);
            } else {
              rowSeats.add(SeatState.disabled);
            }

            continue;
          }
        }

        /// SELECTED SEATS (turn green)
        if (selectedSeats.contains(seatNumber)) {
          rowSeats.add(SeatState.selected);
          continue;
        }

        /// VIP CENTER ZONE
        if (isHotSeat(seatNumber)) {
          rowSeats.add(SeatState.unselected);
        }

        /// NORMAL SEAT
        else {
          rowSeats.add(SeatState.unselected);
        }
      }

      layout.add(rowSeats);
    }

    return layout;
  }

  List<String> suggestBestSeats() {

    autoSelectedSeats.clear();

    int centerRow = 11;
    int centerCol = 16;

    for (int r = centerRow - 4; r <= centerRow + 4; r++) {

      int consecutive = 0;
      List<String> tempSeats = [];

      for (int offset = 0; offset < 16; offset++) {

        List<int> cols = [centerCol - offset, centerCol + offset];

        for (int c in cols) {

          if (c < 0 || c >= 33) continue;
          if (c == 16) continue;

          String seat = "${String.fromCharCode(65 + r)}${c + 1}";

          if (!seatStatus.containsKey(seat)) {

            tempSeats.add(seat);
            consecutive++;

            if (consecutive == neededSeats) {
              return tempSeats;
            }

          } else {

            tempSeats.clear();
            consecutive = 0;

          }
        }
      }
    }

    return [];
  }

  Future<void> releaseExpiredLocks() async {

    final docId =
        "${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}";

    final snapshot = await FirebaseFirestore.instance
        .collection('seat_status')
        .doc(docId)
        .get();

    if (!snapshot.exists) return;

    final data = snapshot.data();

    if (data == null) return;

    final now = DateTime.now();

    Map<String, dynamic> updates = {};

    data.forEach((seat, value) {

      if (value is Map && value["status"] == "locked") {

        Timestamp? lockedAt = value["lockedAt"];

        if (lockedAt != null) {

          DateTime lockTime = lockedAt.toDate();

          if (now.difference(lockTime).inMinutes >= 5) {

            updates[seat] = FieldValue.delete();

          }

        }

      }

    });

    if (updates.isNotEmpty) {

      await FirebaseFirestore.instance
          .collection('seat_status')
          .doc(docId)
          .update(updates);

    }

  }

  Future<void> updateLiveViewer(bool entering) async {

    final docId =
        "${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}";

    final ref = FirebaseFirestore.instance
        .collection("live_show_activity")
        .doc(docId);

    await FirebaseFirestore.instance.runTransaction((tx) async {

      final snap = await tx.get(ref);

      int viewers = 0;

      if (snap.exists) {
        viewers = snap["viewers"] ?? 0;
      }

      viewers = entering ? viewers + 1 : viewers - 1;

      if (viewers < 0) viewers = 0;

      tx.set(ref, {"viewers": viewers}, SetOptions(merge: true));

    });
  }


  Future<void> lockSeat(String seatNumber) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId =
        "${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}";

    await FirebaseFirestore.instance
        .collection('seat_status')
        .doc(docId)
        .set({
      seatNumber: {
        "status": "locked",
        "lockedBy": user.uid,
        "lockedAt": FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Widget _heatLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
                  child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [

                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffcfd8dc),
                          Colors.white,
                          Color(0xffcfd8dc),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(140),
                        bottomRight: Radius.circular(140),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "SCREEN THIS WAY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  Text(
                    "PLATINUM ₹350 | GOLD ₹250 | SILVER ₹180",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Crowd Level: ${getCrowdLevel()}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),

                  Text(
                    "Available Seats: ${getAvailableSeats()}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("live_show_activity")
                        .doc("${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}")
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox();
                      }

                      int viewers = snapshot.data!["viewers"] ?? 0;

                      if (viewers <= 1) return const SizedBox();

                      return Text(
                        "🔥 $viewers people viewing this show",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {

                        List<String> bestSeats = suggestBestSeats();

                        if (bestSeats.isEmpty) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No good seats available")),
                          );

                          return;
                        }

                        setState(() {

                          selectedSeats.clear();
                          selectedSeatCount = 0;
                          calculatedPrice = 0;

                          for (var seat in bestSeats) {

                            selectedSeatCount++;

                            calculatedPrice += getSeatPrice(seat);

                            flashingSeats.add(seat);
                            selectedSeats.add(seat);

                            lockSeat(seat); //  prevent others booking
                          }

                          seatLayoutVersion++;   // rebuild seat grid

                        });


                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              flashingSeats.clear();
                            });
                          }
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Best seats selected: ${bestSeats.join(", ")}")),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text("Suggest Best Seats"),
                    ),
                  ),
                ],
              ),
            ),

              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('seat_status')
                        .doc("${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}")
                        .snapshots(),
                    builder: (context, snapshot) {

                      if (snapshot.hasData && snapshot.data!.exists) {

                        seatStatus = snapshot.data!.data() as Map<String, dynamic>;

                        Set<String> updatedSoldSeats = {};

                        seatStatus.forEach((seat, value) {
                          if (value == "sold") {
                            updatedSoldSeats.add(seat);
                          }
                        });

                        if (!setEquals(updatedSoldSeats, soldSeats)) {

                          final newlySold = updatedSoldSeats.difference(previousSoldSeats);

                          if (newlySold.isNotEmpty) {

                            flashingSeats.addAll(newlySold);

                            Future.delayed(const Duration(milliseconds: 900), () {
                              if (mounted) {
                                setState(() {
                                  flashingSeats.removeAll(newlySold);
                                });
                              }
                            });

                            Future.microtask(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 800),
                                  content: Text("Seat booked: ${newlySold.join(", ")}"),
                                ),
                              );
                            });
                          }

                          soldSeats = updatedSoldSeats;
                          previousSoldSeats = Set.from(updatedSoldSeats);
                          seatLayoutVersion++;
                        }
                      }

                      return SingleChildScrollView(
                        child: InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// SEAT NUMBER HEADER
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 28),
                                    ...List.generate(
                                      33,
                                          (i) => SizedBox(
                                        width: 26,
                                        child: Center(
                                          child: Text(
                                            "${i + 1}",
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _heatLegend(Colors.green, "Best View"),
                                  _heatLegend(Colors.yellow, "Good"),
                                  _heatLegend(Colors.blue, "Normal"),
                                  _heatLegend(Colors.grey, "Edge"),
                                ],
                              ),

                              const SizedBox(height: 6),

                              /// SEAT GRID
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// ROW LABELS
                                    Column(
                                      children: List.generate(
                                        22,
                                            (index) => SizedBox(
                                          height: 26,
                                          width: 22,
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateX(0.12),
                                      child: SeatLayoutWidget(
                                        key: ValueKey(seatLayoutVersion),
                                        stateModel: SeatLayoutStateModel(
                                          rows: 22,
                                          cols: 33,
                                          currentSeatsState: generateSeatLayout(),
                                          seatSvgSize: 32,
                                          pathSelectedSeat: 'assets/images/seat_selected.svg',
                                          pathDisabledSeat: 'assets/images/seat_disabled.svg',
                                          pathSoldSeat: 'assets/images/seat_sold.svg',
                                          pathUnSelectedSeat: 'assets/images/seat_unselected.svg',
                                        ),
                                        onSeatStateChanged: (rowI, colI, currentState) async {

                                          String seatNumber =
                                              "${String.fromCharCode(65 + rowI)}${colI + 1}";

                                          if (currentState == SeatState.selected) {

                                            selectedSeatCount++;
                                            selectedSeats.add(seatNumber);

                                            calculatedPrice += getSeatPrice(seatNumber);

                                            await lockSeat(seatNumber);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                duration: const Duration(milliseconds: 400),
                                                content: Text("Seat $seatNumber selected"),
                                              ),
                                            );

                                          } else if (currentState == SeatState.unselected) {

                                            selectedSeatCount--;
                                            selectedSeats.remove(seatNumber);

                                            calculatedPrice -= getSeatPrice(seatNumber);

                                          }

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// SECTION LABELS
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "PLATINUM",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "GOLD",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "SILVER",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (selectedSeats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Seat Experience Score: ${calculateSeatExperience().toStringAsFixed(1)}%  ${getSeatQuality(calculateSeatExperience())}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),

            if (selectedSeats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "Selected Seats: ${selectedSeats.join(", ")}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

            SizedBox(height: 30),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                SvgPicture.asset(
                  'assets/images/seat_selected.svg',
                  height: 30,
                  width: 30,
                ),
                Text(
                  'Selected seat',
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
                SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/images/seat_unselected.svg',
                  height: 30,
                  width: 30,
                ),
                Text(
                  'Available seat',
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
                SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/images/seat_sold.svg',
                  height: 30,
                  width: 30,
                ),
                Text(
                  'Sold seat',
                  style: TextStyle(color: Colors.grey[800], fontSize: 12),
                ),
              ],
            ),

            SizedBox(height: 20),

            selectedSeatCount == neededSeats
                ? GestureDetector(
              onTap: () async {
                final blocked = await _isUserBlocked();

                if (blocked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Your account is blocked. Please contact support."),
                    ),
                  );
                  return;
                }

                if (canUsePremium) {
                  await bookWithPremium();
                } else {
                  startRazorpayPayment();
                }
              },
              child: Container(
                height: 48,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0,4),
                    )
                  ],
                ),
                child: Text(
                  canUsePremium
                      ? 'Book FREE (Premium Pass)'
                      : 'Pay ₹$calculatedPrice',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: primaryFont,
                    fontSize: textSubTitle,
                  ),
                ),
              ),
            ) : Container(),

            SizedBox(height: 30),
          ],
      ),
      ),
    ),
    ),
    )
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    print(response.code);
  }

  Future<void> handlePaymentSuccessResponse(
      PaymentSuccessResponse response) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookingRef =
    FirebaseFirestore.instance.collection('bookings').doc();

    final bookingSnap = await bookingRef.get();
    final bookingData = bookingSnap.data() ?? {};

    await bookingRef.set({
      'userId': user.uid,
      'amount': calculatedPrice,
      'seatsCount': selectedSeats.length,
      'createdAt': DateTime.now(),
      'movieTitle': widget.movieTitle,
      'theatre': widget.theatreCity,
      'seats': selectedSeats,

      // ✅ ALWAYS READ FROM FIRESTORE (SET BY ShowTiming)
      // UI DISPLAY
      'showDate': selectedShowDateLabel,
      'showTime': selectedShowTimeLabel,

      // 🔥 REAL VALUES (USED BY RIDE)
      'showDateValue': selectedShowDateValue,
      'showTimeValue': selectedShowTimeValue,


      'autoRideEnabled': true,
    });
    await FirebaseFirestore.instance
        .collection('seat_status')
        .doc("${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}")
        .set(
      {
        for (var seat in selectedSeats) seat: "sold"
      },
      SetOptions(merge: true),
    );


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SnackSelectionPage(
          bookingId: bookingRef.id,
          movieTitle: widget.movieTitle,
          theatre: widget.theatreCity,
          seatNumber: selectedSeats.join(","),
          ticketPrice: calculatedPrice ~/ selectedSeats.length,
        ),
      ),
    );
  }




  void handleExternalWalletSelected(PaymentSuccessResponse response) {
    print(response.paymentId);
  }

  Future<void> bookWithPremium() async {
    final blocked = await _isUserBlocked();
    if (blocked) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final premium = snap['premiumPass'];

      tx.update(userRef, {
        'premiumPass.remainingMovies': premium['remainingMovies'] - 1,
      });
    });

    final bookingRef =
    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'amount': calculatedPrice,
      'seatsCount': selectedSeats.length,
      'createdAt': DateTime.now(),
      'movieTitle': widget.movieTitle,
      'theatre': widget.theatreCity,
      'showDate': selectedShowDateLabel,
      'showTime': selectedShowTimeLabel,
      'showDateValue': selectedShowDateValue,
      'showTimeValue': selectedShowTimeValue,
      'seats': selectedSeats,
      'autoRideEnabled': true,
    });
    await FirebaseFirestore.instance
        .collection('seat_status')
        .doc("${widget.movieTitle}_${widget.theatreCity}_${selectedShowDateValue}_${selectedShowTimeValue}")
        .set(
      {
        for (var seat in selectedSeats) seat: "sold"
      },
      SetOptions(merge: true),
    );


    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SnackSelectionPage(
            bookingId: bookingRef.id,
            movieTitle: widget.movieTitle,
            theatre: widget.theatreCity,
            seatNumber: selectedSeats.join(","),
            ticketPrice: calculatedPrice ~/ selectedSeats.length,
          ),
        ),
      );
    }
  }

  Future<bool> _isUserBlocked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return false;

    return doc.data()?['isBlocked'] == true;
  }




  void startRazorpayPayment() {

    var options = {
      'key': 'rzp_test_Bonc0fLChoIiQP',
      'amount': calculatedPrice * 100,
      'name': 'Grab Ur Ticket',
      'description': 'Movie Ticket',
      'retry': {'enabled': true, 'max_count': 1},
      'prefill': {
        'contact': '',
        'email': ''
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Razorpay error: $e");
    }
  }


}