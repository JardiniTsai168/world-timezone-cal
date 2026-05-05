import 'package:flutter/foundation.dart';
import '../models/city.dart';
import '../services/timezone_service.dart';

class AppState extends ChangeNotifier {
  final TimezoneService _tzService = TimezoneService();

  List<City> _allCities = [];
  List<City> _selectedCities = [];
  int _currentTabIndex = 0;
  bool _is24HourFormat = true;
  bool _isDarkMode = false;

  AppState() {
    _init();
  }

  void _init() {
    _allCities = _tzService.allCities;
    // Default selected cities
    _selectedCities = [
      _allCities.firstWhere((c) => c.id == 'taipei', orElse: () => _allCities.first),
      _allCities.firstWhere((c) => c.id == 'tokyo', orElse: () => _allCities.first),
      _allCities.firstWhere((c) => c.id == 'new_york', orElse: () => _allCities.first),
    ];
    notifyListeners();
  }

  // Getters
  List<City> get allCities => List.unmodifiable(_allCities);
  List<City> get selectedCities => List.unmodifiable(_selectedCities);
  int get currentTabIndex => _currentTabIndex;
  bool get is24HourFormat => _is24HourFormat;
  bool get isDarkMode => _isDarkMode;

  City? get selectedCity => _selectedCities.isNotEmpty ? _selectedCities.first : null;

  // Tab navigation
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // City management
  void addCity(City city) {
    if (!_selectedCities.any((c) => c.id == city.id)) {
      _selectedCities.add(city);
      notifyListeners();
    }
  }

  void removeCity(City city) {
    _selectedCities.removeWhere((c) => c.id == city.id);
    notifyListeners();
  }

  void reorderCities(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _selectedCities.length) return;
    if (newIndex < 0 || newIndex > _selectedCities.length) return;
    final item = _selectedCities.removeAt(oldIndex);
    _selectedCities.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    notifyListeners();
  }

  // Settings
  void toggleTimeFormat() {
    _is24HourFormat = !_is24HourFormat;
    notifyListeners();
  }

  void set24HourFormat(bool value) {
    if (_is24HourFormat != value) {
      _is24HourFormat = value;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }
}
