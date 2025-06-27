import 'meal_model.dart';

class DailyLog {
  final String id;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalNutrients;
  final double waterIntake; // in liters
  final double? weight; // optional daily weight
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyLog({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalNutrients,
    required this.waterIntake,
    this.weight,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_nutrients': totalNutrients,
      'water_intake': waterIntake,
      'weight': weight,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database)
  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalCalories: map['total_calories'].toDouble(),
      totalProtein: map['total_protein'].toDouble(),
      totalCarbs: map['total_carbs'].toDouble(),
      totalNutrients: map['total_nutrients'].toDouble(),
      waterIntake: map['water_intake'].toDouble(),
      weight: map['weight']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Create from meals list
  factory DailyLog.fromMeals({
    required String id,
    required DateTime date,
    required List<Meal> meals,
    double waterIntake = 0.0,
    double? weight,
  }) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalNutrients = 0;

    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalNutrients += meal.nutrients;
    }

    return DailyLog(
      id: id,
      date: date,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalNutrients: totalNutrients,
      waterIntake: waterIntake,
      weight: weight,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Copy with method for updates
  DailyLog copyWith({
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalNutrients,
    double? waterIntake,
    double? weight,
  }) {
    return DailyLog(
      id: id,
      date: date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalNutrients: totalNutrients ?? this.totalNutrients,
      waterIntake: waterIntake ?? this.waterIntake,
      weight: weight ?? this.weight,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Get formatted date string
  String get formattedDate {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  // Calculate calorie progress percentage (0.0 to 1.0)
  double getCalorieProgress(double dailyGoal) {
    if (dailyGoal <= 0) return 0.0;
    return (totalCalories / dailyGoal).clamp(0.0, 1.0);
  }

  // Calculate water progress percentage (0.0 to 1.0)
  double getWaterProgress(double dailyGoal) {
    if (dailyGoal <= 0) return 0.0;
    return (waterIntake / dailyGoal).clamp(0.0, 1.0);
  }
}

// Model for meal suggestions from AI
class MealSuggestion {
  final String id;
  final String name;
  final List<String> ingredients;
  final double estimatedCalories;
  final String preparation;
  final String reasoning;
  final MealType mealType;
  final DateTime createdAt;

  MealSuggestion({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.estimatedCalories,
    required this.preparation,
    required this.reasoning,
    required this.mealType,
    required this.createdAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.join('|'), // Store as pipe-separated string
      'estimated_calories': estimatedCalories,
      'preparation': preparation,
      'reasoning': reasoning,
      'meal_type': mealType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (database)
  factory MealSuggestion.fromMap(Map<String, dynamic> map) {
    return MealSuggestion(
      id: map['id'],
      name: map['name'],
      ingredients: map['ingredients'].split('|'),
      estimatedCalories: map['estimated_calories'].toDouble(),
      preparation: map['preparation'],
      reasoning: map['reasoning'],
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['meal_type'],
        orElse: () => MealType.breakfast,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create from JSON (AI response)
  factory MealSuggestion.fromJson(
      Map<String, dynamic> json, MealType mealType) {
    return MealSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      estimatedCalories: (json['estimated_calories'] ?? 0).toDouble(),
      preparation: json['preparation'] ?? '',
      reasoning: json['reasoning'] ?? '',
      mealType: mealType,
      createdAt: DateTime.now(),
    );
  }

  // Convert to Meal object
  Meal toMeal({required String mealId}) {
    // Estimate nutritional breakdown (rough approximation)
    double protein = estimatedCalories * 0.15 / 4; // 15% protein
    double carbs = estimatedCalories * 0.55 / 4; // 55% carbs
    double nutrients = estimatedCalories * 0.05 / 4; // 5% micronutrients

    return Meal(
      id: mealId,
      name: name,
      calories: estimatedCalories,
      protein: protein,
      carbs: carbs,
      nutrients: nutrients,
      mealType: mealType,
      date: DateTime.now(),
      aiEstimated: true,
      aiConfidence: 'medium',
      aiResponse: 'Generated from meal suggestion: $reasoning',
      createdAt: DateTime.now(),
    );
  }
}
