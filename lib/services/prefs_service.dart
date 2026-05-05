import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static PrefsService? _instance;
  static SharedPreferences? _prefs;

  PrefsService._();

  static Future<PrefsService> getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _instance ??= PrefsService._();
  }

  // Keys
  static const _key24Hour = 'is24HourFormat';
  static const _keyDarkMode = 'isDarkMode';
  static const _keySelectedCities = 'selectedCityIds';

  bool get is24HourFormat => _prefs?.getBool(_key24Hour) ?? true;
  Future<void> set24HourFormat(bool value) async =>
      await _prefs?.setBool(_key24Hour, value);

  bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool value) async =>
      await _prefs?.setBool(_keyDarkMode, value);

  List<String> get selectedCityIds => _prefs?.getStringList(_keySelectedCities) ?? [];
  Future<void> setSelectedCityIds(List<String> ids) async =>
      await _prefs?.setStringList(_keySelectedCities, ids);

  Future<void> clear() async => await _prefs?.clear();
}
