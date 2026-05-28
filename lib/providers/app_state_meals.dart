part of 'app_state.dart';

mixin _MealState on ChangeNotifier {
  AppState get _state => this as AppState;

  Future<void> loadMeals() async {
    _state._meals = await _state._dbHelper.getAllMeals(includeImages: false);
    _state._favoriteMeals = await _state._dbHelper.getFavoriteMeals(
      includeImages: true,
    );
    await _state.loadSelectedDateMeals();
    await _state.loadFirstPageHistory(showLoading: false);
    await _state.recalculateAllGamification();
    notifyListeners();
  }

  Future<void> loadSelectedDateMeals() async {
    _state._selectedDateMeals = await _state._dbHelper.getMealsForDate(
      _state._selectedDate,
      includeImages: true,
    );
    notifyListeners();
  }

  Future<List<Meal>> getMealsForFilter({required bool includeImages}) async {
    return await _state._dbHelper.getMealsPaginated(
      limit: null,
      filterType: _state._historyFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
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
      limit: 20,
      filterType: _state._historyFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      includeImages: true,
    );

    _state._hasMore = _state._paginatedMeals.length == 20;

    _state._historyTotalCount = await _state._dbHelper.getMealsCount(
      filterType: _state._historyFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
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

    final int? beforeTimestamp = _state._paginatedMeals.isNotEmpty
        ? _state._paginatedMeals.last.timestamp
        : null;
    final nextPageMeals = await _state._dbHelper.getMealsPaginated(
      limit: 20,
      beforeTimestamp: beforeTimestamp,
      filterType: _state._historyFilter,
      customStart: _state._historyCustomStartDate,
      customEnd: _state._historyCustomEndDate,
      includeImages: true,
    );

    _state._paginatedMeals.addAll(nextPageMeals);
    _state._hasMore = nextPageMeals.length == 20;
    _state._isFetchingMore = false;
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _state._dbHelper.insertMeal(unsyncedMeal);
    await loadMeals();
    await _state.onMealAdded();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final unsyncedMeal = meal.copyWith(synced: 0);
    await _state._dbHelper.updateMeal(unsyncedMeal);
    await loadMeals();
    await _state.checkTodayBudgetExceeded();
    await _state.checkImmediateAchievements();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
  }

  Future<void> deleteMeal(int id) async {
    await _state._dbHelper.deleteMeal(id);
    await loadMeals();
    await _state.onMealDeleted();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
  }

  Future<void> toggleFavoriteMeal(Meal meal) async {
    final updated = meal.copyWith(
      isFavorite: meal.isFavorite == 1 ? 0 : 1,
      synced: 0,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _state._dbHelper.updateMeal(updated);
    await loadMeals();
    if (_state._syncEnabled) {
      _state._trySyncIfAvailable();
    }
  }

  Future<void> clearAllMeals() async {
    await _state._dbHelper.clearDatabase();
    await loadMeals();
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
}
