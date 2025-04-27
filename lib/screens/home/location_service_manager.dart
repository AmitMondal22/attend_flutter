import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/location_response_model.dart';
import '../../utils/colorful_log.dart';

class LocationServiceManager {
  static final LocationServiceManager _instance =
      LocationServiceManager._internal();

  factory LocationServiceManager() => _instance;

  LocationServiceManager._internal();

  final _locationStream = StreamController<Position>.broadcast();
  final _clockInStatusStream = StreamController<bool>.broadcast();
  final _clockOutStatusStream = StreamController<bool>.broadcast();

  Stream<Position> get locationUpdates => _locationStream.stream;
  Stream<bool> get clockInStatus => _clockInStatusStream.stream;
  Stream<bool> get clockOutStatus => _clockOutStatusStream.stream;

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
        autoStart: false,
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

    FlutterBackgroundService().on('location_update').listen((event) {
      if (event != null &&
          event['latitude'] != null &&
          event['longitude'] != null) {
        _locationStream.add(
          Position(
            latitude: event['latitude'],
            longitude: event['longitude'],
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          ),
        );
      }
    });

    FlutterBackgroundService().on('clock_in_status').listen((event) {
      if (event != null && event['status'] != null) {
        _clockInStatusStream.add(event['status']);
      }
    });

