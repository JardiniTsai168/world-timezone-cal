import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/city.dart';

class TimezoneService {
  static bool _initialized = false;

  TimezoneService() {
    _initialize();
  }

  static void _initialize() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  static void forceInitialize() {
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  List<City> get allCities => City.getPredefinedCities();

  List<City> searchCities(String query) {
    if (query.trim().isEmpty) return allCities;
    final lower = query.toLowerCase().trim();
    return allCities.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          c.countryCode.toLowerCase().contains(lower);
    }).toList();
  }

  City? findById(String id) {
    try {
      return allCities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Convert a [time] from [sourceCity] to [targetCity].
  /// Handles DST transitions correctly.
  DateTime convertTime({
    required DateTime time,
    required City sourceCity,
    required City targetCity,
  }) {
    final sourceLocation = sourceCity.location;
    final sourceTZ = tz.TZDateTime.from(time, sourceLocation);
    return tz.TZDateTime.from(sourceTZ, targetCity.location);
  }

  /// Convert a [time] using timezone name strings directly.
  DateTime convertTimeByZone({
    required DateTime time,
    required String fromZone,
    required String toZone,
  }) {
    final fromLocation = tz.getLocation(fromZone);
    final toLocation = tz.getLocation(toZone);
    final sourceTZ = tz.TZDateTime.from(time, fromLocation);
    return tz.TZDateTime.from(sourceTZ, toLocation);
  }

  /// Get current time in a given timezone.
  DateTime getCurrentTime(City city) {
    return tz.TZDateTime.now(city.location);
  }

  DateTime getCurrentTimeByZone(String timeZoneName) {
    final location = tz.getLocation(timeZoneName);
    return tz.TZDateTime.now(location);
  }

  /// Get time difference between two cities.
  Duration getTimeDifference(City city1, City city2) {
    return city1.getOffsetFrom(city2);
  }

  /// Get human-readable time difference like "+8 hours" or "-5 hours".
  String getTimeDifferenceText(City fromCity, City toCity) {
    final diff = getTimeDifference(fromCity, toCity);
    final hours = diff.inMinutes / 60;
    if (hours == 0) return 'Same time';
    final sign = hours > 0 ? '+' : '';
    final rounded = hours.abs() == hours.abs().roundToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);
    return '$sign$rounded hours';
  }

  /// Get all available IANA timezone names.
  List<String> get availableTimeZones =>
      tz.timeZoneDatabase.locations.keys.toList()..sort();

  /// Check if DST is currently active for a city.
  bool isDstActive(City city) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final zone = city.location.timeZone(now);
    return zone.isDst;
  }

  /// Get abbreviation for a city's current timezone (e.g., "EST", "PDT").
  String getTimeZoneAbbreviation(City city) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return city.location.timeZone(now).abbreviation;
  }
}
