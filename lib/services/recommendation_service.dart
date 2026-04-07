class RecommendationService {

  static Map<String, dynamic>? getRecommended(List theatres) {

    if (theatres.isEmpty) return null;

    theatres.sort(
          (a, b) => a["distance"].compareTo(b["distance"]),
    );

    return theatres.first;
  }
}