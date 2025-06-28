import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/meal_model.dart';
import '../models/daily_log_model.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Estimate calories for a meal description
  Future<CalorieEstimate> estimateCalories(String mealDescription) async {
    try {
      final prompt = '''
Analyze this Sri Lankan meal and provide nutritional information: "$mealDescription"

Please respond with ONLY a JSON object in this exact format:
{
  "calories": 450,
  "protein": 25.5,
  "carbs": 55.2,
  "nutrients": 8.3,
  "confidence": "high",
  "explanation": "Brief explanation of the estimation"
}

Guidelines:
- calories: total calories
- protein: grams of protein
- carbs: grams of carbohydrates  
- nutrients: grams of vitamins/minerals/fiber
- confidence: "high", "medium", or "low"
- explanation: 1-2 sentences explaining the estimation

Focus on typical Sri Lankan portion sizes and ingredients.
''';

      final response = await _makeOpenAIRequest(prompt);

      if (response != null) {
        return CalorieEstimate.fromJson(response);
      } else {
        // Fallback estimation
        return _getFallbackEstimate(mealDescription);
      }
    } catch (e) {
      print('OpenAI API Error: $e');
      return _getFallbackEstimate(mealDescription);
    }
  }

  // Generate meal suggestions
  Future<List<MealSuggestion>> generateMealSuggestions({
    required MealType mealType,
    required double calorieGoal,
    required double currentWeight,
    required double targetWeight,
  }) async {
    final targetCalories = _calculateMealCalories(mealType, calorieGoal);

    try {
      final mealTypeStr = mealType.name;

      final prompt = '''
Generate 3 healthy Sri Lankan $mealTypeStr suggestions for weight management.

User details:
- Current weight: ${currentWeight}kg
- Target weight: ${targetWeight}kg
- Target calories for this meal: ${targetCalories.round()} kcal
- Daily calorie goal: ${calorieGoal.round()} kcal

Please respond with ONLY a JSON array in this exact format:
[
  {
    "name": "Meal Name",
    "ingredients": ["ingredient1", "ingredient2", "ingredient3"],
    "estimated_calories": 400,
    "preparation": "Brief cooking instructions",
    "reasoning": "Why this meal is good for weight management"
  }
]

Requirements:
- Use authentic Sri Lankan ingredients and dishes
- Focus on weight loss/management
- Include protein, vegetables, and healthy carbs
- Keep portions reasonable for the calorie target
- Make meals practical and easy to prepare
''';

      final response = await _makeOpenAIRequest(prompt);

      if (response != null && response is List) {
        return response
            .map<MealSuggestion>(
                (json) => MealSuggestion.fromJson(json, mealType))
            .toList();
      } else {
        return _getFallbackSuggestions(mealType, targetCalories);
      }
    } catch (e) {
      print('OpenAI API Error: $e');
      return _getFallbackSuggestions(mealType, targetCalories);
    }
  }

  // Make HTTP request to OpenAI API
  Future<dynamic> _makeOpenAIRequest(String prompt) async {
    if (_apiKey.isEmpty) {
      print('OpenAI API key not found');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a nutritionist specializing in Sri Lankan cuisine. Always respond with valid JSON only.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Clean the response and parse JSON
        final cleanContent = content.trim();
        return jsonDecode(cleanContent);
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('HTTP Request Error: $e');
      return null;
    }
  }

  // Calculate target calories for each meal type
  double _calculateMealCalories(MealType mealType, double dailyGoal) {
    switch (mealType) {
      case MealType.breakfast:
        return dailyGoal * 0.25; // 25% of daily calories
      case MealType.lunch:
        return dailyGoal * 0.35; // 35% of daily calories
      case MealType.dinner:
        return dailyGoal * 0.30; // 30% of daily calories
      case MealType.snack:
        return dailyGoal * 0.10; // 10% of daily calories
    }
  }

  // Fallback calorie estimation when API fails
  CalorieEstimate _getFallbackEstimate(String mealDescription) {
    final description = mealDescription.toLowerCase();
    double calories = 300; // Default

    // Simple keyword-based estimation
    if (description.contains('rice') || description.contains('hoppers')) {
      calories += 200;
    }
    if (description.contains('curry') || description.contains('dhal')) {
      calories += 150;
    }
    if (description.contains('chicken') || description.contains('fish')) {
      calories += 200;
    }
    if (description.contains('coconut') || description.contains('oil')) {
      calories += 100;
    }
    if (description.contains('vegetable') || description.contains('salad')) {
      calories += 50;
    }

    return CalorieEstimate(
      calories: calories,
      protein: calories * 0.15 / 4, // 15% protein
      carbs: calories * 0.55 / 4, // 55% carbs
      nutrients: calories * 0.05 / 4, // 5% micronutrients
      confidence: 'low',
      explanation: 'Estimated based on common Sri Lankan meal components',
    );
  }

  // Fallback meal suggestions when API fails
  List<MealSuggestion> _getFallbackSuggestions(
      MealType mealType, double targetCalories) {
    final suggestions = <MealSuggestion>[];
    final now = DateTime.now();

    switch (mealType) {
      case MealType.breakfast:
        suggestions.addAll([
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_1',
            name: 'String Hoppers with Dhal Curry',
            ingredients: ['String hoppers (2)', 'Dhal curry', 'Sambol', 'Tea'],
            estimatedCalories: targetCalories,
            preparation: 'Steam hoppers, prepare dhal curry with minimal oil',
            reasoning: 'High protein from dhal, complex carbs from hoppers',
            mealType: mealType,
            createdAt: now,
          ),
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_2',
            name: 'Oats with Fruits',
            ingredients: ['Oats', 'Banana', 'Papaya', 'Milk'],
            estimatedCalories: targetCalories * 0.8,
            preparation: 'Cook oats with low-fat milk, add fresh fruits',
            reasoning: 'High fiber, natural sugars, keeps you full longer',
            mealType: mealType,
            createdAt: now,
          ),
        ]);
        break;

      case MealType.lunch:
        suggestions.addAll([
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_1',
            name: 'Brown Rice with Fish Curry',
            ingredients: [
              'Brown rice (1 cup)',
              'Fish curry',
              'Green salad',
              'Papadam'
            ],
            estimatedCalories: targetCalories,
            preparation:
                'Steam brown rice, prepare fish curry with minimal coconut milk',
            reasoning: 'Lean protein from fish, complex carbs, high fiber',
            mealType: mealType,
            createdAt: now,
          ),
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_2',
            name: 'Vegetable Kottu',
            ingredients: [
              'Roti (2 pieces)',
              'Mixed vegetables',
              'Egg (1)',
              'Onions'
            ],
            estimatedCalories: targetCalories * 0.9,
            preparation:
                'Stir-fry vegetables with minimal oil, add chopped roti',
            reasoning: 'Balanced meal with vegetables and moderate carbs',
            mealType: mealType,
            createdAt: now,
          ),
        ]);
        break;

      case MealType.dinner:
        suggestions.addAll([
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_1',
            name: 'Grilled Chicken with Vegetables',
            ingredients: [
              'Chicken breast',
              'Broccoli',
              'Carrots',
              'Green beans'
            ],
            estimatedCalories: targetCalories,
            preparation: 'Grill chicken with herbs, steam vegetables',
            reasoning: 'High protein, low carb dinner for weight loss',
            mealType: mealType,
            createdAt: now,
          ),
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_2',
            name: 'Vegetable Soup with Bread',
            ingredients: [
              'Mixed vegetables',
              'Lentils',
              'Whole grain bread (1 slice)'
            ],
            estimatedCalories: targetCalories * 0.8,
            preparation: 'Boil vegetables and lentils, minimal salt and oil',
            reasoning: 'Light dinner, high fiber, easy to digest',
            mealType: mealType,
            createdAt: now,
          ),
        ]);
        break;

      case MealType.snack:
        suggestions.addAll([
          MealSuggestion(
            id: '${now.millisecondsSinceEpoch}_1',
            name: 'Fruit Salad',
            ingredients: ['Apple', 'Orange', 'Grapes', 'Lime juice'],
            estimatedCalories: targetCalories,
            preparation: 'Cut fruits, add lime juice',
            reasoning: 'Natural sugars, vitamins, low calorie',
            mealType: mealType,
            createdAt: now,
          ),
        ]);
        break;
    }

    return suggestions.take(3).toList();
  }
}
