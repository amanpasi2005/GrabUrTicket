import 'package:flutter/material.dart';
import 'package:graburticket/model/constants.dart';

class CastDetails extends StatefulWidget {
  final List<Map<String, dynamic>> peopleDetails;
  final String title;

  const CastDetails({
    super.key,
    required this.peopleDetails,
    required this.title,
  });

  @override
  State<CastDetails> createState() => _CastDetailsState();
}

class _CastDetailsState extends State<CastDetails> {
  @override
  Widget build(BuildContext context) {
    final people = widget.peopleDetails; // 👈 shorthand

    if (people.isEmpty) {
      // optional: hide completely if no data
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.black,
                fontFamily: primaryFont,
                fontSize: textContent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: people.length,              // ✅ was castDetails.length
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final castingDetails = people[index]; // ✅ widget.peopleDetails[index]

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          castingDetails['imageUrl'],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 90,
                        child: Text(
                          castingDetails['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: primaryFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 90,
                        child: Text(
                          castingDetails['role'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: primaryFont,
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
