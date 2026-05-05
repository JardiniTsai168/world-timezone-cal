import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/city.dart';
import '../services/timezone_service.dart';
import '../widgets/city_time_card.dart';

class CalculateTimeScreen extends StatefulWidget {
  const CalculateTimeScreen({super.key});

  @override
  State<CalculateTimeScreen> createState() => _CalculateTimeScreenState();
}

class _CalculateTimeScreenState extends State<CalculateTimeScreen> {
  DateTime? _selectedTime;
  City? _referenceCity;

  Future<void> _pickTime(BuildContext context, City city) async {
    final tzService = TimezoneService();
    final now = tzService.getCurrentTime(city);

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null || !context.mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedTime = picked;
      _referenceCity = city;
    });
  }

  void _reset() {
    setState(() {
      _selectedTime = null;
      _referenceCity = null;
    });
  }

  DateTime _getDisplayTime(City city) {
    if (_selectedTime != null && _referenceCity != null) {
      return city.convertTime(_selectedTime!, _referenceCity!);
    }
    return TimezoneService().getCurrentTime(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate Time'),
        actions: [
          if (_selectedTime != null)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
            ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final cities = appState.selectedCities;

          if (cities.isEmpty) {
            return const Center(child: Text('No cities selected'));
          }

          return Column(
            children: [
              if (_selectedTime != null && _referenceCity != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    'Base: ${_referenceCity!.flagEmoji} ${_referenceCity!.name}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: cities.length,
                  itemBuilder: (_, i) {
                    final city = cities[i];
                    return CityTimeCard(
                      key: ValueKey('calc_${city.id}'),
                      city: city,
                      displayTime: _getDisplayTime(city),
                      is24Hour: appState.is24HourFormat,
                      showLiveIndicator: _selectedTime == null,
                      onTap: () => _pickTime(context, city),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final appState = context.read<AppState>();
          if (appState.selectedCities.isNotEmpty) {
            _pickTime(context, appState.selectedCities.first);
          }
        },
        icon: const Icon(Icons.edit_calendar),
        label: const Text('Set Time'),
      ),
    );
  }
}
