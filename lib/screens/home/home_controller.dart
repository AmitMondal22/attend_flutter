import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../data/preference_controller.dart';
import '../../data/location_response_model.dart';
import '../../navigation/route_names.dart';
import '../../utils/colorful_log.dart';
import 'location_service_manager.dart';

bool isWithinRadius({
  required double userLat,
  required double userLon,
  required double settingsLat,
  required double settingsLong,
  required int settingRadius,
}) {
  const double earthRadius = 6371000;
  double toRadians(double degrees) => degrees * (pi / 180);
  double dLat = toRadians(userLat - settingsLat);
  double dLon = toRadians(userLon - settingsLong);
  double lat1 = toRadians(settingsLat);
  double lat2 = toRadians(userLat);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;
  return distance <= settingRadius;
}

Options _getAuthHeaders(String? token) => Options(
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

class HomeController extends GetxController {
  final Dio _dio = Dio();
  final _prefs = Get.find<PreferenceController>();
  final _serviceManager = LocationServiceManager();
  RxString currentTime = ''.obs;
  Rx<SettingsData?> settingsData = Rx<SettingsData?>(null);
  Rx<ClockInDataObj?> clockInDataObj = Rx<ClockInDataObj?>(null);
  Rx<ClockOutDataObj?> clockOutDataObj = Rx<ClockOutDataObj?>(null);
  RxBool clockInClockOutDataLoading = true.obs;
  Rx<UserSettings?> userSettings = Rx<UserSettings?>(null);
  RxList<MGListItem> mglSettingsList = <MGListItem>[].obs;
  RxBool autoInOutStatus = false.obs;

  // Stream subscriptions
  late StreamSubscription<bool> _clockInStatusSubscription;
  late StreamSubscription<bool> _clockOutStatusSubscription;

  bool isWithinRadius(
    double userLat,
    double userLon,
  ) {
    if (settingsData.value == null) return false;

    const double earthRadius = 6371000;
    double toRadians(double degrees) => degrees * (pi / 180);
    double dLat = toRadians(userLat - settingsData.value!.latitude);
    double dLon = toRadians(userLon - settingsData.value!.longitude);
    double lat1 = toRadians(settingsData.value!.latitude);
    double lat2 = toRadians(userLat);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance <= settingsData.value!.redus;
  }

  bool isWithinRadiusMulti({
    required double userLat,
    required double userLon,
    required double settingsLat,
    required double settingsLong,
    required int settingRadius,
  }) {
    const double earthRadius = 6371000;
    double toRadians(double degrees) => degrees * (pi / 180);
    double dLat = toRadians(userLat - settingsLat);
    double dLon = toRadians(userLon - settingsLong);
    double lat1 = toRadians(settingsLat);
    double lat2 = toRadians(userLat);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance <= settingRadius;
  }

  @override
  void onInit() async {
    super.onInit();
    await clockInCheck();
    await clockOutCheck();
    await getUserSettings();

    // Listen to streams from service manager
    _clockInStatusSubscription = _serviceManager.clockInStatus.listen((status) {
      _prefs.setIsClockedIn(status);
      clockInCheck();
    });

    _clockOutStatusSubscription =
        _serviceManager.clockOutStatus.listen((status) {
      _prefs.setIsClockedOut(status);
      clockOutCheck();
    });

    if (_prefs.isClockedIn) {
      // _serviceManager.startService();
    }
  }

  @override
  void onClose() {
    _clockInStatusSubscription.cancel();
    _clockOutStatusSubscription.cancel();
    super.onClose();
  }

  Future<void> clockIn() async {
    try {
      if (userSettings.value?.settingsType == 'SGL') {
        if (!await checkIsWithinCompanyRadius()) return;

        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation));

        final response = await _dio.post(
          'http://attendance.iotblitz.com/api/clock_in',
          options: _getAuthHeaders(_prefs.accessTokens),
          data: {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "location_setting": settingsData.value?.settingsId ?? 0,
          },
        );

        if (response.statusCode == 200) {
          _showSnackbar(
              response.data['data']['message']?.toString() ?? "", true);
          _prefs.setIsClockedIn(true);
          _prefs.setIsClockedOut(false);
          // _serviceManager.startService();

          await Future.wait([clockInCheck(), clockOutCheck()]);
        }
      } else if (userSettings.value?.settingsType == 'MGL') {
        ///

        if (!await checkIsWithinCompanyRadiusMGL()) return;

        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation));

        final response = await _dio.post(
          'http://attendance.iotblitz.com/api/clock_in',
          options: _getAuthHeaders(_prefs.accessTokens),
          data: {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "location_setting": settingsData.value?.settingsId ?? 0,
          },
        );

        if (response.statusCode == 200) {
          _showSnackbar(
              response.data['data']['message']?.toString() ?? "", true);
          _prefs.setIsClockedIn(true);
          _prefs.setIsClockedOut(false);
          // _serviceManager.startService();

          await Future.wait([clockInCheck(), clockOutCheck()]);
        }
      } else {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation));

        final response = await _dio.post(
          'http://attendance.iotblitz.com/api/clock_in',
          options: _getAuthHeaders(_prefs.accessTokens),
          data: {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "location_setting": settingsData.value?.settingsId ?? 0,
          },
        );

        if (response.statusCode == 200) {
          _showSnackbar(
              response.data['data']['message']?.toString() ?? "", true);
          _prefs.setIsClockedIn(true);
          _prefs.setIsClockedOut(false);
          // _serviceManager.startService();

          await Future.wait([clockInCheck(), clockOutCheck()]);
        }
      }
    } catch (e) {
      _handleError("Clock in failed", e);
    }
  }

  Future<void> clockOut() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation));

      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/clock_out',
        options: _getAuthHeaders(_prefs.accessTokens),
        data: {
          "latitude": position.latitude,
          "longitude": position.longitude,
          "location_setting": settingsData.value?.settingsId ?? 0,
        },
      );

      if (response.statusCode == 200) {
        _showSnackbar(response.data['data']['message']?.toString() ?? "", true);
        _prefs.setIsClockedIn(false);
        _prefs.setIsClockedOut(true);
        // _serviceManager.startService();

        await Future.wait([clockOutCheck(), clockInCheck()]);
      }
    } catch (e) {
      _handleError("Clock out failed", e);
    }
  }

  Future<bool> checkIsWithinCompanyRadius() async {
    if (settingsData.value == null) {
      _showSnackbar("Company location settings not available", false);
      return false;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation));

      bool isWithin = isWithinRadius(position.latitude, position.longitude);
      if (!isWithin) {
        _showSnackbar("You are not within the company radius!", false);
      }
      return isWithin;
    } catch (e) {
      _handleError("Location check failed", e);
      return false;
    }
  }

  Future<bool> checkIsWithinCompanyRadiusMGL() async {
    if (mglSettingsList.isNotEmpty) {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation));

      var withInRadiusStatus = false;

      for (var mgl in mglSettingsList) {
        if (isWithinRadiusMulti(
          userLat: position.latitude,
          userLon: position.longitude,
          settingsLat: mgl.latitude,
          settingsLong: mgl.longitude,
          settingRadius: mgl.redus,
        )) {
          withInRadiusStatus = true;
        }
      }

      if (withInRadiusStatus == true) {
        return true;
      } else {
        _showSnackbar("You are not within the company radius!", false);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _getSettings() async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/location/settings',
        options: _getAuthHeaders(_prefs.accessTokens),
      );
      if (response.statusCode == 200) {
        settingsData.value =
            LocationSettingResponse.fromJson(response.data).data?.settingsData;
        if (settingsData.value != null) {
          _prefs.saveSettingsData(settingsData.value!);
          _serviceManager.startService();
        }
      }
    } catch (e) {
      _handleError("FFailed to get settings", e);
    }
  }

  Future<void> clockInCheck() async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/clock_in/check',
        options: _getAuthHeaders(_prefs.accessTokens),
      );

      if (response.data['status'] == "success") {
        clockInDataObj.value = ClockInResponse.fromJson(response.data).data;
        if (clockInDataObj.value != null) {
          if (clockInDataObj.value!.clockInStatus) {
            _prefs.setIsClockedIn(true);
          } else {
            _prefs.setIsClockedIn(false);
          }
        }
      }
    } catch (e) {
      ColorLog.yellow('Clock-in check $e');
    }
  }

  Future<void> clockOutCheck() async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/clock_in/check_out',
        options: _getAuthHeaders(_prefs.accessTokens),
      );

      if (response.data['status'] == "success") {
        clockOutDataObj.value = ClockOutResponse.fromJson(response.data).data;
      }
    } catch (e) {
      ColorLog.yellow('Clock-out check $e');
    }
  }

  void logout() async {
    _prefs.clearLoginCred();
    _prefs.changeLoginState(false);
    await _serviceManager.stopService();
    _prefs.clearAll();
    _showSnackbar("Logout successful!", true);
    Get.offAllNamed(RouteNames.login);
  }

  void _showSnackbar(
    String message,
    bool isSuccess,
  ) {
    if (Get.isSnackbarOpen) Get.back();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _handleError(String message, dynamic error) {
    String errorMessage = message;
    if (error is DioException) {
      errorMessage += ": ${error.response?.statusCode ?? 'No response'}";
      ColorLog.yellow("Dio Error: ${error.response?.data}");
    } else {
      errorMessage += ": ${error.toString()}";
    }
    _showSnackbar(errorMessage, false);
  }

  Future<void> getUserSettings() async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/settings/user_settings',
        options: _getAuthHeaders(_prefs.accessTokens),
      );
      if (response.statusCode == 200) {
        userSettings.value = UserSettingsResponse.fromJson(response.data).data;
        if (userSettings.value != null) {
          _prefs.saveUserSettings(userSettings.value!);
        }

        if (userSettings.value != null) {
          autoInOutStatus.value = userSettings.value?.autoInOut == '1';
          if (userSettings.value!.settingsType == 'SGL') {
            _getSettings();
          } else if (userSettings.value!.settingsType == 'MGL') {
            _getMglSettings();
          } else if (userSettings.value!.settingsType == 'MIO') {
            _getSettings();
          }
        }
      }
    } catch (e) {
      ColorLog.yellow("Failed to get settings $e");
    }
  }

  Future<void> _getMglSettings() async {
    try {
      final response = await _dio.post(
        'http://attendance.iotblitz.com/api/location/mgl_settings',
        options: _getAuthHeaders(_prefs.accessTokens),
      );

      if (response.statusCode == 200) {
        mglSettingsList.value =
            MGLSettingsResponse.fromJson(response.data).data.settingsData;
        if (mglSettingsList.isNotEmpty) {
          _prefs.saveMglSettings(mglSettingsList);
          _getSettings();
        }
      }
    } catch (e) {
      _handleError("Failed to get settings", e);
    }
  }
}
