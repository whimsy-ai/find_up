import 'package:intl/intl.dart';

String formatDate(DateTime date) =>
    DateFormat('yyyy-MM-dd – HH:mm:ss').format(date);
