import 'package:attend_master/screens/home/home_screen.dart';
import 'package:attend_master/screens/home/home_screen_binding.dart';
import 'package:get/get.dart';

import '../screens/login/login_screen.dart';
import '../screens/login/login_screen_binding.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/splash/splash_screen_binding.dart';
import 'route_names.dart';

class AppRoutes {
  AppRoutes._();

  static AppRoutes instance = AppRoutes._();

  List<GetPage> routes() {
    return [
      GetPage(
        name: RouteNames.splash,
        page: () => const SplashScreen(),
        binding: SplashScreenBinding(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 500),
      ),
      GetPage(
        name: RouteNames.login,
        page: () => const LoginScreen(),
        binding: LoginScreenBinding(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: RouteNames.home,
        page: () => const HomeScreen(),
        binding: HomeScreenBinding(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ];
  }
}
