import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:world_timezone_cal/models/city.dart';
import 'package:world_timezone_cal/services/timezone_service.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('TimezoneService', () {
    late TimezoneService service;

    setUp(() {
      service = TimezoneService();
    });

    test('has 22 predefined cities', () {
      expect(service.allCities.length, 22);
    });

    test('getCurrentTime returns non-null', () {
      final taipei = service.allCities.firstWhere((c) => c.id == 'taipei');
      expect(service.getCurrentTime(taipei), isNotNull);
    });

    test('convertTime from Taipei to New York', () {
      final taipei = service.allCities.firstWhere((c) => c.id == 'taipei');
      final newYork = service.allCities.firstWhere((c) => c.id == 'new_york');

      // Taipei noon
      final taipeiTime = DateTime(2025, 2, 15, 12, 0);
      final nyTime = service.convertTime(
        time: taipeiTime,
        sourceCity: taipei,
        targetCity: newYork,
      );

      expect(nyTime, isNotNull);
      // February: no DST, Taipei UTC+8, NY UTC-5 => diff = 13h
      // Taipei 12:00 => NY 23:00 (previous day if applicable)
      expect(nyTime.hour, equals(23)); // 12 + (-13) = -1 => 23 previous day
    });

    test('getTimeDifference returns Duration', () {
      final taipei = service.allCities.firstWhere((c) => c.id == 'taipei');
      final tokyo = service.allCities.firstWhere((c) => c.id == 'tokyo');
      final diff = service.getTimeDifference(taipei, tokyo);
      expect(diff, isA<Duration>());
    });

    test('searchCities filters by name', () {
      final results = service.searchCities('tai');
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.first.name.toLowerCase(), contains('tai'));
    });
  });
}
