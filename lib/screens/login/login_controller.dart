import 'package:attend_master/utils/colorful_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/preference_controller.dart';
import '../../navigation/route_names.dart';

class LoginController extends GetxController {
  final _prefs = Get.find<PreferenceController>();

  final Dio _dio = Dio();

  @override
  void onReady() async {
    await Permission.notification.request();
    super.onReady();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/auth/login',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        ColorLog.devLog(response.data!);

        _prefs.setAccessToken(response.data['data']['token']);
        _prefs.setFullName(response.data['data']['user_data']['full_name']);
        _prefs.setEmailAddress(response.data['data']['user_data']['email']);
        _prefs.userId(response.data['data']['user_data']['user_id'].toString());
        _prefs.changeLoginState(true);

        Get.toNamed(RouteNames.home);

        Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Login failed: ${response.statusMessage}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      if (e is DioException) {
        ColorLog.yellow(
            "Dio Error: ${e.response?.statusCode} - ${e.response?.data}");

        Fluttertoast.showToast(
          msg: "Login failed: ${e.response?.statusMessage ?? e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        ColorLog.yellow("Unexpected Error: $e");

        Fluttertoast.showToast(
          msg: "Unexpected error occurred: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }
}
