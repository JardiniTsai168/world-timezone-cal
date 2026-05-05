import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/city.dart';

class TimezoneService {
  static bool _initialized = false;

  static void initialize() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  static final List<City> _defaultCities = [
    const City(name: 'Taipei', countryCode: 'TW', timeZoneName: 'Asia/Taipei'),
    const City(name: 'Tokyo', countryCode: 'JP', timeZoneName: 'Asia/Tokyo'),
    const City(name: 'Seoul', countryCode: 'KR', timeZoneName: 'Asia/Seoul'),
    const City(name: 'Beijing', countryCode: 'CN', timeZoneName: 'Asia/Shanghai'),
    const City(name: 'Singapore', countryCode: 'SG', timeZoneName: 'Asia/Singapore'),
    const City(name: 'Sydney', countryCode: 'AU', timeZoneName: 'Australia/Sydney'),
    const City(name: 'London', countryCode: 'GB', timeZoneName: 'Europe/London'),
    const City(name: 'Paris', countryCode: 'FR', timeZoneName: 'Europe/Paris'),
    const City(name: 'Berlin', countryCode: 'DE', timeZoneName: 'Europe/Berlin'),
    const City(name: 'New York', countryCode: 'US', timeZoneName: 'America/New_York'),
    const City(name: 'Los Angeles', countryCode: 'US', timeZoneName: 'America/Los_Angeles'),
    const City(name: 'Chicago', countryCode: 'US', timeZoneName: 'America/Chicago'),
    const City(name: 'Dubai', countryCode: 'AE', timeZoneName: 'Asia/Dubai'),
    const City(name: 'Mumbai', countryCode: 'IN', timeZoneName: 'Asia/Kolkata'),
    const City(name: 'Moscow', countryCode: 'RU', timeZoneName: 'Europe/Moscow'),
    const City(name: 'São Paulo', countryCode: 'BR', timeZoneName: 'America/Sao_Paulo'),
  ];

  List<City> get defaultCities => List.unmodifiable(_defaultCities);

  List<City> searchCities(String query) {
    if (query.isEmpty) return defaultCities;
    final lower = query.toLowerCase();
    return _defaultCities
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.countryCode.toLowerCase().contains(lower))
        .toList();
  }

  List<String> get allTimeZoneNames => tz.timeZoneDatabase.locations.keys.toList();

  City? findCityByTimeZone(String timeZoneName) {
    try {
      tz.getLocation(timeZoneName);
      return City(
        name: timeZoneName.split('/').last.replaceAll('_', ' '),
        countryCode: '',
        timeZoneName: timeZoneName,
      );
    } catch (e) {
      return null;
    }
  }
}
