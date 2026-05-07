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
      // === TOP 3 MEGA MARKETS ===
      City(id: 'taipei', name: 'Taipei', countryCode: 'TW', country: 'Taiwan', timeZoneName: 'Asia/Taipei', flagEmoji: '🇹🇼'),
      City(id: 'tokyo', name: 'Tokyo', countryCode: 'JP', country: 'Japan', timeZoneName: 'Asia/Tokyo', flagEmoji: '🇯🇵'),
      City(id: 'osaka', name: 'Osaka', countryCode: 'JP', country: 'Japan', timeZoneName: 'Asia/Tokyo', flagEmoji: '🇯🇵'),
      City(id: 'washington_dc', name: 'Washington D.C.', countryCode: 'US', country: 'United States', timeZoneName: 'America/New_York', flagEmoji: '🇺🇸'),
      City(id: 'new_york', name: 'New York', countryCode: 'US', country: 'United States', timeZoneName: 'America/New_York', flagEmoji: '🇺🇸'),
      City(id: 'los_angeles', name: 'Los Angeles', countryCode: 'US', country: 'United States', timeZoneName: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      City(id: 'chicago', name: 'Chicago', countryCode: 'US', country: 'United States', timeZoneName: 'America/Chicago', flagEmoji: '🇺🇸'),
      City(id: 'san_francisco', name: 'San Francisco', countryCode: 'US', country: 'United States', timeZoneName: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      City(id: 'shanghai', name: 'Shanghai', countryCode: 'CN', country: 'China', timeZoneName: 'Asia/Shanghai', flagEmoji: '🇨🇳'),
      City(id: 'beijing', name: 'Beijing', countryCode: 'CN', country: 'China', timeZoneName: 'Asia/Shanghai', flagEmoji: '🇨🇳'),
      
      // === MAJOR EUROPEAN MARKETS ===
      City(id: 'london', name: 'London', countryCode: 'GB', country: 'United Kingdom', timeZoneName: 'Europe/London', flagEmoji: '🇬🇧'),
      City(id: 'berlin', name: 'Berlin', countryCode: 'DE', country: 'Germany', timeZoneName: 'Europe/Berlin', flagEmoji: '🇩🇪'),
      City(id: 'munich', name: 'Munich', countryCode: 'DE', country: 'Germany', timeZoneName: 'Europe/Berlin', flagEmoji: '🇩🇪'),
      City(id: 'frankfurt', name: 'Frankfurt', countryCode: 'DE', country: 'Germany', timeZoneName: 'Europe/Berlin', flagEmoji: '🇩🇪'),
      City(id: 'paris', name: 'Paris', countryCode: 'FR', country: 'France', timeZoneName: 'Europe/Paris', flagEmoji: '🇫🇷'),
      City(id: 'rome', name: 'Rome', countryCode: 'IT', country: 'Italy', timeZoneName: 'Europe/Rome', flagEmoji: '🇮🇹'),
      City(id: 'milan', name: 'Milan', countryCode: 'IT', country: 'Italy', timeZoneName: 'Europe/Rome', flagEmoji: '🇮🇹'),
      City(id: 'madrid', name: 'Madrid', countryCode: 'ES', country: 'Spain', timeZoneName: 'Europe/Madrid', flagEmoji: '🇪🇸'),
      City(id: 'barcelona', name: 'Barcelona', countryCode: 'ES', country: 'Spain', timeZoneName: 'Europe/Madrid', flagEmoji: '🇪🇸'),
      
      // === NORTH AMERICA ===
      City(id: 'toronto', name: 'Toronto', countryCode: 'CA', country: 'Canada', timeZoneName: 'America/Toronto', flagEmoji: '🇨🇦'),
      City(id: 'montreal', name: 'Montreal', countryCode: 'CA', country: 'Canada', timeZoneName: 'America/Toronto', flagEmoji: '🇨🇦'),
      City(id: 'vancouver', name: 'Vancouver', countryCode: 'CA', country: 'Canada', timeZoneName: 'America/Vancouver', flagEmoji: '🇨🇦'),
      
      // === ASIA-PACIFIC ===
      City(id: 'seoul', name: 'Seoul', countryCode: 'KR', country: 'South Korea', timeZoneName: 'Asia/Seoul', flagEmoji: '🇰🇷'),
      City(id: 'new_delhi', name: 'New Delhi', countryCode: 'IN', country: 'India', timeZoneName: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      City(id: 'mumbai', name: 'Mumbai', countryCode: 'IN', country: 'India', timeZoneName: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      City(id: 'bangalore', name: 'Bangalore', countryCode: 'IN', country: 'India', timeZoneName: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      City(id: 'sydney', name: 'Sydney', countryCode: 'AU', country: 'Australia', timeZoneName: 'Australia/Sydney', flagEmoji: '🇦🇺'),
      City(id: 'melbourne', name: 'Melbourne', countryCode: 'AU', country: 'Australia', timeZoneName: 'Australia/Melbourne', flagEmoji: '🇦🇺'),
      
      // === HIGH PENETRATION EUROPE ===
      City(id: 'amsterdam', name: 'Amsterdam', countryCode: 'NL', country: 'Netherlands', timeZoneName: 'Europe/Amsterdam', flagEmoji: '🇳🇱'),
      City(id: 'stockholm', name: 'Stockholm', countryCode: 'SE', country: 'Sweden', timeZoneName: 'Europe/Stockholm', flagEmoji: '🇸🇪'),
      City(id: 'reykjavik', name: 'Reykjavík', countryCode: 'IS', country: 'Iceland', timeZoneName: 'Atlantic/Reykjavik', flagEmoji: '🇮🇸'),
      City(id: 'zurich', name: 'Zürich', countryCode: 'CH', country: 'Switzerland', timeZoneName: 'Europe/Zurich', flagEmoji: '🇨🇭'),
      City(id: 'oslo', name: 'Oslo', countryCode: 'NO', country: 'Norway', timeZoneName: 'Europe/Oslo', flagEmoji: '🇳🇴'),
      City(id: 'copenhagen', name: 'Copenhagen', countryCode: 'DK', country: 'Denmark', timeZoneName: 'Europe/Copenhagen', flagEmoji: '🇩🇰'),
      
      // === MIDDLE EAST ===
      City(id: 'riyadh', name: 'Riyadh', countryCode: 'SA', country: 'Saudi Arabia', timeZoneName: 'Asia/Riyadh', flagEmoji: '🇸🇦'),
      City(id: 'dubai', name: 'Dubai', countryCode: 'AE', country: 'United Arab Emirates', timeZoneName: 'Asia/Dubai', flagEmoji: '🇦🇪'),
      
      // === ASIA HIGH PENETRATION ===
      City(id: 'hong_kong', name: 'Hong Kong', countryCode: 'HK', country: 'Hong Kong', timeZoneName: 'Asia/Hong_Kong', flagEmoji: '🇭🇰'),
      City(id: 'singapore', name: 'Singapore', countryCode: 'SG', country: 'Singapore', timeZoneName: 'Asia/Singapore', flagEmoji: '🇸🇬'),
      City(id: 'bangkok', name: 'Bangkok', countryCode: 'TH', country: 'Thailand', timeZoneName: 'Asia/Bangkok', flagEmoji: '🇹🇭'),
      City(id: 'phnom_penh', name: 'Phnom Penh', countryCode: 'KH', country: 'Cambodia', timeZoneName: 'Asia/Phnom_Penh', flagEmoji: '🇰🇭'),
      
      // === SPECIAL TERRITORIES (Very High Market Share) ===
      City(id: 'hamilton', name: 'Hamilton', countryCode: 'BM', country: 'Bermuda', timeZoneName: 'Atlantic/Bermuda', flagEmoji: '🇧🇲'),
      City(id: 'nassau', name: 'Nassau', countryCode: 'BS', country: 'Bahamas', timeZoneName: 'America/Nassau', flagEmoji: '🇧🇸'),
      City(id: 'torshavn', name: 'Tórshavn', countryCode: 'FO', country: 'Faroe Islands', timeZoneName: 'Atlantic/Faroe', flagEmoji: '🇫🇴'),
      City(id: 'san_marino', name: 'San Marino', countryCode: 'SM', country: 'San Marino', timeZoneName: 'Europe/San_Marino', flagEmoji: '🇸🇲'),
      City(id: 'andorra_la_vella', name: 'Andorra la Vella', countryCode: 'AD', country: 'Andorra', timeZoneName: 'Europe/Andorra', flagEmoji: '🇦🇩'),
      
      // === SOUTH AMERICA ===
      City(id: 'sao_paulo', name: 'São Paulo', countryCode: 'BR', country: 'Brazil', timeZoneName: 'America/Sao_Paulo', flagEmoji: '🇧🇷'),
      City(id: 'brasilia', name: 'Brasília', countryCode: 'BR', country: 'Brazil', timeZoneName: 'America/Sao_Paulo', flagEmoji: '🇧🇷'),
      
      // === OTHER ASIA ===
      City(id: 'moscow', name: 'Moscow', countryCode: 'RU', country: 'Russia', timeZoneName: 'Europe/Moscow', flagEmoji: '🇷🇺'),
      City(id: 'ho_chi_minh', name: 'Ho Chi Minh', countryCode: 'VN', country: 'Vietnam', timeZoneName: 'Asia/Ho_Chi_Minh', flagEmoji: '🇻🇳'),
      City(id: 'jakarta', name: 'Jakarta', countryCode: 'ID', country: 'Indonesia', timeZoneName: 'Asia/Jakarta', flagEmoji: '🇮🇩'),
      City(id: 'manila', name: 'Manila', countryCode: 'PH', country: 'Philippines', timeZoneName: 'Asia/Manila', flagEmoji: '🇵🇭'),
      City(id: 'kuala_lumpur', name: 'Kuala Lumpur', countryCode: 'MY', country: 'Malaysia', timeZoneName: 'Asia/Kuala_Lumpur', flagEmoji: '🇲🇾'),
      City(id: 'belmopan', name: 'Belmopan', countryCode: 'BZ', country: 'Belize', timeZoneName: 'America/Belize', flagEmoji: '🇧🇿'),
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
