class AIRecommendationService {

  static Map<String, dynamic>? recommendTheatre(
      List theatres,
      List<String> favouriteTheatres) {

    if (theatres.isEmpty) return null;

    theatres.sort((a, b) {

      double scoreA = calculateScore(a, favouriteTheatres);
      double scoreB = calculateScore(b, favouriteTheatres);

      return scoreA.compareTo(scoreB);
    });

    return theatres.first;
  }

  static double calculateScore(
      Map theatre,
      List<String> favouriteTheatres) {

    double distanceScore = (theatre["distance"] ?? 0).toDouble();
    double seatScore = (theatre["availableSeats"] ?? 50).toDouble();

    bool isFavourite =
    favouriteTheatres.contains(theatre["name"]);

    double favouriteBonus = isFavourite ? -5 : 0;

    return distanceScore +
        (100 - seatScore) * 0.1 +
        favouriteBonus;
  }
}