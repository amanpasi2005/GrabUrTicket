import 'package:graburticket/components/ticketbooking/cinemalisting.dart';
import 'package:graburticket/model/constants.dart';
import 'package:flutter/material.dart';

class Ticketbookingscreen extends StatefulWidget {
  final int movieIndex;

  const Ticketbookingscreen({
    super.key,
    required this.movieIndex,
  });

  @override
  State<Ticketbookingscreen> createState() => _TicketbookingscreenState();
}

class _TicketbookingscreenState extends State<Ticketbookingscreen> {
  @override
  Widget build(BuildContext context) {
    final movie = movieData[widget.movieIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          movie['title'],
          style: TextStyle(
            color: darkColor,
            fontSize: textContent,
            fontFamily: primaryFont,
          ),
        ),
      ),
      backgroundColor: Colors.white,

      /// ✅ FIXED: NO ScrollView, NO Column
      body: CinemaTimings(movie: movie),
    );
  }
}