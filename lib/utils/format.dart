extension DateTimeExtension on String {
  /// Converts a string representing milliseconds to a formatted date (YYYY-MM-DD).
  String toFormattedDate() {
    try {
      // Parse the string to an integer
      final milliseconds = int.tryParse(this);
      if (milliseconds == null) return "Invalid date";

      // Convert milliseconds to DateTime
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

      // Format the date
      return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}";
    } catch (e) {
      return "Invalid date";
    }
  }

  /// Helper to ensure two-digit formatting (e.g., 01, 02).
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}