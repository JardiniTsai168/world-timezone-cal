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
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
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
        leadingWidth: 80,
        leading: _selectedTime != null
            ? TextButton(
                onPressed: _reset,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Reset', style: TextStyle(fontSize: 14)),
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
          final inEditWithAdd = _isEditMode;
          final cityCount = cities.length;

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
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: inEditWithAdd ? cityCount + 1 : cityCount,
                    itemBuilder: (_, i) {
                      if (inEditWithAdd && i == cityCount) {
                        // Add a location row — no top border
                        return InkWell(
                          onTap: () => _showAddCityDialog(context),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFFEF4444),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add a location',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final isLastCityBeforeAdd = inEditWithAdd && i == cityCount - 1;
                      final city = cities[i];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: isLastCityBeforeAdd
                                ? BorderSide.none
                                : const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                        ),
                        child: CityTimeCard(
                          key: ValueKey('calc_${city.id}'),
                          city: city,
                          displayTime: _getDisplayTime(city.id, allCities),
                          is24Hour: appState.is24HourFormat,
                          showLiveIndicator: _selectedTime == null,
                          showArrow: _selectedTime != null,
                          isEditing: _isEditMode,
                          onTap: _isEditMode ? null : () => _pickTime(context, city.id),
                          onDelete: _isEditMode
                              ? () => appState.removeCity(city)
                              : null,
                        ),
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
