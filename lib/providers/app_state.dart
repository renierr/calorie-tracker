import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/db_helper.dart';
import '../models/meal_model.dart';

class AppState extends ChangeNotifier {
  // SQLite instance
  final DbHelper _dbHelper = DbHelper.instance;

  // Preferences & settings keys
  static const String _keyGeminiApiKey = 'gemini_api_key';
  static const String _keyCalorieGoal = 'calorie_goal';
  static const String _keyProteinGoal = 'protein_goal';
  static const String _keyCarbsGoal = 'carbs_goal';
  static const String _keyFatGoal = 'fat_goal';
  static const String _keyHistoryFilter = 'history_filter';
  static const String _keyLocale = 'app_locale';

  // State variables
  String _geminiApiKey = '';
  int _calorieGoal = 2000;
  int _proteinGoal = 130;
  int _carbsGoal = 220;
  int _fatGoal = 70;
  String _historyFilter = 'all';
  String _appLocale = 'en';

  List<Meal> _meals = [];
  bool _isLoading = false;

  // Selected date for Dashboard tracking (defaults to today)
  DateTime _selectedDate = DateTime.now();

  // Tab index for navigation (0=Dashboard, 1=Scan, 2=History, 3=Settings)
  int _selectedTabIndex = 0;

  // Getters
  String get geminiApiKey => _geminiApiKey;
  int get calorieGoal => _calorieGoal;
  int get proteinGoal => _proteinGoal;
  int get carbsGoal => _carbsGoal;
  int get fatGoal => _fatGoal;
  String get historyFilter => _historyFilter;
  String get appLocale => _appLocale;
  Locale get locale => Locale(_appLocale);
  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get selectedTabIndex => _selectedTabIndex;

  // Filtered meals based on selected day (at midnight local time)
  List<Meal> get mealsForSelectedDate {
    return _meals.where((meal) {
      final mealDate = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
      return mealDate.year == _selectedDate.year &&
          mealDate.month == _selectedDate.month &&
          mealDate.day == _selectedDate.day;
    }).toList();
  }

  // Daily totals calculations
  int get totalCaloriesConsumed =>
      mealsForSelectedDate.fold(0, (sum, meal) => sum + meal.calories);
  int get totalProteinConsumed =>
      mealsForSelectedDate.fold(0, (sum, meal) => sum + meal.protein);
  int get totalCarbsConsumed =>
      mealsForSelectedDate.fold(0, (sum, meal) => sum + meal.carbs);
  int get totalFatConsumed =>
      mealsForSelectedDate.fold(0, (sum, meal) => sum + meal.fat);

  // Initialize and load everything on startup
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await loadSettings();
    await loadMeals();

    _isLoading = false;
    notifyListeners();
  }

  // Load configuration and credentials
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _geminiApiKey = prefs.getString(_keyGeminiApiKey) ?? '';
    _calorieGoal = prefs.getInt(_keyCalorieGoal) ?? 2000;
    _proteinGoal = prefs.getInt(_keyProteinGoal) ?? 130;
    _carbsGoal = prefs.getInt(_keyCarbsGoal) ?? 220;
    _fatGoal = prefs.getInt(_keyFatGoal) ?? 70;
    _historyFilter = prefs.getString(_keyHistoryFilter) ?? 'all';
    _appLocale = prefs.getString(_keyLocale) ?? 'en';
    notifyListeners();
  }

  // Save Settings
  Future<void> saveSettings({
    required String apiKey,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _geminiApiKey = apiKey.trim();
    _calorieGoal = calories;
    _proteinGoal = protein;
    _carbsGoal = carbs;
    _fatGoal = fat;

    await prefs.setString(_keyGeminiApiKey, _geminiApiKey);
    await prefs.setInt(_keyCalorieGoal, _calorieGoal);
    await prefs.setInt(_keyProteinGoal, _proteinGoal);
    await prefs.setInt(_keyCarbsGoal, _carbsGoal);
    await prefs.setInt(_keyFatGoal, _fatGoal);

    notifyListeners();
  }

  // Set and persist history filter
  Future<void> setHistoryFilter(String filter) async {
    _historyFilter = filter;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistoryFilter, filter);
  }

  // Database Meal Actions
  Future<void> loadMeals() async {
    _meals = await _dbHelper.getAllMeals();
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    await _dbHelper.insertMeal(meal);
    await loadMeals();
  }

  Future<void> updateMeal(Meal meal) async {
    await _dbHelper.updateMeal(meal);
    await loadMeals();
  }

  Future<void> deleteMeal(int id) async {
    await _dbHelper.deleteMeal(id);
    await loadMeals();
  }

  Future<void> clearAllMeals() async {
    await _dbHelper.clearDatabase();
    await loadMeals();
  }

  // Day Navigation
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  // Tab Navigation
  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Locale
  Future<void> setLocale(String code) async {
    _appLocale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, code);
  }

  // Export database
  Future<File> exportDatabase() => _dbHelper.exportDatabase();
}
