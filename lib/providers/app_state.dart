import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/db_helper.dart';
import '../models/meal_model.dart';
import '../services/sync_service.dart';

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
  static const String _keyThemeMode = 'theme_mode';
  static const String _keySyncServerUrl = 'sync_server_url';
  static const String _keySyncUserId = 'sync_user_id';
  static const String _keyLastSyncedTime = 'last_synced_time';
  static const String _keySyncEnabled = 'sync_enabled';

  // State variables
  String _geminiApiKey = '';
  int _calorieGoal = 2000;
  int _proteinGoal = 130;
  int _carbsGoal = 220;
  int _fatGoal = 70;
  String _historyFilter = 'all';
  String _appLocale = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  String _syncServerUrl = '';
  String _syncUserId = 'user-1';
  int? _lastSyncedTime;
  bool _isSyncing = false;
  bool _syncEnabled = false;

  List<Meal> _meals = [];
  bool _isLoading = false;

  // Selected date for Dashboard tracking (defaults to today)
  DateTime _selectedDate = DateTime.now();

  // Tab index for navigation (0=Dashboard, 1=Scan, 2=History, 3=Settings)
  int _selectedTabIndex = 0;

  // Template meal for manual entry
  Meal? _templateMeal;

  // Lazy loading & Pagination states
  List<Meal> _selectedDateMeals = [];
  List<Meal> _paginatedMeals = [];
  bool _hasMore = true;
  bool _isFetchingMore = false;
  int _historyTotalCount = 0;
  DateTime? _historyCustomStartDate;
  DateTime? _historyCustomEndDate;

  // Getters
  String get geminiApiKey => _geminiApiKey;
  int get calorieGoal => _calorieGoal;
  int get proteinGoal => _proteinGoal;
  int get carbsGoal => _carbsGoal;
  int get fatGoal => _fatGoal;
  String get historyFilter => _historyFilter;
  String get appLocale => _appLocale;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => Locale(_appLocale);
  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  int get selectedTabIndex => _selectedTabIndex;
  Meal? get templateMeal => _templateMeal;
  String get syncServerUrl => _syncServerUrl;
  String get syncUserId => _syncUserId;
  int? get lastSyncedTime => _lastSyncedTime;
  bool get isSyncing => _isSyncing;
  bool get syncEnabled => _syncEnabled;

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

    // Auto sync on startup if backend is enabled and reachable
    if (_syncEnabled && _syncServerUrl.isNotEmpty) {
      _trySyncIfAvailable();
    }
  }

  // Check backend health before syncing (used for non-manual triggers)
  Future<void> _trySyncIfAvailable() async {
    if (!_syncEnabled || _syncServerUrl.isEmpty) return;
    try {
      final available = await SyncService.isBackendAvailable(_syncServerUrl);
      if (available) {
        await syncWithBackend();
      }
    } catch (e) {
      debugPrint('[AppState] Background sync skipped: $e');
    }
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
    final themeStr = prefs.getString(_keyThemeMode) ?? 'system';
    _themeMode = _parseThemeMode(themeStr);

    _syncServerUrl = prefs.getString(_keySyncServerUrl) ?? '';
    _syncUserId = prefs.getString(_keySyncUserId) ?? 'user-1';
    _lastSyncedTime = prefs.getInt(_keyLastSyncedTime);
    _syncEnabled = prefs.getBool(_keySyncEnabled) ?? false;
    notifyListeners();
  }

  // Save Sync Settings
  Future<void> saveSyncSettings({
    required String serverUrl,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _syncServerUrl = serverUrl.trim();
    _syncUserId = userId.trim();

    await prefs.setString(_keySyncServerUrl, _syncServerUrl);
    await prefs.setString(_keySyncUserId, _syncUserId);
    notifyListeners();
  }

  // Toggle sync enabled/disabled
  Future<void> setSyncEnabled(bool enabled) async {
    _syncEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySyncEnabled, enabled);

    if (_syncEnabled && _syncServerUrl.isNotEmpty) {
      _trySyncIfAvailable();
    }
  }

  // Synchronize database with Bun server
  Future<Map<String, int>?> syncWithBackend({bool manual = false}) async {
    if (!_syncEnabled || _syncServerUrl.isEmpty) return null;

    _isSyncing = true;
    notifyListeners();

    try {
      final results = await SyncService.sync(
        baseUrl: _syncServerUrl,
        userId: _syncUserId,
      );

      _lastSyncedTime = DateTime.now().millisecondsSinceEpoch;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastSyncedTime, _lastSyncedTime!);

      await loadMeals(); // Reload meals from local SQLite
      return results;
    } catch (e) {
      debugPrint('[AppState] Sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
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
    await loadFirstPageHistory();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistoryFilter, filter);
  }

  // Set history custom dates and trigger load
  Future<void> setHistoryCustomDates(DateTime? start, DateTime? end) async {
    _historyCustomStartDate = start;
    _historyCustomEndDate = end;
    await loadFirstPageHistory();
  }

  // Database Meal Actions
  Future<void> loadMeals() async {
    _meals = await _dbHelper.getAllMeals(includeImages: false);
    await loadSelectedDateMeals();
    await loadFirstPageHistory(showLoading: false);
    notifyListeners();
  }

  Future<void> loadSelectedDateMeals() async {
    _selectedDateMeals = await _dbHelper.getMealsForDate(
      _selectedDate,
      includeImages: true,
    );
    notifyListeners();
  }

  // Lazy Loaded / Paginated History loading
  Future<List<Meal>> getMealsForFilter({required bool includeImages}) async {
    return await _dbHelper.getMealsPaginated(
      limit: null,
      filterType: _historyFilter,
      customStart: _historyCustomStartDate,
      customEnd: _historyCustomEndDate,
      includeImages: includeImages,
    );
  }

  Future<void> loadFirstPageHistory({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _hasMore = true;
    _isFetchingMore = false;
    _paginatedMeals = await _dbHelper.getMealsPaginated(
      limit: 20,
      filterType: _historyFilter,
      customStart: _historyCustomStartDate,
      customEnd: _historyCustomEndDate,
      includeImages: true,
    );

    _hasMore = _paginatedMeals.length == 20;

    _historyTotalCount = await _dbHelper.getMealsCount(
      filterType: _historyFilter,
      customStart: _historyCustomStartDate,
      customEnd: _historyCustomEndDate,
    );

    if (showLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchNextPageHistory() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    final int? beforeTimestamp = _paginatedMeals.isNotEmpty
        ? _paginatedMeals.last.timestamp
        : null;
    final nextPageMeals = await _dbHelper.getMealsPaginated(
      limit: 20,
      beforeTimestamp: beforeTimestamp,
      filterType: _historyFilter,
      customStart: _historyCustomStartDate,
      customEnd: _historyCustomEndDate,
      includeImages: true,
    );

    _paginatedMeals.addAll(nextPageMeals);
    _hasMore = nextPageMeals.length == 20;
    _isFetchingMore = false;
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _dbHelper.insertMeal(unsyncedMeal);
    await loadMeals();
    if (_syncEnabled) {
      _trySyncIfAvailable();
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _dbHelper.updateMeal(unsyncedMeal);
    await loadMeals();
    if (_syncEnabled) {
      _trySyncIfAvailable();
    }
  }

  Future<void> deleteMeal(int id) async {
    await _dbHelper.deleteMeal(id);
    await loadMeals();
    if (_syncEnabled) {
      _trySyncIfAvailable();
    }
  }

  Future<void> clearAllMeals() async {
    await _dbHelper.clearDatabase();
    await loadMeals();
  }

  // Day Navigation
  void selectDate(DateTime date) {
    _selectedDate = date;
    loadSelectedDateMeals();
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    loadSelectedDateMeals();
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    loadSelectedDateMeals();
  }

  // Tab Navigation
  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Template Meal for scan/manual entry
  void setTemplateMeal(Meal? meal) {
    _templateMeal = meal;
    if (meal != null) {
      _selectedTabIndex = 1;
    }
    notifyListeners();
  }

  void clearTemplateMeal() {
    _templateMeal = null;
    notifyListeners();
  }

  // Locale
  Future<void> setLocale(String code) async {
    _appLocale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, code);
  }

  // Theme
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, _themeModeString(mode));
  }

  ThemeMode _parseThemeMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  // Export database
  Future<File> exportDatabase({required String destPath}) =>
      _dbHelper.exportDatabase(destPath: destPath);

  // Read database bytes for direct exporting
  Future<Uint8List> getDatabaseBytes() async {
    final String path = await _dbHelper.databasePath;
    return await File(path).readAsBytes();
  }

  // Restore database
  Future<void> restoreDatabase(String backupPath) async {
    await _dbHelper.restoreDatabase(backupPath: backupPath);
    await loadMeals();
  }

  // Export meals list to a standard JSON string
  Future<String> exportMealsToJson(List<Meal> mealsToExport) async {
    final List<Meal> fullMeals = [];
    for (final meal in mealsToExport) {
      if (meal.id != null && meal.imageBytes == null) {
        final imgBytes = await _dbHelper.getMealImageBytes(meal.id!);
        fullMeals.add(meal.copyWith(imageBytes: imgBytes));
      } else {
        fullMeals.add(meal);
      }
    }

    final Map<String, dynamic> exportMap = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': {
        'calorieGoal': _calorieGoal,
        'proteinGoal': _proteinGoal,
        'carbsGoal': _carbsGoal,
        'fatGoal': _fatGoal,
      },
      'meals': fullMeals.map((m) => m.toJsonExport()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  // Import meals from a JSON string (Full Envelope, Raw Array, or Single Meal)
  // Ignoring and omitting settings from the envelope.
  Future<int> importMealsFromJson(String jsonContent) async {
    _isLoading = true;
    notifyListeners();

    try {
      final decoded = json.decode(jsonContent);
      List<dynamic> mealsJsonList = [];

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('meals') && decoded['meals'] is List) {
          // Full Envelope standard
          mealsJsonList = decoded['meals'] as List;
        } else {
          // Single Entry Map
          mealsJsonList = [decoded];
        }
      } else if (decoded is List) {
        // Raw Array
        mealsJsonList = decoded;
      } else {
        throw const FormatException('Invalid JSON payload structure');
      }

      int importCount = 0;
      for (final item in mealsJsonList) {
        if (item is Map<String, dynamic>) {
          final meal = Meal.fromJsonExport(item);

          // Collision deduplication by shortId
          final existingMeal = await _dbHelper.getMealByShortId(meal.shortId);
          if (existingMeal != null) {
            // Overwrite existing meal with the new data, keeping its primary database ID
            final mergedMeal = meal.copyWith(id: existingMeal.id);
            await _dbHelper.updateMeal(mergedMeal);
          } else {
            // Insert as a new entry
            await _dbHelper.insertMeal(meal);
          }
          importCount++;
        }
      }

      await loadMeals();
      return importCount;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
