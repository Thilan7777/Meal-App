import 'package:flutter/material.dart';

class CalorieCountScreen extends StatefulWidget {
  const CalorieCountScreen({super.key});

  @override
  State<CalorieCountScreen> createState() => _CalorieCountScreenState();
}

class _CalorieCountScreenState extends State<CalorieCountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Counter'),
      ),
      body: const Center(
        child: Text('Calorie Count Screen'),
      ),
    );
  }
}
