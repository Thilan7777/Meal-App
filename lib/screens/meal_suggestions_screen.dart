import 'package:flutter/material.dart';

class MealSuggestionsScreen extends StatefulWidget {
  final String mealType;

  const MealSuggestionsScreen({super.key, required this.mealType});

  @override
  State<MealSuggestionsScreen> createState() => _MealSuggestionsScreenState();
}

class _MealSuggestionsScreenState extends State<MealSuggestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Suggestions'),
      ),
      body: const Center(
        child: Text('Meal Suggestions Screen'),
      ),
    );
  }
}
