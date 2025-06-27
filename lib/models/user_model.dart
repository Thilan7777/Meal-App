class User {
  final String id;
  final String name;
  final double currentWeight;
  final double targetWeight;
  final double height; // in cm
  final int age;
  final String gender;
  final double dailyCalorieGoal;
  final double dailyWaterGoal; // in liters
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.age,
    required this.gender,
    required this.dailyCalorieGoal,
    this.dailyWaterGoal = 3.0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMI
  double get bmi => currentWeight / ((height / 100) * (height / 100));

  // BMI Category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'current_weight': currentWeight,
      'target_weight': targetWeight,
      'height': height,
      'age': age,
      'gender': gender,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_water_goal': dailyWaterGoal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      currentWeight: map['current_weight'].toDouble(),
      targetWeight: map['target_weight'].toDouble(),
      height: map['height'].toDouble(),
      age: map['age'],
      gender: map['gender'],
      dailyCalorieGoal: map['daily_calorie_goal'].toDouble(),
      dailyWaterGoal: map['daily_water_goal']?.toDouble() ?? 3.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // Copy with method for updates
  User copyWith({
    String? name,
    double? currentWeight,
    double? targetWeight,
    double? height,
    int? age,
    String? gender,
    double? dailyCalorieGoal,
    double? dailyWaterGoal,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
