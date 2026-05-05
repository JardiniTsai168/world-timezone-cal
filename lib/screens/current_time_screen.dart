import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/city_time_card.dart';
import '../widgets/city_picker_dialog.dart';
import '../widgets/empty_state.dart';

class CurrentTimeScreen extends StatefulWidget {
  const CurrentTimeScreen({super.key});

  @override
  State<CurrentTimeScreen> createState() => _CurrentTimeScreenState();
}

class _CurrentTimeScreenState extends State<CurrentTimeScreen> {
  Timer? _timer;
  int _tick = 0;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Time'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.selectedCities.isEmpty) return const SizedBox.shrink();
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

          if (cities.isEmpty) {
            return EmptyState(
              icon: Icons.access_time,
              title: 'No cities selected',
              subtitle: 'Add cities to see their current time',
              onAction: () => _showAddCityDialog(context),
              actionLabel: 'Add City',
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: cities.length,
            buildDefaultDragHandles: _isEditMode,
            onReorder: (oldIndex, newIndex) {
              context.read<AppState>().reorderCities(oldIndex, newIndex);
            },
            itemBuilder: (_, i) {
              final city = cities[i];
              return CityTimeCard(
                key: ValueKey(city.id),
                city: city,
                is24Hour: appState.is24HourFormat,
                showLiveIndicator: true,
                onDelete: _isEditMode ? () => appState.removeCity(city) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
