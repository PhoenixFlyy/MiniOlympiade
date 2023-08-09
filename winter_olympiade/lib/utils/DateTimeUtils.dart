String dateTimeToString(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String second = dateTime.second.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute:$second';
}

DateTime stringToDateTime(String dateString) {
  List<String> parts = dateString.split(' ');
  List<String> dateParts = parts[0].split('-');
  List<String> timeParts = parts[1].split(':');

  int year = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int day = int.parse(dateParts[2]);
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  int second = int.parse(timeParts[2]);

  return DateTime(year, month, day, hour, minute, second);
}
