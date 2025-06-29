import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/daily_log_model.dart';
import '../services/database_service.dart';
import '../services/openai_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final OpenAIService _openAIService = OpenAIService();
  final Uuid _uuid = Uuid();

  // User data
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Daily data
  DailyLog? _todayLog;
  DailyLog? get todayLog => _todayLog;

  List<Meal> _todayMeals = [];
  List<Meal> get todayMeals => _todayMeals;

  // Weekly data
  List<DailyLog> _weeklyLogs = [];
  List<DailyLog> get weeklyLogs => _weeklyLogs;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingCalories = false;
  bool get isLoadingCalories => _isLoadingCalories;

  bool _isLoadingSuggestions = false;
  bool get isLoadingSuggestions => _isLoadingSuggestions;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Meal suggestions
  List<MealSuggestion> _mealSuggestions = [];
  List<MealSuggestion> get mealSuggestions => _mealSuggestions;

  // Initialize app data
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      await _loadUser();
      await _loadTodayData();
      await _loadWeeklyData();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  // User operations
  Future<void> _loadUser() async {
    _currentUser = await _databaseService.getUser();
  }

  Future<void> createUser({
    required String name,
    required double currentWeight,
    required double targetWeight,
    required double height,
    required int age,
    required String gender,
    required double dailyCalorieGoal,
    double dailyWaterGoal = 3.0,
    String? profileImagePath,
  }) async {
    try {
      final user = User(
        id: _uuid.v4(),
        name: name,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        height: height,
        age: age,
        gender: gender,
        dailyCalorieGoal: dailyCalorieGoal,
        dailyWaterGoal: dailyWaterGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.insertUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _setError('Failed to create user: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _databaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user: $e');
    }
  }

  // Daily data operations
  Future<void> _loadTodayData() async {
    final today = DateTime.now();
    _todayLog = await _databaseService.getDailyLog(today);
    _todayMeals = await _databaseService.getTodayMeals();

    // Create today's log if it doesn't exist
    if (_todayLog == null) {
      _todayLog = DailyLog.fromMeals(
        id: _uuid.v4(),
        date: today,
        meals: _todayMeals,
      );
      await _databaseService.insertOrUpdateDailyLog(_todayLog!);
    }
  }

  Future<void> _loadWeeklyData() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _weeklyLogs = await _databaseService.getWeeklyLogs(startOfWeek);
  }

  // Meal operations
  Future<void> addMeal({
    required String name,
    required MealType mealType,
    double? calories,
    double? protein,
    double? carbs,
    double? nutrients,
  }) async {
    _setLoadingCalories(true);
    try {
      CalorieEstimate? estimate;

      // If nutritional info not provided, get AI estimation
      if (calories == null ||
          protein == null ||
          carbs == null ||
          nutrients == null) {
        estimate = await _openAIService.estimateCalories(name);
      }

      final meal = Meal(
        id: _uuid.v4(),
        name: name,
        calories: calories ?? estimate?.calories ?? 0,
        protein: protein ?? estimate?.protein ?? 0,
        carbs: carbs ?? estimate?.carbs ?? 0,
        nutrients: nutrients ?? estimate?.nutrients ?? 0,
        mealType: mealType,
        date: DateTime.now(),
        aiEstimated: estimate != null,
        aiConfidence: estimate?.confidence,
        aiResponse: estimate?.explanation,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertMeal(meal);
      await _refreshTodayData();
      _clearError();
    } catch (e) {
      _setError('Failed to add meal: $e');
    } finally {
      _setLoadingCalories(false);
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _databaseService.deleteMeal(mealId);
      await _refreshTodayData();
    } catch (e) {
      _setError('Failed to delete meal: $e');
    }
  }

  // Water intake operations
  Future<void> updateWaterIntake(double waterIntake) async {
    try {
      if (_todayLog != null) {
        final updatedLog = _todayLog!.copyWith(waterIntake: waterIntake);
        await _databaseService.insertOrUpdateDailyLog(updatedLog);
        _todayLog = updatedLog;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update water intake: $e');
    }
  }

  // Weight operations
  Future<void> updateTodayWeight(double weight) async {
    try {
      if (_todayLog != null) {
        final updatedLog = _todayLog!.copyWith(weight: weight);
        await _databaseService.insertOrUpdateDailyLog(updatedLog);
        _todayLog = updatedLog;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update weight: $e');
    }
  }

  Future<CalorieEstimate?> estimateCalories(String mealDescription) async {
    _setLoadingCalories(true);
    CalorieEstimate? estimate;
    try {
      estimate = await _openAIService.estimateCalories(mealDescription);
      _clearError();
    } catch (e) {
      _setError('Failed to estimate calories: $e');
    } finally {
      _setLoadingCalories(false);
    }
    return estimate;
  }

  // Meal suggestions
  Future<void> generateMealSuggestions(MealType mealType) async {
    _setLoadingSuggestions(true);
    try {
      final suggestions = await _openAIService.generateMealSuggestions(
        mealType: mealType,
        calorieGoal: _currentUser?.dailyCalorieGoal ?? 2000,
        currentWeight: _currentUser?.currentWeight ?? 70,
        targetWeight: _currentUser?.targetWeight ?? 65,
      );

      // Save suggestions to database
      for (var suggestion in suggestions) {
        await _databaseService.insertMealSuggestion(suggestion);
      }

      _mealSuggestions = suggestions;
      _clearError();
    } catch (e) {
      _setError('Failed to generate meal suggestions: $e');
    } finally {
      _setLoadingSuggestions(false);
    }
  }

  Future<void> addMealFromSuggestion(MealSuggestion suggestion) async {
    try {
      final meal = suggestion.toMeal(mealId: _uuid.v4());
      await _databaseService.insertMeal(meal);
      await _refreshTodayData();
    } catch (e) {
      _setError('Failed to add meal from suggestion: $e');
    }
  }

  // Refresh data
  Future<void> _refreshTodayData() async {
    await _loadTodayData();
    await _loadWeeklyData();
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    await initializeApp();
  }

  // Getters for calculated values
  double get todayCalorieProgress {
    if (_currentUser == null || _todayLog == null) return 0.0;
    return _todayLog!.getCalorieProgress(_currentUser!.dailyCalorieGoal);
  }

  double get todayWaterProgress {
    if (_currentUser == null || _todayLog == null) return 0.0;
    return _todayLog!.getWaterProgress(_currentUser!.dailyWaterGoal);
  }

  double get currentBMI {
    return _currentUser?.bmi ?? 0.0;
  }

  String get bmiCategory {
    return _currentUser?.bmiCategory ?? 'Unknown';
  }

  // Get meals by type for today
  List<Meal> getMealsByType(MealType mealType) {
    return _todayMeals.where((meal) => meal.mealType == mealType).toList();
  }

  // Get weekly calorie data for chart
  Map<String, double> get weeklyCalorieData {
    Map<String, double> data = {};
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final day = weekdays[i];
      final log = _weeklyLogs.firstWhere(
        (log) => log.formattedDate == day,
        orElse: () => DailyLog(
          id: '',
          date: DateTime.now(),
          totalCalories: 0,
          totalProtein: 0,
          totalCarbs: 0,
          totalNutrients: 0,
          waterIntake: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      data[day] = log.totalCalories;
    }

    return data;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingCalories(bool loading) {
    _isLoadingCalories = loading;
    notifyListeners();
  }

  void _setLoadingSuggestions(bool loading) {
    _isLoadingSuggestions = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
