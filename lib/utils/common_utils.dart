import 'package:intl/intl.dart';

String getFormattedDate() {
  DateTime now = DateTime.now();
  return DateFormat('EEEE, MMM d, y')
      .format(now); // Example: Sunday, Feb 23, 2025
}
