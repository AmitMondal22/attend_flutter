import 'package:get/get.dart';

import '../../../../data/preference_controller.dart';
import 'login_controller.dart';

class LoginScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => PreferenceController());
  }
}
