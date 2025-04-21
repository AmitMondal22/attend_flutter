import 'package:get/get.dart';
import '../data/preference_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PreferenceController());
  }
}
