import 'package:flutter/foundation.dart';

class DateTimeProvider with ChangeNotifier {

  String tag = "[DateTimeProvider]";

  late DateTime now;

  DateTimeProvider() {
    now = DateTime.now();
    if (kDebugMode) {
      print("$tag _ ${now.toString()}");
    }
  }

}
