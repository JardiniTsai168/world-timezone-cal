import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/city_time_card.dart';
import '../widgets/empty_state.dart';

class CurrentTimeScreen extends StatefulWidget {
  const CurrentTimeScreen({super.key});

  @override
  State<CurrentTimeScreen> createState() => _CurrentTimeScreenState();
}

class _CurrentTimeScreenState extends State<CurrentTimeScreen> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showAddCityDialog(BuildContext context) {
    final appState = context.read<AppState>();
    final available = appState.allCities
        .where((c) => !appState.selectedCities.any((s) => s.id == c.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All cities already added')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add City',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: available.length,
                itemBuilder: (_, i) {
                  final city = available[i];
                  return ListTile(
                    leading: Text(city.flagEmoji, style: const TextStyle(fontSize: 24)),
                    title: Text(city.name),
                    subtitle: Text(city.timeZoneName),
                    onTap: () {
                      appState.addCity(city);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Time'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.selectedCities.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAddCityDialog(context),
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

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: cities.length,
            itemBuilder: (_, i) {
              final city = cities[i];
                    return CityTimeCard(
                      key: ValueKey(city.id),
                      city: city,
                      is24Hour: appState.is24HourFormat,
                      showLiveIndicator: true,
                      onDelete: () => appState.removeCity(city),
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
