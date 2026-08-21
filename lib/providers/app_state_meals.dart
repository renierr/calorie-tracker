part of 'app_state.dart';

mixin _MealState on ChangeNotifier {
  AppState get _state => this as AppState;

  Future<void> loadMeals() async {
    _state._meals = await _state._dbHelper.getAllMeals(includeImages: false);
    await loadFirstPageFavoriteMeals();
    await _state.loadSelectedDateMeals();
    await _state.loadFirstPageHistory(showLoading: false);
    await _state.recalculateAllGamification();
    notifyListeners();
  }

  /// Refreshes in-memory meal caches after a mutation.
  /// Skips full gamification recalc — use targeted per-hook calls instead.
  Future<void> _reloadCaches({bool refreshHistory = true}) async {
    _state._meals = await _state._dbHelper.getAllMeals(includeImages: false);
    _state._selectedDateMeals = await _state._dbHelper.getMealsForDate(
      _state._selectedDate,
      includeImages: true,
    );
    await loadFirstPageFavoriteMeals();
    _computeDailyTotals();
    if (refreshHistory) {
      await _state.loadFirstPageHistory(showLoading: false);
    }
  }

  Future<void> loadSelectedDateMeals() async {
    _state._selectedDateMeals = await _state._dbHelper.getMealsForDate(
      _state._selectedDate,
      includeImages: true,
    );
    _computeDailyTotals();
    notifyListeners();
  }

  /// Whether a logged entry already carries a body weight for [date].
  Future<bool> hasWeightLoggedOnDate(DateTime date) async {
    final meals = await _state._dbHelper.getMealsForDate(
      date,
      includeImages: false,
    );
    return meals.any((meal) => meal.weightKg != null);
  }

  void _computeDailyTotals() {
    int intake = 0, burned = 0, protein = 0, carbs = 0, fat = 0;
    for (final meal in _state._selectedDateMeals) {
      if (meal.isMeal) {
        intake += meal.calories;
        protein += meal.protein;
        carbs += meal.carbs;
        fat += meal.fat;
      } else {
        burned += meal.calories;
      }
    }
    _state._cachedTotalCaloriesIntake = intake;
    _state._cachedTotalCaloriesBurned = burned;
    _state._cachedTotalProteinConsumed = protein;
    _state._cachedTotalCarbsConsumed = carbs;
    _state._cachedTotalFatConsumed = fat;
  }

  Future<List<Meal>> getMealsForFilter({required bool includeImages}) async {
    return await _state._dbHelper.getMealsPaginated(
      limit: null,
      filterType: _state._historyFilter,
      typeFilter: _state._historyTypeFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      searchQuery: _state._historySearchQuery,
      includeImages: includeImages,
    );
  }

  Future<void> loadFirstPageHistory({bool showLoading = true}) async {
    if (showLoading) {
      _state._isLoading = true;
      notifyListeners();
    }

    _state._hasMore = true;
    _state._isFetchingMore = false;
    _state._paginatedMeals = await _state._dbHelper.getMealsPaginated(
      limit: AppConstants.pageSize,
      filterType: _state._historyFilter,
      typeFilter: _state._historyTypeFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      searchQuery: _state._historySearchQuery,
      includeImages: true,
    );

    _state._hasMore = _state._paginatedMeals.length == AppConstants.pageSize;

    _state._historyTotalCount = await _state._dbHelper.getMealsCount(
      filterType: _state._historyFilter,
      typeFilter: _state._historyTypeFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      searchQuery: _state._historySearchQuery,
    );

    if (showLoading) {
      _state._isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchNextPageHistory() async {
    if (_state._isFetchingMore || !_state._hasMore) return;

    _state._isFetchingMore = true;
    notifyListeners();

    final isSearching = _state._historySearchQuery.trim().isNotEmpty;
    final nextPageMeals = await _state._dbHelper.getMealsPaginated(
      limit: AppConstants.pageSize,
      beforeTimestamp: isSearching || _state._paginatedMeals.isEmpty
          ? null
          : _state._paginatedMeals.last.timestamp,
      offset: isSearching ? _state._paginatedMeals.length : 0,
      filterType: _state._historyFilter,
      typeFilter: _state._historyTypeFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      searchQuery: _state._historySearchQuery,
      includeImages: true,
    );

    _state._paginatedMeals.addAll(nextPageMeals);
    _state._hasMore = nextPageMeals.length == AppConstants.pageSize;
    _state._isFetchingMore = false;
    notifyListeners();
  }

  Future<void> loadFirstPageFavoriteMeals() async {
    _state._hasMoreFavoriteMeals = true;
    _state._isFetchingMoreFavoriteMeals = false;
    _state._paginatedFavoriteMeals = await _state._dbHelper.getMealsPaginated(
      limit: AppConstants.pageSize,
      filterType: 'favorites',
      searchQuery: _state._favoriteSearchQuery,
      includeImages: true,
    );
    _state._hasMoreFavoriteMeals =
        _state._paginatedFavoriteMeals.length == AppConstants.pageSize;
    _state._favoriteTotalCount = await _state._dbHelper.getMealsCount(
      filterType: 'favorites',
      searchQuery: _state._favoriteSearchQuery,
    );
    notifyListeners();
  }

  Future<void> fetchNextPageFavoriteMeals() async {
    if (_state._isFetchingMoreFavoriteMeals || !_state._hasMoreFavoriteMeals) {
      return;
    }

    _state._isFetchingMoreFavoriteMeals = true;
    notifyListeners();
    final isSearching = _state._favoriteSearchQuery.trim().isNotEmpty;
    final nextPageMeals = await _state._dbHelper.getMealsPaginated(
      limit: AppConstants.pageSize,
      beforeTimestamp: isSearching || _state._paginatedFavoriteMeals.isEmpty
          ? null
          : _state._paginatedFavoriteMeals.last.timestamp,
      offset: isSearching ? _state._paginatedFavoriteMeals.length : 0,
      filterType: 'favorites',
      searchQuery: _state._favoriteSearchQuery,
      includeImages: true,
    );
    _state._paginatedFavoriteMeals.addAll(nextPageMeals);
    _state._hasMoreFavoriteMeals =
        nextPageMeals.length == AppConstants.pageSize;
    _state._isFetchingMoreFavoriteMeals = false;
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _state._dbHelper.insertMeal(unsyncedMeal);
    await _reloadCaches();
    notifyListeners();
    await _state.onMealAdded();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
    if (_state._healthConnectEnabled) {
      HealthConnectNutritionPublisher.instance.publishMeals([unsyncedMeal]);
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _state._dbHelper.updateMeal(unsyncedMeal);
    await _reloadCaches();
    notifyListeners();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
    if (_state._healthConnectEnabled) {
      HealthConnectNutritionPublisher.instance.publishMeals([unsyncedMeal]);
    }
  }

  Future<void> deleteMeal(int id) async {
    await _state._dbHelper.deleteMeal(id);
    await _reloadCaches();
    notifyListeners();
    await _state.onMealDeleted();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
    if (_state._healthConnectEnabled) {
      _state.publishMealsToHealthConnect(reconcile: true);
    }
  }

  Future<void> toggleFavoriteMeal(Meal meal) async {
    final updated = meal.copyWith(
      isFavorite: meal.isFavorite == 1 ? 0 : 1,
      synced: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _state._dbHelper.updateMeal(updated);
    await _reloadCaches(refreshHistory: false);
    notifyListeners();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
  }

  Future<void> clearAllMeals() async {
    await _state._dbHelper.clearDatabase();
    _state._meals = [];
    _state._selectedDateMeals = [];
    _state._paginatedFavoriteMeals = [];
    _state._favoriteTotalCount = 0;
    _state._paginatedMeals = [];
    _state._hasMore = true;
    _state._historyTotalCount = 0;
    _computeDailyTotals();
    notifyListeners();
  }

  Future<String> exportMealsToJson(List<Meal> mealsToExport) async {
    final List<Meal> fullMeals = [];
    for (final meal in mealsToExport) {
      if (meal.id != null && meal.imageBytes == null) {
        final imgBytes = await _state._dbHelper.getMealImageBytes(meal.id!);
        fullMeals.add(meal.copyWith(imageBytes: imgBytes));
      } else {
        fullMeals.add(meal);
      }
    }

    final Map<String, dynamic> exportMap = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': {
        'calorieGoal': _state._calorieGoal,
        'proteinGoal': _state._proteinGoal,
        'carbsGoal': _state._carbsGoal,
        'fatGoal': _state._fatGoal,
      },
      'meals': fullMeals.map((m) => m.toJsonExport()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  Future<int> importMealsFromJson(String jsonContent) async {
    _state._isLoading = true;
    notifyListeners();

    try {
      final decoded = json.decode(jsonContent);
      List<dynamic> mealsJsonList = [];

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('meals') && decoded['meals'] is List) {
          mealsJsonList = decoded['meals'] as List;
        } else {
          mealsJsonList = [decoded];
        }
      } else if (decoded is List) {
        mealsJsonList = decoded;
      } else {
        throw const FormatException('Invalid JSON payload structure');
      }

      int importCount = 0;
      for (final item in mealsJsonList) {
        if (item is Map<String, dynamic>) {
          final meal = Meal.fromJsonExport(item);

          final existingMeal = await _state._dbHelper.getMealByShortId(
            meal.shortId,
          );
          if (existingMeal != null) {
            final mergedMeal = meal.copyWith(id: existingMeal.id);
            await _state._dbHelper.updateMeal(mergedMeal);
          } else {
            await _state._dbHelper.insertMeal(meal);
          }
          importCount++;
        }
      }

      await loadMeals();
      return importCount;
    } catch (e) {
      rethrow;
    } finally {
      _state._isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> getMealImageBytes(int id) async {
    return await _state._dbHelper.getMealImageBytes(id);
  }
}
