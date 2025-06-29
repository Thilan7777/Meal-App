import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white), // back button white
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode',
                    style: TextStyle(color: Colors.white)),
                value: false, // TODO: Implement dark mode
                onChanged: (value) {
                  // TODO: Implement dark mode toggle
                },
                activeColor: Colors.amber,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
              ListTile(
                title: const Text('Set Daily Calorie Goal',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${appState.currentUser?.dailyCalorieGoal.round() ?? 0} kcal',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  // TODO: Implement calorie goal setting
                },
              ),
              SwitchListTile(
                title: const Text('Enable Experimental Features',
                    style: TextStyle(color: Colors.white)),
                value: false, // TODO: Implement experimental features
                onChanged: (value) {
                  // TODO: Implement experimental features toggle
                },
                activeColor: Colors.amber,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
              ListTile(
                title: const Text('Clear Meal History',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Implement clear meal history
                },
              ),
              ListTile(
                title: const Text('Privacy Terms',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Implement privacy terms navigation
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
