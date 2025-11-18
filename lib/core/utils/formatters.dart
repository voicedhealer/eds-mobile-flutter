class Formatters {
  static String formatPrice(double? price) {
    if (price == null) return 'Prix non disponible';
    return '${price.toStringAsFixed(2)} €';
  }

  static String formatPriceRange(double? min, double? max) {
    if (min == null && max == null) return 'Prix non disponible';
    if (min == null) return 'Jusqu\'à ${formatPrice(max)}';
    if (max == null) return 'À partir de ${formatPrice(min)}';
    return '${formatPrice(min)} - ${formatPrice(max)}';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

