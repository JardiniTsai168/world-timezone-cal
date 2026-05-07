import 'package:timezone/timezone.dart' as tz;

class City {
  final String id;
  final String name;
  final String countryCode;
  final String country; // Added country name for search
  final String timeZoneName;
  final String flagEmoji;
  final double? latitude;
  final double? longitude;

  const City({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.country,
    required this.timeZoneName,
    required this.flagEmoji,
    this.latitude,
    this.longitude,
  });

  tz.Location get location => tz.getLocation(timeZoneName);

  DateTime get currentTime => tz.TZDateTime.now(location);

  Duration getOffsetFrom(City other) {
    final now = DateTime.now();
    final myOffset = location.timeZone(now.millisecondsSinceEpoch).offset;
    final otherOffset = other.location.timeZone(now.millisecondsSinceEpoch).offset;
    return Duration(milliseconds: myOffset - otherOffset);
  }

  DateTime convertTime(DateTime sourceTime, City sourceCity) {
    final sourceLocation = sourceCity.location;
    final sourceTZ = tz.TZDateTime.from(sourceTime, sourceLocation);
    return tz.TZDateTime.from(sourceTZ, location);
  }

  /// Returns a flag emoji for a given ISO country code.
  static String? getFlagEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    if (code == 'TW') return '🇹🇼';
    if (code == 'JP') return '🇯🇵';
    if (code == 'KR') return '🇰🇷';
    if (code == 'CN') return '🇨🇳';
    if (code == 'SG') return '🇸🇬';
    if (code == 'AU') return '🇦🇺';
    if (code == 'GB') return '🇬🇧';
    if (code == 'FR') return '🇫🇷';
    if (code == 'DE') return '🇩🇪';
    if (code == 'US') return '🇺🇸';
    if (code == 'AE') return '🇦🇪';
    if (code == 'IN') return '🇮🇳';
    if (code == 'RU') return '🇷🇺';
    if (code == 'BR') return '🇧🇷';
    if (code == 'HK') return '🇭🇰';
    if (code == 'TH') return '🇹🇭';
    if (code == 'VN') return '🇻🇳';
    if (code == 'ID') return '🇮🇩';
    if (code == 'PH') return '🇵🇭';
    if (code == 'IT') return '🇮🇹';

    // Generic fallback: convert country code to regional indicator symbols
    const regionalOffset = 0x1F1E6;
    const aCode = 0x41;
    if (code.length == 2) {
      final c1 = code.codeUnitAt(0);
      final c2 = code.codeUnitAt(1);
      if (c1 >= aCode && c1 <= aCode + 25 && c2 >= aCode && c2 <= aCode + 25) {
        return String.fromCharCodes([
          regionalOffset + (c1 - aCode),
          regionalOffset + (c2 - aCode),
        ]);
      }
    }
    return '🏳️';
  }

  static List<City> getPredefinedCities() {
    return [
      City(id: 'taipei', name: 'Taipei', countryCode: 'TW', country: 'Taiwan', timeZoneName: 'Asia/Taipei', flagEmoji: '🇹🇼'),
      City(id: 'tokyo', name: 'Tokyo', countryCode: 'JP', country: 'Japan', timeZoneName: 'Asia/Tokyo', flagEmoji: '🇯🇵'),
      City(id: 'seoul', name: 'Seoul', countryCode: 'KR', country: 'South Korea', timeZoneName: 'Asia/Seoul', flagEmoji: '🇰🇷'),
      City(id: 'beijing', name: 'Beijing', countryCode: 'CN', country: 'China', timeZoneName: 'Asia/Shanghai', flagEmoji: '🇨🇳'),
      City(id: 'singapore', name: 'Singapore', countryCode: 'SG', country: 'Singapore', timeZoneName: 'Asia/Singapore', flagEmoji: '🇸🇬'),
      City(id: 'sydney', name: 'Sydney', countryCode: 'AU', country: 'Australia', timeZoneName: 'Australia/Sydney', flagEmoji: '🇦🇺'),
      City(id: 'london', name: 'London', countryCode: 'GB', country: 'United Kingdom', timeZoneName: 'Europe/London', flagEmoji: '🇬🇧'),
      City(id: 'paris', name: 'Paris', countryCode: 'FR', country: 'France', timeZoneName: 'Europe/Paris', flagEmoji: '🇫🇷'),
      City(id: 'berlin', name: 'Berlin', countryCode: 'DE', country: 'Germany', timeZoneName: 'Europe/Berlin', flagEmoji: '🇩🇪'),
      City(id: 'rome', name: 'Rome', countryCode: 'IT', country: 'Italy', timeZoneName: 'Europe/Rome', flagEmoji: '🇮🇹'),
      City(id: 'moscow', name: 'Moscow', countryCode: 'RU', country: 'Russia', timeZoneName: 'Europe/Moscow', flagEmoji: '🇷🇺'),
      City(id: 'new_york', name: 'New York', countryCode: 'US', country: 'United States', timeZoneName: 'America/New_York', flagEmoji: '🇺🇸'),
      City(id: 'los_angeles', name: 'Los Angeles', countryCode: 'US', country: 'United States', timeZoneName: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      City(id: 'chicago', name: 'Chicago', countryCode: 'US', country: 'United States', timeZoneName: 'America/Chicago', flagEmoji: '🇺🇸'),
      City(id: 'dubai', name: 'Dubai', countryCode: 'AE', country: 'United Arab Emirates', timeZoneName: 'Asia/Dubai', flagEmoji: '🇦🇪'),
      City(id: 'mumbai', name: 'Mumbai', countryCode: 'IN', country: 'India', timeZoneName: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      City(id: 'hong_kong', name: 'Hong Kong', countryCode: 'HK', country: 'Hong Kong', timeZoneName: 'Asia/Hong_Kong', flagEmoji: '🇭🇰'),
      City(id: 'bangkok', name: 'Bangkok', countryCode: 'TH', country: 'Thailand', timeZoneName: 'Asia/Bangkok', flagEmoji: '🇹🇭'),
      City(id: 'ho_chi_minh', name: 'Ho Chi Minh', countryCode: 'VN', country: 'Vietnam', timeZoneName: 'Asia/Ho_Chi_Minh', flagEmoji: '🇻🇳'),
      City(id: 'jakarta', name: 'Jakarta', countryCode: 'ID', country: 'Indonesia', timeZoneName: 'Asia/Jakarta', flagEmoji: '🇮🇩'),
      City(id: 'manila', name: 'Manila', countryCode: 'PH', country: 'Philippines', timeZoneName: 'Asia/Manila', flagEmoji: '🇵🇭'),
      City(id: 'sao_paulo', name: 'São Paulo', countryCode: 'BR', country: 'Brazil', timeZoneName: 'America/Sao_Paulo', flagEmoji: '🇧🇷'),
    ];
  }

  @override
  String toString() => 'City($flagEmoji $name, $timeZoneName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is City && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
