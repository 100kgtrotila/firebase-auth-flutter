class DateFormatter {
  const DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final day = twoDigits(dateTime.day);
    final month = twoDigits(dateTime.month);
    final year = dateTime.year.toString();
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);

    return '$day.$month.$year $hour:$minute';
  }
}
