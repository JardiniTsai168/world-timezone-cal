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
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Reset to current time on app start - requirement 8
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedTime = null;
          _referenceCityId = null;
        });
      }
    });
  }

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

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Convert Timezone',
          style: TextStyle(fontSize: 16),
        ),
        leading: _selectedTime != null
            ? TextButton(
                onPressed: _reset,
                child: const Text('Reset'),
              )
            : null,
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.selectedCities.isEmpty && !_isEditMode) return const SizedBox.shrink();
              return TextButton(
                onPressed: _toggleEditMode,
                child: Text(_isEditMode ? 'Done' : 'Edit'),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final cities = appState.selectedCities;

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
              if (cities.isEmpty && !_isEditMode)
                const Expanded(
                  child: Center(child: Text('No cities selected')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _isEditMode ? cities.length + 1 : cities.length,
                    itemBuilder: (_, i) {
                      if (_isEditMode && i == cities.length) {
                        // ⊕ Add a location
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: InkWell(
                            onTap: () => _showAddCityDialog(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFFEF4444),
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Add a location',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: const Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final city = cities[i];
                      return CityTimeCard(
                        key: ValueKey('calc_${city.id}'),
                        city: city,
                        displayTime: _getDisplayTime(city.id, allCities),
                        is24Hour: appState.is24HourFormat,
                        showLiveIndicator: _selectedTime == null,
                        isEditing: _isEditMode,
                        onTap: _isEditMode ? null : () => _pickTime(context, city.id),
                        onDelete: _isEditMode
                            ? () => appState.removeCity(city)
                            : null,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
