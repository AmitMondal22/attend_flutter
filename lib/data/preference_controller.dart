import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_response_model.dart';

class PreferenceController extends GetxController {
  SharedPreferences? _preferences;

  static const _hasViewedOnboardingKey = 'HAS_VIEWED_ONBOARDING';

  //--- AFTER LOGIN ----------------------------

  static const _userId = "USER_ID";
  static const _accessToken = "ACCESS_TOKEN";
  static const _fullName = "FULL_NAME";
  static const _emailAddress = "EMAIL_ADDRESS";
  static const _loginStatus = "LOGIN_STATUS";
  static const _settingsDataKey = "SETTINGS_DATA";
  static const _userSettingsDataKey = "USER_SETTINGS_DATA";
  static const _userClockInKey = "USER_CLOCK_IN_STATUS";
  static const _mglSettingsDataKey = "MGL_SETTINGS_DATA";
  static const _userClockOutKey = "USER_CLOCK_OUT_STATUS";

//
  @override
  void onReady() async {
    _preferences = await SharedPreferences.getInstance();
    super.onReady();
  }

//----------------------------------------------------------------------------------------------

  bool get hasViewedOnboarding =>
      _preferences?.getBool(_hasViewedOnboardingKey) ?? false;

  Future<bool> setHasViewedOnboarding(bool hasViewed) {
    return _preferences!.setBool(_hasViewedOnboardingKey, hasViewed);
  }

  Future<void> completeOnboarding() async {
    await setHasViewedOnboarding(true);
  }

  //---------- WITH LOGIN PREF -------

  Future<bool> setAccessToken(String token) {
    return _preferences!.setString(_accessToken, token);
  }

  String get accessTokens => _preferences!.getString(_accessToken) ?? "";

  Future<bool> setFullName(String token) {
    return _preferences!.setString(_fullName, token);
  }

  String get fullName => _preferences!.getString(_fullName) ?? "";

  Future<bool> setEmailAddress(String token) {
    return _preferences!.setString(_emailAddress, token);
  }

  String get emailAddress => _preferences!.getString(_emailAddress) ?? "";

  String get userID => _preferences!.getString(_userId) ?? "";

  Future<bool> userId(String id) {
    return _preferences!.setString(_userId, id);
  }

  Future<bool> changeLoginState(bool state) {
    return _preferences!.setBool(_loginStatus, state);
  }

  bool get loginStatus {
    return _preferences!.getBool(_loginStatus) ?? false;
  }

  Future<void> clearLoginCred() async {
    await _preferences?.remove(_accessToken);
  }

  Future<void> clearAll() async {
    await _preferences?.clear();
  }

  Future<bool> saveSettingsData(SettingsData settingsData) async {
    String jsonString = settingsData.toJsonString();
    return await _preferences!.setString(_settingsDataKey, jsonString);
  }

  SettingsData? getSettingsData() {
    String? jsonString = _preferences?.getString(_settingsDataKey);
    if (jsonString != null) {
      return SettingsData.fromJsonString(jsonString);
    }
    return null;
  }

  Future<bool> removeSettingsData() async {
    return await _preferences!.remove(_settingsDataKey);
  }

  Future<bool> saveUserSettings(UserSettings userSettingsData) async {
    String jsonString = userSettingsData.toJsonString();
    return await _preferences!.setString(_userSettingsDataKey, jsonString);
  }

  UserSettings? getUserSettings() {
    String? jsonString = _preferences?.getString(_userSettingsDataKey);
    if (jsonString != null) {
      return UserSettings.fromJsonString(jsonString);
    }
    return null;
  }

  Future<bool> removeUserSettings() async {
    return await _preferences!.remove(_userSettingsDataKey);
  }

  bool get isClockedIn => _preferences?.getBool(_userClockInKey) ?? false;

  Future<bool> setIsClockedIn(bool isClockedIn) {
    return _preferences!.setBool(_userClockInKey, isClockedIn);
  }

  bool get isClockedOut => _preferences?.getBool(_userClockOutKey) ?? false;

  Future<bool> setIsClockedOut(bool isClockedOut) {
    return _preferences!.setBool(_userClockOutKey, isClockedOut);
  }

  Future<bool> saveMglSettings(List<MGListItem> dataList) async {
    final jsonString = MGListItem.encodeList(dataList);
    return await _preferences!.setString(_mglSettingsDataKey, jsonString);
  }

  List<MGListItem> getMglSettings() {
    final jsonString = _preferences?.getString(_mglSettingsDataKey);
    if (jsonString == null) return [];
    return MGListItem.decodeList(jsonString);
  }

  Future<bool> removeMglSettings() async {
    return await _preferences!.remove(_mglSettingsDataKey);
  }
}
