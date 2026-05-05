import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/city.dart';
import '../services/timezone_service.dart';

class CityTimeCard extends StatelessWidget {
  final City city;
  final DateTime? displayTime;
  final bool showLiveIndicator;
  final bool is24Hour;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CityTimeCard({
    super.key,
    required this.city,
    this.displayTime,
    this.showLiveIndicator = true,
    this.is24Hour = true,
    this.onTap,
    this.onDelete,
  });

  String _formatTime(DateTime dt, bool is24Hour) {
    if (is24Hour) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('h:mm a').format(dt);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM dd').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final tzService = TimezoneService();
    final time = displayTime ?? tzService.getCurrentTime(city);
    final isDst = tzService.isDstActive(city);
    final tzAbbr = tzService.getTimeZoneAbbreviation(city);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                city.flagEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(time)}  $tzAbbr${isDst ? ' (DST)' : ''}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showLiveIndicator)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      Text(
                        _formatTime(time, is24Hour),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 22,
                            ),
                      ),
                    ],
                  ),
                  if (displayTime == null)
                    Text(
                      'Live',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF10B981),
                          ),
                    )
                  else
                    Text(
                      'Calculated',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444)),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
