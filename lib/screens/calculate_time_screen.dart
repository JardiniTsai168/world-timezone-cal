import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

    // Initialize wheel values from current time
    int selYear = now.year;
    int selMonth = now.month;
    int selDay = now.day;
    int selHour = now.hour;
    int selMinute = now.minute;

    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final years = List.generate(7, (i) => 2024 + i); // 2024-2030

    int _daysInMonth(int year, int month) {
      return DateTime(year, month + 1, 0).day;
    }

    Widget _buildWheel({
      required int itemCount,
      required int initialItem,
      required String Function(int) labelBuilder,
      required ValueChanged<int> onChanged,
      required double width,
    }) {
      final controller = FixedExtentScrollController(initialItem: initialItem);
      return SizedBox(
        width: width,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 40,
          perspective: 0.005,
          diameterRatio: 1.2,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= itemCount) return null;
              return Center(
                child: Text(
                  labelBuilder(index),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            },
            childCount: itemCount,
          ),
        ),
      );
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              // Top bar: Cancel / City Name / Done
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '${city.flagEmoji} ${city.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(ctx).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Custom wheels: Year | Month | Day | Hour | Min
              Expanded(
                child: Stack(
                  children: [
                    // Selection highlight bar
                    Center(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Year wheel
                        Expanded(
                          flex: 2,
                          child: _buildWheel(
                            itemCount: years.length,
                            initialItem: selYear - 2024,
                            labelBuilder: (i) => '${years[i]}',
                            onChanged: (i) => selYear = years[i],
                            width: 70,
                          ),
                        ),
                        // Month wheel
                        Expanded(
                          flex: 2,
                          child: _buildWheel(
                            itemCount: 12,
                            initialItem: selMonth - 1,
                            labelBuilder: (i) => months[i],
                            onChanged: (i) => selMonth = i + 1,
                            width: 60,
                          ),
                        ),
                        // Day wheel
                        Expanded(
                          flex: 2,
                          child: _buildWheel(
                            itemCount: _daysInMonth(selYear, selMonth),
                            initialItem: selDay - 1,
                            labelBuilder: (i) => '${i + 1}',
                            onChanged: (i) => selDay = i + 1,
                            width: 50,
                          ),
                        ),
                        // Separator
                        const SizedBox(width: 4),
                        // Hour wheel
                        Expanded(
                          flex: 2,
                          child: _buildWheel(
                            itemCount: 24,
                            initialItem: selHour,
                            labelBuilder: (i) => i.toString().padLeft(2, '0'),
                            onChanged: (i) => selHour = i,
                            width: 50,
                          ),
                        ),
                        // Colon
                        const Text(':', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        // Minute wheel
                        Expanded(
                          flex: 2,
                          child: _buildWheel(
                            itemCount: 60,
                            initialItem: selMinute,
                            labelBuilder: (i) => i.toString().padLeft(2, '0'),
                            onChanged: (i) => selMinute = i,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      final maxDay = DateTime(selYear, selMonth + 1, 0).day;
      if (selDay > maxDay) selDay = maxDay;
      final picked = DateTime(selYear, selMonth, selDay, selHour, selMinute);
      setState(() {
        _selectedTime = picked;
        _referenceCityId = cityId;
      });
    }
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

                      final isLastItem = i == cityCount - 1;
                      final city = cities[i];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: isLastItem
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
                          showArrow: true,
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
