import 'dart:convert';
import 'package:flutter/foundation.dart';

mixin ColorLog {
  static cyan(message) {
    if (kDebugMode) {
      print('\x1B[36m$message\x1B[0m');
    }
  }

  static magenta(message) {
    if (kDebugMode) {
      print('\x1B[35m$message\x1B[0m');
    }
  }

  static blue(message) {
    if (kDebugMode) {
      print('\x1B[34m$message\x1B[0m');
    }
  }

  static black(message) {
    if (kDebugMode) {
      print('\x1B[34m$message\x1B[0m');
    }
  }

  static yellow(message) {
    if (kDebugMode) {
      print('\x1B[33m$message\x1B[0m');
    }
  }

  static white(message) {
    if (kDebugMode) {
      print('\x1B[33m$message\x1B[0m');
    }
  }

  static devLog(Map<String, dynamic> message) {
    var encoder = const JsonEncoder.withIndent('  ');
    String prettyJson = encoder.convert(message);
    String coloredJson = prettyJson
        .replaceAllMapped(
        RegExp(r'"(\w+)":'), (match) => '\x1B[36m${match.group(0)}\x1B[0m')
        .replaceAllMapped(RegExp(r':\s"([^"]+)"'),
            (match) => ':\x1B[36m "${match.group(1)}"\x1B[0m')
        .replaceAllMapped(RegExp(r':\s(\d+)'),
            (match) => ':\x1B[36m ${match.group(1)}\x1B[0m');
    if (kDebugMode) {
      debugPrint(coloredJson);
    }
  }

  static devLogWithType(
      {required String type, required Map<String, dynamic> message}) {
    var encoder = const JsonEncoder.withIndent('  ');
    String prettyJson = encoder.convert(message);
    String coloredJson = prettyJson
        .replaceAllMapped(
        RegExp(r'"(\w+)":'), (match) => '\x1B[36m${match.group(0)}\x1B[0m')
        .replaceAllMapped(RegExp(r':\s"([^"]+)"'),
            (match) => ':\x1B[36m "${match.group(1)}"\x1B[0m')
        .replaceAllMapped(RegExp(r':\s(\d+)'),
            (match) => ':\x1B[36m ${match.group(1)}\x1B[0m');
    if (kDebugMode) {
      print('\x1B[36m${'-----------------$type-----------'}\x1B[0m');
      debugPrint(coloredJson);
    }
  }
}
