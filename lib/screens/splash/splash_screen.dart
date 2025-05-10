import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<SplashController>();
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();

    Get.delete<SplashController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.sizeOf(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0), // Top Blue
              Colors.white,
              Color(0xFF1565C0), // Bottom Blue
            ],
            stops: [0.0, 0.5, 1.0], // White is centered
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: mediaSize.height / 7),
              Image.asset(
                'assets/logo.png',
                height: mediaSize.height / 4,
                fit: BoxFit.cover,
              ),
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  final double animationValue = _shimmerController.value;
                  final double position = -1.5 + (3.0 * animationValue);

                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.white,
                          Colors.white,
                          Colors.grey.shade400,
                        ],
                        stops: const [
                          0.25,
                          0.45,
                          0.55,
                          0.75
                        ], // more width to white
                        begin: Alignment(position - 0.5, 0.0),
                        end: Alignment(position + 0.5, 0.0),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: child,
                  );
                },
                child: const Text(
                  'HR EXON',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: mediaSize.height / 6),
            ],
          ),
        ),
      ),
    );
  }
}
