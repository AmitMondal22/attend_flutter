import 'dart:convert';

class LocationSettingResponse {
  LocationSettingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final LocationSettingData? data;

  factory LocationSettingResponse.fromJson(Map<String, dynamic> json) {
    return LocationSettingResponse(
      status: json["status"] ?? "",
      message: json["message"] ?? "",
      data: json["data"] == null
          ? null
          : LocationSettingData.fromJson(json["data"]),
    );
  }
}

class LocationSettingData {
  LocationSettingData({
    required this.settingsData,
  });

  final SettingsData? settingsData;

  factory LocationSettingData.fromJson(Map<String, dynamic> json) {
    return LocationSettingData(
      settingsData: json["settings_data"] == null
          ? null
          : SettingsData.fromJson(json["settings_data"]),
    );
  }
}

class SettingsData {
  SettingsData({
    required this.settingsId,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.redus,
  });

  final int settingsId;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final int redus;

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      settingsId: json["settings_id"] ?? 0,
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
      locationAddress: json["location_address"] ?? "",
      redus: json["redus"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings_id': settingsId,
      'latitude': latitude,
      'longitude': longitude,
      'location_address': locationAddress,
      'redus': redus,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static SettingsData fromJsonString(String jsonString) {
    final jsonData = jsonDecode(jsonString);
    return SettingsData.fromJson(jsonData);
  }
}

//////
class ClockInResponse {
  ClockInResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final ClockInDataObj? data;

  factory ClockInResponse.fromJson(Map<String, dynamic> json) {
    return ClockInResponse(
      status: json["status"] ?? "",
      message: json["message"] ?? "",
      data: json["data"] == null ? null : ClockInDataObj.fromJson(json["data"]),
    );
  }
}

class ClockInDataObj {
  ClockInDataObj({
    required this.clockInStatus,
    required this.clockInData,
  });

  final bool clockInStatus;
  final ClockInData? clockInData;

  factory ClockInDataObj.fromJson(Map<String, dynamic> json) {
    return ClockInDataObj(
      clockInStatus: json["clock_in_status"] ?? false,
      clockInData: json["clock_in_data"] == null
          ? null
          : ClockInData.fromJson(json["clock_in_data"]),
    );
  }
}

class ClockInData {
  ClockInData({
    required this.clockInId,
    required this.inTime,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.inOutFlag,
    required this.userId,
    required this.createdAt,
  });

  final int clockInId;
  final String inTime;
  final DateTime? date;
  final double latitude;
  final double longitude;
  final String inOutFlag;
  final int userId;
  final String createdAt;

  factory ClockInData.fromJson(Map<String, dynamic> json) {
    return ClockInData(
      clockInId: json["clock_in_id"] ?? 0,
      inTime: json["in_time"] ?? "",
      date: DateTime.tryParse(json["date"] ?? ""),
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
      inOutFlag: json["in_out_flag"] ?? "",
      userId: json["user_id"] ?? 0,
      createdAt: json["created_at"] ?? "",
    );
  }
}

class ClockOutResponse {
  ClockOutResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final ClockOutDataObj? data;

  factory ClockOutResponse.fromJson(Map<String, dynamic> json) {
    return ClockOutResponse(
      status: json["status"] ?? "",
      message: json["message"] ?? "",
      data:
          json["data"] == null ? null : ClockOutDataObj.fromJson(json["data"]),
    );
  }
}

class ClockOutDataObj {
  ClockOutDataObj({
    required this.clockOutStatus,
    required this.clockOutData,
  });

  final bool clockOutStatus;
  final ClockOutData? clockOutData;

  factory ClockOutDataObj.fromJson(Map<String, dynamic> json) {
    return ClockOutDataObj(
      clockOutStatus: json["clock_out_status"] ?? false,
      clockOutData: json["clock_out_data"] == null
          ? null
          : ClockOutData.fromJson(json["clock_out_data"]),
    );
  }
}

class ClockOutData {
  ClockOutData({
    required this.clockOutId,
    required this.outTime,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.inOutFlag,
    required this.userId,
    required this.createdAt,
  });

  final int clockOutId;
  final String outTime;
  final DateTime? date;
  final double latitude;
  final double longitude;
  final String inOutFlag;
  final int userId;
  final DateTime? createdAt;

  factory ClockOutData.fromJson(Map<String, dynamic> json) {
    return ClockOutData(
      clockOutId: json["clock_out_id"] ?? 0,
      outTime: json["out_time"] ?? "",
      date: DateTime.tryParse(json["date"] ?? ""),
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
      inOutFlag: json["in_out_flag"] ?? "",
      userId: json["user_id"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
    );
  }
}

class UserSettingsResponse {
  final String status;
  final String message;
  final UserSettings data;

  UserSettingsResponse(
      {required this.status, required this.message, required this.data});

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UserSettingsResponse(
      status: json['status'],
      message: json['message'],
      data: UserSettings.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

class UserSettings {
  final int settingsId;
  final int userId;
  final int employeeId;
  final String settingsType;
  final String autoInOut;
  final int locationId;
  final String faceRecognition;
  final String shiftStatus;
  final int shiftId;

  UserSettings({
    required this.settingsId,
    required this.userId,
    required this.employeeId,
    required this.settingsType,
    required this.autoInOut,
    required this.locationId,
    required this.faceRecognition,
    required this.shiftStatus,
    required this.shiftId,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      settingsId: json['settings_id'],
      userId: json['user_id'],
      employeeId: json['employee_id'],
      settingsType: json['settings_type'],
      autoInOut: json['auto_in_out'],
      locationId: json['location_id'],
      faceRecognition: json['face_recognition'],
      shiftStatus: json['shift_status'],
      shiftId: json['shift_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings_id': settingsId,
      'user_id': userId,
      'employee_id': employeeId,
      'settings_type': settingsType,
      'auto_in_out': autoInOut,
      'location_id': locationId,
      'face_recognition': faceRecognition,
      'shift_status': shiftStatus,
      'shift_id': shiftId,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static UserSettings fromJsonString(String jsonString) {
    final jsonData = jsonDecode(jsonString);
    return UserSettings.fromJson(jsonData);
  }
}

//

class MGLSettingsResponse {
  final String status;
  final String message;
  final MGLSettingsData data;

  MGLSettingsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MGLSettingsResponse.fromJson(Map<String, dynamic> json) {
    return MGLSettingsResponse(
      status: json['status'],
      message: json['message'],
      data: MGLSettingsData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.toJson(),
      };
}

class MGLSettingsData {
  final List<MGListItem> settingsData;

  MGLSettingsData({required this.settingsData});

  factory MGLSettingsData.fromJson(Map<String, dynamic> json) {
    return MGLSettingsData(
      settingsData: (json['settings_data'] as List)
          .map((e) => MGListItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'settings_data': settingsData.map((e) => e.toJson()).toList(),
      };
}

class MGListItem {
  final int settingsId;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final int redus;

  MGListItem({
    required this.settingsId,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.redus,
  });

  factory MGListItem.fromJson(Map<String, dynamic> json) {
    return MGListItem(
      settingsId: json['settings_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationAddress: json['location_address'],
      redus: json['redus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'settings_id': settingsId,
        'latitude': latitude,
        'longitude': longitude,
        'location_address': locationAddress,
        'redus': redus,
      };

  static String encodeList(List<MGListItem> settingsList) =>
      jsonEncode(settingsList.map((e) => e.toJson()).toList());

  static List<MGListItem> decodeList(String jsonString) =>
      (jsonDecode(jsonString) as List)
          .map((e) => MGListItem.fromJson(e))
          .toList();
}
