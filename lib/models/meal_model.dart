enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double nutrients; // in grams (vitamins/minerals)
  final MealType mealType;
  final DateTime date;
  final bool aiEstimated;
  final String? aiConfidence; // high, medium, low
  final String? aiResponse; // full AI response for reference
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.nutrients,
    required this.mealType,
    required this.date,
    this.aiEstimated = false,
    this.aiConfidence,
    this.aiResponse,
    required this.createdAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'nutrients': nutrients,
      'meal_type': mealType.name,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'ai_estimated': aiEstimated ? 1 : 0,
      'ai_confidence': aiConfidence,
      'ai_response': aiResponse,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (database)
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      calories: map['calories'].toDouble(),
      protein: map['protein'].toDouble(),
      carbs: map['carbs'].toDouble(),
      nutrients: map['nutrients'].toDouble(),
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['meal_type'],
        orElse: () => MealType.breakfast,
      ),
      date: DateTime.parse(map['date']),
      aiEstimated: map['ai_estimated'] == 1,
      aiConfidence: map['ai_confidence'],
      aiResponse: map['ai_response'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create from AI estimation
  factory Meal.fromAIEstimate({
    required String id,
    required String name,
    required CalorieEstimate estimate,
    required MealType mealType,
    DateTime? date,
  }) {
    return Meal(
      id: id,
      name: name,
      calories: estimate.calories,
      protein: estimate.protein,
      carbs: estimate.carbs,
      nutrients: estimate.nutrients,
      mealType: mealType,
      date: date ?? DateTime.now(),
      aiEstimated: true,
      aiConfidence: estimate.confidence,
      aiResponse: estimate.explanation,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for updates
  Meal copyWith({
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? nutrients,
    MealType? mealType,
    DateTime? date,
  }) {
    return Meal(
      id: id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      nutrients: nutrients ?? this.nutrients,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      aiEstimated: aiEstimated,
      aiConfidence: aiConfidence,
      aiResponse: aiResponse,
      createdAt: createdAt,
    );
  }

  // Get meal type display name
  String get mealTypeDisplayName {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  // Get meal type icon asset path
  String get mealTypeIconPath {
    switch (mealType) {
      case MealType.breakfast:
        return 'assets/breakfast.png';
      case MealType.lunch:
        return 'assets/lunch.png';
      case MealType.dinner:
        return 'assets/dinner.png';
      case MealType.snack:
        return 'assets/breakfast.png'; // Use breakfast icon for snacks
    }
  }
}

// Model for AI calorie estimation response
class CalorieEstimate {
  final double calories;
  final double protein;
  final double carbs;
  final double nutrients;
  final String confidence; // high, medium, low
  final String explanation;

  CalorieEstimate({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.nutrients,
    required this.confidence,
    required this.explanation,
  });

  // Create from JSON response
  factory CalorieEstimate.fromJson(Map<String, dynamic> json) {
    return CalorieEstimate(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      nutrients: (json['nutrients'] ?? 0).toDouble(),
      confidence: json['confidence'] ?? 'medium',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'nutrients': nutrients,
      'confidence': confidence,
      'explanation': explanation,
    };
  }

  CalorieEstimate copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? nutrients,
    String? confidence,
    String? explanation,
  }) {
    return CalorieEstimate(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      nutrients: nutrients ?? this.nutrients,
      confidence: confidence ?? this.confidence,
      explanation: explanation ?? this.explanation,
    );
  }
}