    FlutterBackgroundService().on('clock_out_status').listen((event) {
      if (event != null && event['status'] != null) {
        _clockOutStatusStream.add(event['status']);
      }
    });
  }

  Future<void> startService() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
      print("📍 Background location tracking started...");
    }
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (isRunning) {
      service.invoke("stopService");
      print("❌ Background service stopped.");
    }
  }

  Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  void dispose() {
    _locationStream.close();
    _clockInStatusStream.close();
    _clockOutStatusStream.close();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Location Tracking",
      content: "Tracking in the background...",
    );
  }

  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString("ACCESS_TOKEN");

  SettingsData? settingsData = getSettingsData(prefs);
  UserSettings? userSettings = getUserSettings(prefs);
  List<MGListItem>? mglSettings = getMglSettings(prefs);

  bool isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
  bool isClockedOut = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    await backgroundClockInCheck(prefs, accessToken);
    await backgroundClockOutCheck(prefs, accessToken);
    await backgroundGetUserSettings(prefs, accessToken);

    settingsData = getSettingsData(prefs);
    userSettings = getUserSettings(prefs);
    mglSettings = getMglSettings(prefs);

    bool newClockInStatus = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
    bool newClockOutStatus = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;

    if (isClockedIn != newClockInStatus) {
      isClockedIn = newClockInStatus;
      service.invoke('clock_in_status', {
        'status': isClockedIn,
      });
    }

    if (isClockedOut != newClockOutStatus) {
      isClockedOut = newClockOutStatus;
      service.invoke('clock_out_status', {
        'status': isClockedOut,
      });
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    service.invoke('location_update', {
      'latitude': position.latitude,
      'longitude': position.longitude,
    });

    if (userSettings != null) {
      if (userSettings!.settingsType == 'SGL') {
        if (userSettings?.autoInOut == '1') {
          if (isClockedIn == true) {
            if (isWithinRadius(
              userLat: position.latitude,
              userLon: position.longitude,
              settingsLat: settingsData!.latitude,
              settingsLong: settingsData!.longitude,
              settingRadius: settingsData!.redus,
            )) {
              await trackLocation(
                position.latitude,
                position.longitude,
                accessToken,
              );
            } else {
              await backgroundClockOut(
                position.latitude,
                position.longitude,
                settingsData!.settingsId,
                accessToken,
                prefs,
              );
              isClockedOut = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;
              service.invoke('clock_out_status', {
                'status': isClockedOut,
              });

              isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
              service.invoke('clock_in_status', {
                'status': isClockedIn,
              });
            }
          } else if (isClockedIn == false) {
            if (isWithinRadius(
              userLat: position.latitude,
              userLon: position.longitude,
              settingsLat: settingsData!.latitude,
              settingsLong: settingsData!.longitude,
              settingRadius: settingsData!.redus,
            )) {
              await backgroundClockIn(
                position.latitude,
                position.longitude,
                settingsData!.settingsId,
                accessToken,
                prefs,
              );
              isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
              service.invoke('clock_in_status', {
                'status': isClockedIn,
              });

              isClockedOut = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;
              service.invoke('clock_out_status', {
                'status': isClockedOut,
              });
              await trackLocation(
                position.latitude,
                position.longitude,
                accessToken,
              );
            }
          }
        } else if (userSettings?.autoInOut == '0') {
          if (isClockedIn == true) {
            await trackLocation(
              position.latitude,
              position.longitude,
              accessToken,
            );
          }
        }
      } else if (userSettings?.settingsType == 'MGL') {
        if (userSettings!.autoInOut == '1') {
          if (isClockedIn == true) {
            if (mglSettings!.isNotEmpty) {
              var withInRadiusStatus = false;
              for (var mgl in mglSettings!) {
                if (isWithinRadius(
                  userLat: position.latitude,
                  userLon: position.longitude,
                  settingsLat: mgl.latitude,
                  settingsLong: mgl.longitude,
                  settingRadius: mgl.redus,
                )) {
                  withInRadiusStatus = true;
                  await trackLocation(
                    position.latitude,
                    position.longitude,
                    accessToken,
                  );
                }
              }

              if (withInRadiusStatus == false) {
                await backgroundClockOut(
                  position.latitude,
                  position.longitude,
                  settingsData!.settingsId,
                  accessToken,
                  prefs,
                );

                isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
                service.invoke('clock_in_status', {
                  'status': isClockedIn,
                });

                isClockedOut = prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;
                service.invoke('clock_out_status', {
                  'status': isClockedOut,
                });

                withInRadiusStatus = false;
              }
            }
          } else if (isClockedIn == false) {
            if (mglSettings!.isNotEmpty) {
              for (var mgl in mglSettings!) {
                if (isWithinRadius(
                  userLat: position.latitude,
                  userLon: position.longitude,
                  settingsLat: mgl.latitude,
                  settingsLong: mgl.longitude,
                  settingRadius: mgl.redus,
                )) {
                  await backgroundClockIn(
                    position.latitude,
                    position.longitude,
                    settingsData!.settingsId,
                    accessToken,
                    prefs,
                  );

                  isClockedIn = prefs.getBool("USER_CLOCK_IN_STATUS") ?? false;
                  service.invoke('clock_in_status', {
                    'status': isClockedIn,
                  });

                  isClockedOut =
                      prefs.getBool("USER_CLOCK_OUT_STATUS") ?? false;
                  service.invoke('clock_out_status', {
                    'status': isClockedOut,
                  });

                  await trackLocation(
                    position.latitude,
                    position.longitude,
                    accessToken,
                  );
                }
              }
            }
          }
        } else if (userSettings?.autoInOut == '0') {
          if (isClockedIn == true) {
            var withInRadiusStatus = false;
            if (mglSettings!.isNotEmpty) {
              for (var mgl in mglSettings!) {
                if (isWithinRadius(
                  userLat: position.latitude,
                  userLon: position.longitude,
                  settingsLat: mgl.latitude,
                  settingsLong: mgl.longitude,
                  settingRadius: mgl.redus,
                )) {
                  withInRadiusStatus = true;
                }
              }
            }

            if (withInRadiusStatus == true) {
              await trackLocation(
                position.latitude,
                position.longitude,
                accessToken,
              );
            }
            withInRadiusStatus = false;
          }
        }
      } else if (userSettings?.settingsType == 'MIO') {
        if (isClockedIn == true) {
          await trackLocation(
              position.latitude, position.longitude, accessToken);
        }
      }
    }
  });
}

SettingsData? getSettingsData(SharedPreferences prefs) {
  String? jsonString = prefs.getString("SETTINGS_DATA");
  if (jsonString != null) {
    return SettingsData.fromJsonString(jsonString);
  }
  return null;
}

UserSettings? getUserSettings(SharedPreferences prefs) {
  String? jsonString = prefs.getString("USER_SETTINGS_DATA");
  if (jsonString != null) {
    return UserSettings.fromJsonString(jsonString);
  }
  return null;
}

List<MGListItem> getMglSettings(SharedPreferences prefs) {
  final jsonString = prefs.getString("MGL_SETTINGS_DATA");
  if (jsonString == null) return [];
  return MGListItem.decodeList(jsonString);
}

