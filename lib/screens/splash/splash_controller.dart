import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/preference_controller.dart';
import '../../navigation/route_names.dart';

class SplashController extends GetxController {
  final selectedIndex = 0.obs;
  final _prefs = Get.find<PreferenceController>();

  @override
  void onReady() {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (_prefs.loginStatus) {
          Get.offAllNamed(RouteNames.home);
        } else {
          Get.offAllNamed(RouteNames.login);
        }
      },
    );
    super.onReady();
  }
}
