import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_meal_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/meal_suggestions_screen.dart';
import '../screens/calorie_count_screen.dart';
import '../screens/shell_screen.dart';

class NavigationService {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/add-meal',
            name: 'add-meal',
            builder: (context, state) => const AddMealScreen(),
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/calorie-count',
        name: 'calorie-count',
        builder: (context, state) => const CalorieCountScreen(),
      ),
      GoRoute(
        path: '/meal-suggestions',
        name: 'meal-suggestions',
        builder: (context, state) => const MealSuggestionsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation helper methods
  static void goHome(BuildContext context) {
    context.go('/');
  }

  static void goToAddMeal(BuildContext context) {
    context.go('/add-meal');
  }

  static void goToStats(BuildContext context) {
    context.go('/stats');
  }

  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }

  static void goToCalorieCount(BuildContext context) {
    context.push('/calorie-count');
  }

  static void goToMealSuggestions(BuildContext context, {String? mealType}) {
    context.push('/meal-suggestions', extra: mealType);
  }

  // Bottom navigation helper
  static void navigateToTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        goHome(context);
        break;
      case 1:
        goToAddMeal(context);
        break;
      case 2:
        goToStats(context);
        break;
      case 3:
        goToProfile(context);
        break;
    }
  }

  // Get current tab index from route
  static int getCurrentTabIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/add-meal':
        return 1;
      case '/stats':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }
}
