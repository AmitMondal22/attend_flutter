import 'package:get/get.dart';

import '../../../../data/preference_controller.dart';
import 'home_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => PreferenceController());
  }
}
