import 'package:flutter/material.dart';
import '../models/city.dart';

class CityPickerDialog extends StatefulWidget {
  final List<City> allCities;
  final List<City> excludedCities;
  final void Function(City) onSelected;

  const CityPickerDialog({
    super.key,
    required this.allCities,
    required this.excludedCities,
    required this.onSelected,
  });

  @override
  State<CityPickerDialog> createState() => _CityPickerDialogState();
}

class _CityPickerDialogState extends State<CityPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final excludedIds = widget.excludedCities.map((c) => c.id).toSet();
    final filtered = widget.allCities
        .where((c) => !excludedIds.contains(c.id))
        .where((c) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          // Search by city name, country name, or country code
          return c.name.toLowerCase().contains(q) ||
              c.country.toLowerCase().contains(q) ||
              c.countryCode.toLowerCase().contains(q);
        })
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add City',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No cities found'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                      itemBuilder: (_, i) {
                        final city = filtered[i];
                        return ListTile(
                          leading: Text(
                            city.flagEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(city.name),
                          subtitle: Text('${city.country} • ${city.timeZoneName}'),
                          trailing: Text(
                            _formatOffset(city),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          onTap: () {
                            widget.onSelected(city);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOffset(City city) {
    try {
      final now = DateTime.now().toUtc();
      final offset = city.currentTime.difference(now);
      final hours = offset.inMinutes ~/ 60;
      final remainder = offset.inMinutes.remainder(60);
      final sign = hours >= 0 ? '+' : '';
      if (remainder == 0) return 'UTC$sign$hours' 'h';
      return 'UTC$sign$hours:${remainder.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
