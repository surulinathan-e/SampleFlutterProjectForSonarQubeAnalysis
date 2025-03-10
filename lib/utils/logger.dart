import 'package:flutter/foundation.dart';

class Logger {
  static printLog(message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
