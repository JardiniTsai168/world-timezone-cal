import 'package:flutter/material.dart';

class CurrentTimeScreen extends StatelessWidget {
  const CurrentTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Time'),
      ),
      body: const Center(
        child: Text('Current Time Screen - Phase 1 Placeholder'),
      ),
    );
  }
}
