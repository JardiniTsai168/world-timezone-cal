import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _SectionHeader(title: 'Appearance', context: context),
              _SettingsCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme throughout the app'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: appState.isDarkMode,
                      onChanged: (_) => appState.toggleDarkMode(),
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      title: const Text('24-Hour Format'),
                      subtitle: const Text('Display time in 24-hour notation'),
                      secondary: const Icon(Icons.access_time),
                      value: appState.is24HourFormat,
                      onChanged: (_) => appState.toggleTimeFormat(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'About', context: context),
              _SettingsCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Version'),
                      trailing: Text(
                        '1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('Cities in Database'),
                      trailing: Text(
                        '${appState.allCities.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.rocket_launch_outlined),
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: const [
                            TextSpan(text: 'Built by '),
                            TextSpan(
                              text: 'lihi.io',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: const Text(
                        'Branded URL shortener at your service',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://lihi.io'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final BuildContext context;

  const _SectionHeader({required this.title, required this.context});

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