Future<void> backgroundClockInCheck(
  SharedPreferences prefs,
  String? accessToken,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/clock_in/check',
      options: _getAuthHeaders(accessToken),
    );

    if (response.data['status'] == "success") {
      final clockInData = ClockInResponse.fromJson(response.data).data;
      if (clockInData != null) {
        await prefs.setBool("USER_CLOCK_IN_STATUS", clockInData.clockInStatus);
      }
    }
  } catch (e) {
    print('Clock-in check error: $e');
  }
}

Future<void> backgroundClockOutCheck(
  SharedPreferences prefs,
  String? accessToken,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/clock_in/check_out',
      options: _getAuthHeaders(accessToken),
    );

    if (response.data['status'] == "success") {
      final clockOutData = ClockOutResponse.fromJson(response.data).data;
      if (clockOutData != null) {
        await prefs.setBool(
            "USER_CLOCK_OUT_STATUS", clockOutData.clockOutStatus);
      }
    }
  } catch (e) {
    print('Clock-out check error: $e');
  }
}

Future<void> backgroundGetUserSettings(
  SharedPreferences prefs,
  String? accessToken,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/settings/user_settings',
      options: _getAuthHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      final settings = UserSettingsResponse.fromJson(response.data).data;
      final String jsonString = jsonEncode(settings.toJson());
      await prefs.setString("USER_SETTINGS_DATA", jsonString);

      if (settings.settingsType == 'SGL') {
        await backgroundGetSettings(prefs, accessToken);
      } else if (settings.settingsType == 'MGL') {
        await backgroundGetMglSettings(prefs, accessToken);
      }
    }
  } catch (e) {
    print("Failed to get user settings: $e");
  }
}

Future<void> backgroundGetSettings(
  SharedPreferences prefs,
  String? accessToken,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/location/settings',
      options: _getAuthHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      final settingsData =
          LocationSettingResponse.fromJson(response.data).data?.settingsData;
      if (settingsData != null) {
        final String jsonString = jsonEncode(settingsData.toJson());
        await prefs.setString("SETTINGS_DATA", jsonString);
      }
    }
  } catch (e) {
    print("Failed to get settings: $e");
  }
}

Future<void> backgroundGetMglSettings(
  SharedPreferences prefs,
  String? accessToken,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/location/mgl_settings',
      options: _getAuthHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      final mglSettings =
          MGLSettingsResponse.fromJson(response.data).data.settingsData;
      if (mglSettings.isNotEmpty) {
        final String jsonString =
            jsonEncode(mglSettings.map((item) => item.toJson()).toList());
        await prefs.setString("MGL_SETTINGS_DATA", jsonString);
      }
    }
  } catch (e) {
    print("Failed to get MGL settings: $e");
  }
}

Future<void> backgroundClockIn(
  double latitude,
  double longitude,
  int locationSettingId,
  String? accessToken,
  SharedPreferences prefs,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/clock_in',
      options: _getAuthHeaders(accessToken),
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "location_setting": locationSettingId,
      },
    );

    if (response.statusCode == 200) {
      await prefs.setBool("USER_CLOCK_IN_STATUS", true);
      await prefs.setBool("USER_CLOCK_OUT_STATUS", false);
      print("✅ Clocked in successfully");
    }
  } catch (e) {
    print("❌ Clock in failed: $e");
  }
}

Future<void> backgroundClockOut(
  double latitude,
  double longitude,
  int locationSettingId,
  String? accessToken,
  SharedPreferences prefs,
) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      'http://attendance.iotblitz.com/api/clock_out',
      options: _getAuthHeaders(accessToken),
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "location_setting": locationSettingId,
      },
    );

    if (response.statusCode == 200) {
      await prefs.setBool("USER_CLOCK_IN_STATUS", false);
      await prefs.setBool("USER_CLOCK_OUT_STATUS", true);
      print("✅ Clocked out successfully");
    }
  } catch (e) {
    print("❌ Clock out failed: $e");
  }
}

Future<void> trackLocation(
  double latitude,
  double longitude,
  String? accessToken,
) async {
  final dio = Dio();
  try {
    await dio.post(
      'http://attendance.iotblitz.com/api/location/track',
      data: {
        "latitude": latitude,
        "longitude": longitude,
      },
      options: _getAuthHeaders(accessToken),
    );
    print("✅ Location sent: $latitude, $longitude");
  } catch (e) {
    print("❌ Error sending location: $e");
  }
}

Options _getAuthHeaders(String? token) => Options(
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

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
bool onIosBackground(ServiceInstance service) {
  print("✅ iOS background execution started!");
  return true;
}
