import 'dart:io';
class NetworkCheckerUtils {
  static Future<bool> hasNetwork() async {
    try {
      // final result = await InternetAddress.lookup(API.baseUrl);
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
