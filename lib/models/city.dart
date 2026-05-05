import 'package:timezone/timezone.dart' as tz;

class City {
  final String name;
  final String countryCode;
  final String timeZoneName;
  final double? latitude;
  final double? longitude;

  const City({
    required this.name,
    required this.countryCode,
    required this.timeZoneName,
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

  @override
  String toString() => 'City(name: $name, timeZone: $timeZoneName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && name == other.name && timeZoneName == other.timeZoneName;

  @override
  int get hashCode => Object.hash(name, timeZoneName);
}
