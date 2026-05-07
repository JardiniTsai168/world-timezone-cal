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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      size: 28,
                    ),
                  ),
                ),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(time),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$tzAbbr${isDst ? ' (DST)' : ''}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isEditing)
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (showArrow)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                    if (showLiveIndicator)
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
              if (!isEditing && onDelete != null)
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
