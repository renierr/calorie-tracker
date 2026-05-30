import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/db_helper.dart';
import '../models/meal_model.dart';
import '../models/gamification_model.dart';
import '../l10n/app_localizations.dart';
import '../services/sync_service.dart';
import '../services/ai_service.dart';

part 'app_state_meals.dart';
part 'app_state_settings.dart';
part 'app_state_sync.dart';
part 'app_state_navigation.dart';
part 'app_state_ai.dart';
part 'app_state_gamification.dart';

class AppState extends ChangeNotifier
    with
        _MealState,
        _SettingsState,
        _SyncState,
        _NavigationState,
        _AiState,
        _GamificationState {
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
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySyncServerUrl = 'sync_server_url';
  static const String _keySyncUserId = 'sync_user_id';
  static const String _keyLastSyncedTime = 'last_synced_time';
  static const String _keySyncEnabled = 'sync_enabled';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  static const String _keyAiProvider = 'ai_provider';
  static const String _keyAiModel = 'ai_model';
  static const String _keyAiApiKey = 'ai_api_key';
  static const String _keyAiCustomUrl = 'ai_custom_url';
  static const String _keyAiReasoningEffort = 'ai_reasoning_effort';

  // State variables
  String _aiProvider = AIServiceConfig.defaultProvider;
  String _aiModel = AIServiceConfig.defaultModel;
  String _aiApiKey = '';
  String _aiCustomUrl = '';
  String _aiReasoningEffort = 'none';
  int _calorieGoal = 2000;
  int _proteinGoal = 130;
  int _carbsGoal = 220;
  int _fatGoal = 70;
  String _historyFilter = 'all';
  String _historyTypeFilter = 'all'; // 'all', 'meals', 'activities'
  String _appLocale = 'en';
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  String _syncServerUrl = '';
  String _syncUserId = 'user-1';
  int? _lastSyncedTime;
  bool _isSyncing = false;
  bool _syncEnabled = false;

  List<Meal> _meals = [];
  List<Meal> _favoriteMeals = [];
  bool _isLoading = false;

  // Selected date for Dashboard tracking (defaults to today)
  DateTime _selectedDate = DateTime.now();

  // Tab index for navigation (0=Dashboard, 1=Scan, 2=History, 3=Settings)
  int _selectedTabIndex = 0;

  // Template meal for manual entry
  Meal? _templateMeal;

  // Scan page state variables
  Uint8List? _scanImageBytes;
  String _scanMimeType = 'image/jpeg';
  String _scanUserHint = '';
  bool _scanShowForm = false;
  bool _scanIsScanning = false;
  AIAnalysisResult? _scanResult;
  bool _scanIsPickedImage = false;
  bool _scanIsAiFlow = false;
  bool _scanIsActivity = false;

  // Scan Verification Form Draft Values
  String _scanFoodName = '';
  String _scanCalories = '';
  String _scanProtein = '';
  String _scanCarbs = '';
  String _scanFat = '';
  String _scanNotes = '';
  String _scanWeight = '';
  DateTime _scanMealDate = DateTime.now();

  // Lazy loading & Pagination states
  List<Meal> _selectedDateMeals = [];
  List<Meal> _paginatedMeals = [];
  bool _hasMore = true;
  bool _isFetchingMore = false;
  int _historyTotalCount = 0;
  DateTime? _historyCustomStartDate;
  DateTime? _historyCustomEndDate;

  // Getters
  int get calorieGoal => _calorieGoal;
  int get proteinGoal => _proteinGoal;
  int get carbsGoal => _carbsGoal;
  int get fatGoal => _fatGoal;
  String get historyFilter => _historyFilter;
  String get historyTypeFilter => _historyTypeFilter;
  String get appLocale => _appLocale;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => Locale(_appLocale);
  List<Meal> get meals => _meals;
  List<Meal> get favoriteMeals => _favoriteMeals;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get selectedTabIndex => _selectedTabIndex;
  Meal? get templateMeal => _templateMeal;
  String get syncServerUrl => _syncServerUrl;
  String get syncUserId => _syncUserId;
  int? get lastSyncedTime => _lastSyncedTime;
  bool get isSyncing => _isSyncing;
  bool get syncEnabled => _syncEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get scanIsActivity => _scanIsActivity;

  // Optimized lazy-loaded selected date meals
  List<Meal> get mealsForSelectedDate => _selectedDateMeals;

  // Paginated states
  List<Meal> get paginatedMeals => _paginatedMeals;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  int get historyTotalCount => _historyTotalCount;
  DateTime? get historyCustomStartDate => _historyCustomStartDate;
  DateTime? get historyCustomEndDate => _historyCustomEndDate;

  // Daily totals calculations
  int get totalCaloriesIntake => mealsForSelectedDate
      .where((m) => m.isMeal)
      .fold(0, (sum, meal) => sum + meal.calories);

  int get totalCaloriesBurned => mealsForSelectedDate
      .where((m) => m.isActivity)
      .fold(0, (sum, meal) => sum + meal.calories);

  int get totalCaloriesConsumed => totalCaloriesIntake - totalCaloriesBurned;

  int get totalProteinConsumed => mealsForSelectedDate
      .where((m) => m.isMeal)
      .fold(0, (sum, meal) => sum + meal.protein);

  int get totalCarbsConsumed => mealsForSelectedDate
      .where((m) => m.isMeal)
      .fold(0, (sum, meal) => sum + meal.carbs);

  int get totalFatConsumed => mealsForSelectedDate
      .where((m) => m.isMeal)
      .fold(0, (sum, meal) => sum + meal.fat);

  // Initialize and load everything on startup
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await loadSettings();
    await loadMeals();
    await loadGamification();

    _isLoading = false;
    notifyListeners();

    // Auto sync on startup if backend is enabled and reachable
    if (_syncEnabled && _syncServerUrl.isNotEmpty) {
      _trySyncIfAvailable();
    }
  }
}
