import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/timezone_service.dart';
import '../widgets/city_time_card.dart';
import '../widgets/city_picker_dialog.dart';

class CalculateTimeScreen extends StatefulWidget {
  const CalculateTimeScreen({super.key});

  @override
  State<CalculateTimeScreen> createState() => _CalculateTimeScreenState();
}

class _CalculateTimeScreenState extends State<CalculateTimeScreen> {
  DateTime? _selectedTime;
  String? _referenceCityId;

  Future<void> _pickTime(BuildContext context, String cityId) async {
    final appState = context.read<AppState>();
    final city = appState.allCities.firstWhere((c) => c.id == cityId);
    final tzService = TimezoneService();
    final now = tzService.getCurrentTime(city);

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // ignore: use_build_context_synchronously
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    // ignore: use_build_context_synchronously
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      _selectedTime = picked;
      _referenceCityId = cityId;
    });
  }

  void _reset() {
    setState(() {
      _selectedTime = null;
      _referenceCityId = null;
    });
  }

  DateTime _getDisplayTime(String cityId, List<dynamic> allCities) {
    if (_selectedTime != null && _referenceCityId != null) {
      final refCity = allCities.firstWhere((c) => c.id == _referenceCityId);
      final targetCity = allCities.firstWhere((c) => c.id == cityId);
      return TimezoneService().convertTime(
        time: _selectedTime!,
        sourceCity: refCity,
        targetCity: targetCity,
      );
    }
    final city = allCities.firstWhere((c) => c.id == cityId);
    return TimezoneService().getCurrentTime(city);
  }

  void _showAddCityDialog(BuildContext context) {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => CityPickerDialog(
        allCities: appState.allCities.toList(),
        excludedCities: appState.selectedCities.toList(),
        onSelected: appState.addCity,
      ),
    );
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

          final allCities = appState.allCities;
          final refCity = _referenceCityId != null
              ? allCities.firstWhere((c) => c.id == _referenceCityId)
              : null;

          return Column(
            children: [
              if (refCity != null && _selectedTime != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Text(
                        'Base: ${refCity.flagEmoji} ${refCity.name}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
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
                      displayTime: _getDisplayTime(city.id, allCities),
                      is24Hour: appState.is24HourFormat,
                      showLiveIndicator: _selectedTime == null,
                      onTap: () => _pickTime(context, city.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCityDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add City'),
      ),
    );
  }
}
