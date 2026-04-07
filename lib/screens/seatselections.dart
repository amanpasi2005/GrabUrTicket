import 'package:flutter/material.dart';
import 'package:graburticket/components/seatselections/seatListing.dart';
import 'package:graburticket/model/constants.dart';

class Seatselections extends StatelessWidget {
  final Map<String, dynamic> movie;

  const Seatselections({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie['title'],
              style: TextStyle(
                color: darkColor,
                fontSize: textContent,
                fontFamily: primaryFont,
              ),
            ),
            Text(
              'Cinepolis Mumbai Maharashtra',
              style: TextStyle(
                color: darkColor,
                fontSize: 12,
                fontFamily: subtitleFonts,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SeatsListings(
        theatreCity: "Mumbai",
        movieTitle: movie['title'],
        movieMetadata: movie['metadata'],

        // 🔥 TEMP DEFAULTS (WILL BE OVERWRITTEN BY ShowTiming)
        showDateLabel: 'Today',
        showTimeLabel: 'Morning',
        showDateValue: DateTime.now()
            .toIso8601String()
            .split('T')
            .first,
        showTimeValue: '09:00 AM',
      ),

    );
  }
}
