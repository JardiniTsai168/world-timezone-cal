import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/city.dart';
import '../services/timezone_service.dart';

class CityTimeCard extends StatelessWidget {
  final City city;
  final DateTime? displayTime;
  final bool showLiveIndicator;
  final bool is24Hour;
  final bool showArrow;
  final bool isEditing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CityTimeCard({
    super.key,
    required this.city,
    this.displayTime,
    this.showLiveIndicator = true,
    this.is24Hour = true,
    this.showArrow = true,
    this.isEditing = false,
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

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
              ),
            Text(
              city.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isEditing)
                    Text(
                      city.country,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      '${_formatDate(time)}  $tzAbbr${isDst ? ' (DST)' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!isEditing)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLiveIndicator)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  Text(
                    _formatTime(time, is24Hour),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (showArrow)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
