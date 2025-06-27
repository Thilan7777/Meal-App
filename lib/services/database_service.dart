import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/daily_log_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meal_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        current_weight REAL NOT NULL,
        target_weight REAL NOT NULL,
        height REAL NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        daily_calorie_goal REAL NOT NULL,
        daily_water_goal REAL DEFAULT 3.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Meals table
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        nutrients REAL NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        ai_estimated INTEGER DEFAULT 0,
        ai_confidence TEXT,
        ai_response TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Daily logs table
    await db.execute('''
      CREATE TABLE daily_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        total_calories REAL NOT NULL,
        total_protein REAL NOT NULL,
        total_carbs REAL NOT NULL,
        total_nutrients REAL NOT NULL,
        water_intake REAL NOT NULL,
        weight REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Meal suggestions table
    await db.execute('''
      CREATE TABLE meal_suggestions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        estimated_calories REAL NOT NULL,
        preparation TEXT NOT NULL,
        reasoning TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Meal operations
  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    return await db.insert('meals', meal.toMap());
  }

  Future<List<Meal>> getMealsForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'meals',
      where: 'date = ?',
      whereArgs: [dateString],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<List<Meal>> getTodayMeals() async {
    return await getMealsForDate(DateTime.now());
  }

  Future<List<Meal>> getMealsByType(DateTime date, MealType mealType) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'meals',
      where: 'date = ? AND meal_type = ?',
      whereArgs: [dateString, mealType.name],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(String mealId) async {
    final db = await database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [mealId],
    );
  }

  // Daily log operations
  Future<int> insertOrUpdateDailyLog(DailyLog dailyLog) async {
    final db = await database;
    final dateString = dailyLog.date.toIso8601String().split('T')[0];

    // Check if log exists for this date
    final existing = await db.query(
      'daily_logs',
      where: 'date = ?',
      whereArgs: [dateString],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'daily_logs',
        dailyLog.toMap(),
        where: 'date = ?',
        whereArgs: [dateString],
      );
    } else {
      return await db.insert('daily_logs', dailyLog.toMap());
    }
  }

  Future<DailyLog?> getDailyLog(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_logs',
      where: 'date = ?',
      whereArgs: [dateString],
    );
    if (maps.isNotEmpty) {
      return DailyLog.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DailyLog>> getWeeklyLogs(DateTime startDate) async {
    final db = await database;
    final endDate = startDate.add(Duration(days: 6));
    final startDateString = startDate.toIso8601String().split('T')[0];
    final endDateString = endDate.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'daily_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDateString, endDateString],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => DailyLog.fromMap(maps[i]));
  }

  Future<DailyLog?> getTodayLog() async {
    return await getDailyLog(DateTime.now());
  }

  // Meal suggestion operations
  Future<int> insertMealSuggestion(MealSuggestion suggestion) async {
    final db = await database;
    return await db.insert('meal_suggestions', suggestion.toMap());
  }

  Future<List<MealSuggestion>> getMealSuggestions(MealType mealType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_suggestions',
      where: 'meal_type = ?',
      whereArgs: [mealType.name],
      orderBy: 'created_at DESC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => MealSuggestion.fromMap(maps[i]));
  }

  // Statistics and analytics
  Future<Map<String, double>> getWeeklyCalorieStats() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    Map<String, double> weeklyStats = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateString = date.toIso8601String().split('T')[0];

      final result = await db.rawQuery(
        'SELECT SUM(calories) as total FROM meals WHERE date = ?',
        [dateString],
      );

      final total = result.first['total'] as double? ?? 0.0;
      weeklyStats[date.weekday.toString()] = total;
    }

    return weeklyStats;
  }

  Future<double> getTotalCaloriesForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];

    final result = await db.rawQuery(
      'SELECT SUM(calories) as total FROM meals WHERE date = ?',
      [dateString],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  // Update daily log from meals
  Future<void> updateDailyLogFromMeals(DateTime date) async {
    final meals = await getMealsForDate(date);
    final existingLog = await getDailyLog(date);

    final dailyLog = DailyLog.fromMeals(
      id: existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      meals: meals,
      waterIntake: existingLog?.waterIntake ?? 0.0,
      weight: existingLog?.weight,
    );

    await insertOrUpdateDailyLog(dailyLog);
  }

  // Clean up old data (optional)
  Future<void> cleanupOldData({int daysToKeep = 90}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffDateString = cutoffDate.toIso8601String().split('T')[0];

    await db.delete(
      'meals',
      where: 'date < ?',
      whereArgs: [cutoffDateString],
    );

    await db.delete(
      'daily_logs',
      where: 'date < ?',
      whereArgs: [cutoffDateString],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
