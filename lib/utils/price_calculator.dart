class PriceCalculator {
  /// Returns the final price after applying last minute deal discount.
  static int applyDiscount({
    required int originalPrice,
    required bool isDeal,
    required int discountPercent,
  }) {
    // If no deal, return original price
    if (!isDeal || discountPercent <= 0) {
      return originalPrice;
    }

    // Safety check
    if (discountPercent >= 100) {
      return 0;
    }

    final int discountAmount =
        (originalPrice * discountPercent) ~/ 100;

    final int finalPrice = originalPrice - discountAmount;

    return finalPrice < 0 ? 0 : finalPrice;
  }

  /// Returns how much amount the user saved
  static int savings({
    required int originalPrice,
    required int finalPrice,
  }) {
    return originalPrice > finalPrice
        ? originalPrice - finalPrice
        : 0;
  }
}
