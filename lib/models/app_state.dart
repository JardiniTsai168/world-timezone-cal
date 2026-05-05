import 'package:flutter/foundation.dart';
import '../models/city.dart';
import '../services/prefs_service.dart';
import '../services/timezone_service.dart';

class AppState extends ChangeNotifier {
  final TimezoneService _tzService = TimezoneService();
  PrefsService? _prefs;

  List<City> _allCities = [];
  List<City> _selectedCities = [];
  int _currentTabIndex = 0;
  bool _is24HourFormat = true;
  bool _isDarkMode = false;

  bool _initialized = false;
  bool get initialized => _initialized;

  AppState() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    _prefs = await PrefsService.getInstance();
    _allCities = _tzService.allCities;

    _is24HourFormat = _prefs?.is24HourFormat ?? true;
    _isDarkMode = _prefs?.isDarkMode ?? false;

    final savedIds = _prefs?.selectedCityIds ?? [];
    if (savedIds.isNotEmpty) {
      _selectedCities = savedIds
          .map((id) => _allCities.firstWhere(
                (c) => c.id == id,
                orElse: () => City.getPredefinedCities().firstWhere((c) => c.id == id),
              ))
          .whereType<City>()
          .toList();
    }

    if (_selectedCities.isEmpty) {
      _selectedCities = [
        _allCities.firstWhere((c) => c.id == 'taipei'),
        _allCities.firstWhere((c) => c.id == 'tokyo'),
        _allCities.firstWhere((c) => c.id == 'new_york'),
      ];
    }

    _initialized = true;
    notifyListeners();
  }

  // Getters
  List<City> get allCities => List.unmodifiable(_allCities);
  List<City> get selectedCities => List.unmodifiable(_selectedCities);
  int get currentTabIndex => _currentTabIndex;
  bool get is24HourFormat => _is24HourFormat;
  bool get isDarkMode => _isDarkMode;

  City? get selectedCity => _selectedCities.isNotEmpty ? _selectedCities.first : null;

  // Persistence helper
  Future<void> _persistCities() async {
    await _prefs?.setSelectedCityIds(_selectedCities.map((c) => c.id).toList());
  }

  // Tab navigation
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // City management
  void addCity(City city) {
    if (!_selectedCities.any((c) => c.id == city.id)) {
      _selectedCities.add(city);
      _persistCities();
      notifyListeners();
    }
  }

  void removeCity(City city) {
    _selectedCities.removeWhere((c) => c.id == city.id);
    _persistCities();
    notifyListeners();
  }

  void reorderCities(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _selectedCities.length) return;
    if (newIndex < 0 || newIndex > _selectedCities.length) return;
    final item = _selectedCities.removeAt(oldIndex);
    _selectedCities.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    _persistCities();
    notifyListeners();
  }

  // Settings
  void toggleTimeFormat() {
    _is24HourFormat = !_is24HourFormat;
    _prefs?.set24HourFormat(_is24HourFormat);
    notifyListeners();
  }

  void set24HourFormat(bool value) {
    if (_is24HourFormat != value) {
      _is24HourFormat = value;
      _prefs?.set24HourFormat(value);
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _prefs?.setDarkMode(value);
      notifyListeners();
    }
  }
}
