class SmartRecommendationService {

  static Map<String, dynamic>? getRecommended(List theatres) {

    if (theatres.isEmpty) return null;

    theatres.sort((a, b) {

      double scoreA =
          (a["distance"] ?? 10) +
              ((a["bookedSeats"] ?? 0) / (a["totalSeats"] ?? 100));

      double scoreB =
          (b["distance"] ?? 10) +
              ((b["bookedSeats"] ?? 0) / (b["totalSeats"] ?? 100));

      return scoreA.compareTo(scoreB);
    });

    return theatres.first;
  }
}