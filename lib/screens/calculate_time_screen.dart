import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/timezone_service.dart';
import '../widgets/city_time_card.dart';
class CalculateTimeScreen extends StatefulWidget {
  const CalculateTimeScreen({super.key});

  @override
  State<CalculateTimeScreen> createState() => _CalculateTimeScreenState();
}

class _CalculateTimeScreenState extends State<CalculateTimeScreen> {
  DateTime? _selectedTime;
  String? _referenceCityId;

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
        title: const Text('Convert Timezone'),
        leading: _selectedTime != null
            ? TextButton(
                onPressed: _reset,
                child: const Text('Reset'),
              )
            : null,
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
                    return Dismissible(
                      key: Key('city_${city.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove City'),
                            content: Text('Remove ${city.flagEmoji} ${city.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF4444),
                                ),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        appState.removeCity(city);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${city.flagEmoji} ${city.name} removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () => appState.addCity(city),
                            ),
                          ),
                        );
                      },
                      child: CityTimeCard(
                        key: ValueKey('calc_${city.id}'),
                        city: city,
                        displayTime: _getDisplayTime(city.id, allCities),
                        is24Hour: appState.is24HourFormat,
                        showLiveIndicator: _selectedTime == null,
                        onTap: () => _pickTime(context, city.id),
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
