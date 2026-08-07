extension TurkishStringExtension on String {
  /// Converts the string to uppercase, respecting Turkish characters (i -> İ, ı -> I).
  String toTurkishUpperCase() {
    return replaceAll('i', 'İ')
          .replaceAll('ı', 'I')
          .toUpperCase();
  }
}
