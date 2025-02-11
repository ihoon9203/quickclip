class Printer {
  static void printTime(String message) {
    print('[Time] $message: ${DateTime.now().millisecondsSinceEpoch}');
  }
}