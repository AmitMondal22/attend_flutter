import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/preference_controller.dart';
import '../../data/location_response_model.dart';
import '../../navigation/route_names.dart';
import '../../utils/colorful_log.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'location_tracking',
    'Location Tracking',
    description: 'Shows notification when location is being tracked',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'location_tracking',
      initialNotificationTitle: 'Location Tracking',
      initialNotificationContent: 'Tracking in the background...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => PreferenceController());

  final homeController = Get.find<HomeController>();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Location Tracking",
      content: "Tracking in the background...",
    );
  }

  ////// shered prefs =====================

  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString("ACCESS_TOKEN");

  SettingsData? getSettingsData() {
    String? jsonString = prefs.getString("SETTINGS_DATA");
    if (jsonString != null) {
      return SettingsData.fromJsonString(jsonString);
    }
    return null;
  }

  UserSettings? getUserSettings() {
    String? jsonString = prefs.getString("USER_SETTINGS_DATA");
    if (jsonString != null) {
      return UserSettings.fromJsonString(jsonString);
    }
    return null;
  }

  List<MGListItem> getMglSettings() {
    final jsonString = prefs.getString("MGL_SETTINGS_DATA");
    if (jsonString == null) return [];
    return MGListItem.decodeList(jsonString);
  }

  SettingsData? settingsData = getSettingsData();
  UserSettings? userSettings = getUserSettings();
  List<MGListItem>? mglSettings = getMglSettings();

  bool isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
  bool isClockedOut = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;

  Future<bool> setIsClockedOut(bool isClockedOut) {
    return prefs.setBool("USER_CLOCK_OUT_STATUS", isClockedOut);
  }

  Future<bool> setIsClockedIn(bool isClockedIn) {
    return prefs.setBool("USER_CLOCK_IN_STATUS", isClockedIn);
  }

  ////// shered prefs =====================

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    if (userSettings != null) {
      if (userSettings!.settingsType == 'SGL') {
        if (userSettings.autoInOut == '1') {
          if (isClockedIn == true) {
            if (isWithinRadius(
              userLat: position.latitude,
              userLon: position.longitude,
              settingsLat: settingsData!.latitude,
              settingsLong: settingsData!.latitude,
              settingRadius: settingsData.redus,
            )) {
              Dio dio = Dio();
              try {
                await dio.post(
                  'http://attendance.iotblitz.com/api/location/track',
                  data: {
                    "latitude": position.latitude,
                    "longitude": position.longitude,
                  },
                  options: _getAuthHeaders(accessToken),
                );
                print(
                    "✅ Location sent: ${position.latitude}, ${position.longitude}");
              } catch (e) {
                print(accessToken);
                print("❌ Error sending location: $e");
              }
            } else {
              await homeController.clockOut();
              setIsClockedOut(true);
              setIsClockedIn(false);
            }
          } else if (isClockedIn == false) {
            if (isWithinRadius(
              userLat: position.latitude,
              userLon: position.longitude,
              settingsLat: settingsData!.latitude,
              settingsLong: settingsData!.longitude,
              settingRadius: settingsData.redus,
            )) {
              await homeController.clockIn();
              setIsClockedOut(false);
              setIsClockedIn(true);
              Dio dio = Dio();
              try {
                await dio.post(
                  'http://attendance.iotblitz.com/api/location/track',
                  data: {
                    "latitude": position.latitude,
                    "longitude": position.longitude,
                  },
                  options: _getAuthHeaders(accessToken),
                );
                print(
                    "✅ Location sent: ${position.latitude}, ${position.longitude}");
              } catch (e) {
                print("❌ Error sending location: $e");
              }
            }
          }
        } else if (userSettings.autoInOut == '0') {
          Dio dio = Dio();
          try {
            await dio.post(
              'http://attendance.iotblitz.com/api/location/track',
              data: {
                "latitude": position.latitude,
                "longitude": position.longitude,
              },
              options: _getAuthHeaders(accessToken),
            );
            print(
                "✅ Location sent: ${position.latitude}, ${position.longitude}");
          } catch (e) {
            print("❌ Error sending location: $e");
          }
        }
      } else if (userSettings.settingsType == 'MGL') {
        if (userSettings.autoInOut == '1') {
          if (isClockedIn == true) {
            if (mglSettings.isNotEmpty) {
              var withInRadiusStatus = false;
              for (var mgl in mglSettings) {
                if (isWithinRadius(
                  userLat: position.latitude,
                  userLon: position.longitude,
                  settingsLat: mgl.latitude,
                  settingsLong: mgl.longitude,
                  settingRadius: mgl.redus,
                )) {
                  withInRadiusStatus = true;
                  Dio dio = Dio();
                  try {
                    await dio.post(
                      'http://attendance.iotblitz.com/api/location/track',
                      data: {
                        "latitude": position.latitude,
                        "longitude": position.longitude,
                      },
                      options: _getAuthHeaders(accessToken),
                    );
                    print(
                        "✅ Location sent: ${position.latitude}, ${position.longitude}");
                  } catch (e) {
                    print(accessToken);
                    print("❌ Error sending location: $e");
                  }
                } else {
                  await homeController.clockIn();

                  setIsClockedOut(false);
                  setIsClockedIn(true);
                }
              }

              if (withInRadiusStatus == false) {
                await homeController.clockOut();
                setIsClockedOut(true);
                withInRadiusStatus = true;
              }
            }
          } else if (isClockedIn == false) {
            if (mglSettings.isNotEmpty) {
              for (var mgl in mglSettings) {
                if (isWithinRadius(
                  userLat: position.latitude,
                  userLon: position.longitude,
                  settingsLat: mgl.latitude,
                  settingsLong: mgl.longitude,
                  settingRadius: mgl.redus,
                )) {
                  await homeController.clockIn();

                  setIsClockedOut(false);
                  setIsClockedIn(true);

                  Dio dio = Dio();
                  try {
                    await dio.post(
                      'http://attendance.iotblitz.com/api/location/track',
                      data: {
                        "latitude": position.latitude,
                        "longitude": position.longitude,
                      },
                      options: _getAuthHeaders(accessToken),
                    );
                    print(
                        "✅ Location sent: ${position.latitude}, ${position.longitude}");
                  } catch (e) {
                    print("❌ Error sending location: $e");
                  }
                }
              }
            }
          }
        } else if (userSettings.autoInOut == '0') {
          Dio dio = Dio();
          try {
            await dio.post(
              'http://attendance.iotblitz.com/api/location/track',
              data: {
                "latitude": position.latitude,
                "longitude": position.longitude,
              },
              options: _getAuthHeaders(accessToken),
            );
            print(
                "✅ Location sent: ${position.latitude}, ${position.longitude}");
          } catch (e) {
            print("❌ Error sending location: $e");
          }
        }
      }
    }
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  print("✅ iOS background execution started!");
  return true;
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
  RxString currentTime = ''.obs;
  Rx<SettingsData?> settingsData = Rx<SettingsData?>(null);
  Rx<ClockInDataObj?> clockInDataObj = Rx<ClockInDataObj?>(null);
  Rx<ClockOutDataObj?> clockOutDataObj = Rx<ClockOutDataObj?>(null);
  RxBool clockInClockOutDataLoading = true.obs;
  Rx<UserSettings?> userSettings = Rx<UserSettings?>(null);
  RxList<MGListItem> mglSettingsList = <MGListItem>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    getUserSettings();
    clockInCheck();
    clockOutCheck();
  }

  @override
  void onReady() {
    initializeService();
    super.onReady();
  }

  void startBackgroundService() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      service.startService();
      print("📍 Background location tracking started...");
    }
  }

  void stopBackgroundService() {
    FlutterBackgroundService().invoke("stopService");
    print("❌ Background service stopped.");
  }

  Future<void> clockIn() async {
    try {
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
        _showSnackbar(response.data['data']['message']?.toString() ?? "", true);
        _prefs.setIsClockedIn(true);
        _prefs.setIsClockedOut(false);
        startBackgroundService();

        await Future.wait([clockInCheck(), clockOutCheck()]);
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
        stopBackgroundService();

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

  void logout() {
    _prefs.clearLoginCred();
    _prefs.changeLoginState(false);
    stopBackgroundService();
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
        print(response.data);
        if (userSettings.value != null) {
          _prefs.saveUserSettings(userSettings.value!);
        }

        if (userSettings.value != null) {
          if (userSettings.value!.settingsType == 'SGL') {
            _getSettings();
          } else if (userSettings.value!.settingsType == 'MGL') {
            _getMglSettings();
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
        }
      }
    } catch (e) {
      _handleError("Failed to get settings", e);
    }
  }
}
