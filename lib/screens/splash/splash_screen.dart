import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final controller = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.6),
      body: Center(
          child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            width: MediaQuery.sizeOf(context).width / 2.5,
          ),
          const Text(
            'Attend Master',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ).marginOnly(top: 30),
        ],
      ).paddingOnly(top: MediaQuery.sizeOf(context).height / 2.6)),
    );
  }

  @override
  void dispose() {
    Get.delete<SplashController>();
    super.dispose();
  }
}
