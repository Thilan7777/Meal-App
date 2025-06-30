import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<AppStateProvider, ThemeProvider>(
        builder: (context, appState, themeProvider, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(
                  themeProvider.themeMode
                      .toString()
                      .split('.')
                      .last
                      .capitalize(),
                ),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
              ListTile(
                title: const Text('Set Daily Calorie Goal'),
                subtitle: Text(
                  '${appState.currentUser?.dailyCalorieGoal.round() ?? 0} kcal',
                ),
                onTap: () => _showCalorieGoalDialog(context, appState),
              ),
              SwitchListTile(
                title: const Text('Enable Experimental Features'),
                value: false, // TODO: Implement experimental features
                onChanged: (value) {
                  // TODO: Implement experimental features toggle
                },
              ),
              ListTile(
                title: const Text('Clear Meal History'),
                onTap: () => _showClearHistoryDialog(context, appState),
              ),
              ListTile(
                title: const Text('Privacy Terms'),
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

  void _showCalorieGoalDialog(BuildContext context, AppStateProvider appState) {
    final controller = TextEditingController(
      text: appState.currentUser?.dailyCalorieGoal.round().toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Calorie Goal'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newGoal = double.tryParse(controller.text);
                if (newGoal != null && newGoal > 0) {
                  final updatedUser = appState.currentUser!.copyWith(
                    dailyCalorieGoal: newGoal,
                  );
                  appState.updateUser(updatedUser);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog(
      BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Meal History?'),
          content: const Text(
              'This will permanently delete all your meal and calorie data. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appState.clearMealHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal history cleared.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                  }
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                  }
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
