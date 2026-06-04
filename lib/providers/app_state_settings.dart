part of 'app_state.dart';

mixin _SettingsState on ChangeNotifier {
  AppState get _state => this as AppState;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _state._calorieGoal =
        prefs.getInt(AppState._keyCalorieGoal) ??
        AppConstants.defaultCalorieGoal;
    _state._proteinGoal =
        prefs.getInt(AppState._keyProteinGoal) ??
        AppConstants.defaultProteinGoal;
    _state._carbsGoal =
        prefs.getInt(AppState._keyCarbsGoal) ?? AppConstants.defaultCarbsGoal;
    _state._fatGoal =
        prefs.getInt(AppState._keyFatGoal) ?? AppConstants.defaultFatGoal;
    _state._historyFilter =
        prefs.getString(AppState._keyHistoryFilter) ?? 'all';
    _state._appLocale = prefs.getString(AppState._keyLocale) ?? 'en';
    final themeStr = prefs.getString(AppState._keyThemeMode) ?? 'system';
    _state._themeMode = _parseThemeMode(themeStr);

    _state._syncServerUrl = prefs.getString(AppState._keySyncServerUrl) ?? '';
    _state._syncUserId = prefs.getString(AppState._keySyncUserId) ?? 'user-1';
    _state._lastSyncedTime = prefs.getInt(AppState._keyLastSyncedTime);
    _state._syncEnabled = prefs.getBool(AppState._keySyncEnabled) ?? false;
    _state._notificationsEnabled =
        prefs.getBool(AppState._keyNotificationsEnabled) ?? true;

    await _state.loadAISettings();
    notifyListeners();
  }

  Future<void> saveSettings({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _state._calorieGoal = calories;
    _state._proteinGoal = protein;
    _state._carbsGoal = carbs;
    _state._fatGoal = fat;

    await prefs.setInt(AppState._keyCalorieGoal, _state._calorieGoal);
    await prefs.setInt(AppState._keyProteinGoal, _state._proteinGoal);
    await prefs.setInt(AppState._keyCarbsGoal, _state._carbsGoal);
    await prefs.setInt(AppState._keyFatGoal, _state._fatGoal);

    notifyListeners();
  }

  Future<void> setHistoryFilter(String filter) async {
    _state._historyFilter = filter;
    await _state.loadFirstPageHistory();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppState._keyHistoryFilter, filter);
  }

  Future<void> setHistoryTypeFilter(String typeFilter) async {
    _state._historyTypeFilter = typeFilter;
    await _state.loadFirstPageHistory();
    notifyListeners();
  }

  Future<void> setHistoryCustomDates(DateTime? start, DateTime? end) async {
    _state._historyCustomStartDate = start;
    _state._historyCustomEndDate = end;
    await _state.loadFirstPageHistory();
  }

  Future<void> setLocale(String code) async {
    _state._appLocale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppState._keyLocale, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _state._themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppState._keyThemeMode, _themeModeString(mode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _state._notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppState._keyNotificationsEnabled, enabled);
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

  Future<File> exportDatabase({required String destPath}) =>
      _state._dbHelper.exportDatabase(destPath: destPath);

  Future<Uint8List> getDatabaseBytes() async {
    final String path = await _state._dbHelper.databasePath;
    return await File(path).readAsBytes();
  }

  Future<void> restoreDatabase(String backupPath) async {
    await _state._dbHelper.restoreDatabase(backupPath: backupPath);
    await _state.loadMeals();
  }

  Future<String> exportSettingsToJson() async {
    final Map<String, dynamic> exportMap = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': {
        'calorieGoal': _state._calorieGoal,
        'proteinGoal': _state._proteinGoal,
        'carbsGoal': _state._carbsGoal,
        'fatGoal': _state._fatGoal,
        'historyFilter': _state._historyFilter,
        'appLocale': _state._appLocale,
        'themeMode': _themeModeString(_state._themeMode),
        'syncServerUrl': _state._syncServerUrl,
        'syncUserId': _state._syncUserId,
        'syncEnabled': _state._syncEnabled,
        'notificationsEnabled': _state._notificationsEnabled,
        'aiProvider': _state._aiProvider,
        'aiModel': _state._aiModel,
        'aiCustomUrl': _state._aiCustomUrl,
        'aiReasoningEffort': _state._aiReasoningEffort,
        'aiProviderModels': _state._aiProviderModels,
        'aiProviderCustomUrls': _state._aiProviderCustomUrls,
        'aiProviderReasoningEfforts': _state._aiProviderReasoningEfforts,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  Future<void> importSettingsFromJson(String jsonContent) async {
    _state._isLoading = true;
    notifyListeners();

    try {
      final decoded = json.decode(jsonContent);
      if (decoded is! Map<String, dynamic> ||
          !decoded.containsKey('settings')) {
        throw const FormatException('Invalid settings JSON format');
      }

      final settings = decoded['settings'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      if (settings.containsKey('calorieGoal')) {
        _state._calorieGoal =
            settings['calorieGoal'] as int? ?? AppConstants.defaultCalorieGoal;
        await prefs.setInt(AppState._keyCalorieGoal, _state._calorieGoal);
      }
      if (settings.containsKey('proteinGoal')) {
        _state._proteinGoal =
            settings['proteinGoal'] as int? ?? AppConstants.defaultProteinGoal;
        await prefs.setInt(AppState._keyProteinGoal, _state._proteinGoal);
      }
      if (settings.containsKey('carbsGoal')) {
        _state._carbsGoal =
            settings['carbsGoal'] as int? ?? AppConstants.defaultCarbsGoal;
        await prefs.setInt(AppState._keyCarbsGoal, _state._carbsGoal);
      }
      if (settings.containsKey('fatGoal')) {
        _state._fatGoal =
            settings['fatGoal'] as int? ?? AppConstants.defaultFatGoal;
        await prefs.setInt(AppState._keyFatGoal, _state._fatGoal);
      }
      if (settings.containsKey('historyFilter')) {
        _state._historyFilter = settings['historyFilter'] as String? ?? 'all';
        await prefs.setString(
          AppState._keyHistoryFilter,
          _state._historyFilter,
        );
      }
      if (settings.containsKey('appLocale')) {
        _state._appLocale = settings['appLocale'] as String? ?? 'en';
        await prefs.setString(AppState._keyLocale, _state._appLocale);
      }
      if (settings.containsKey('themeMode')) {
        final themeStr = settings['themeMode'] as String? ?? 'system';
        _state._themeMode = _parseThemeMode(themeStr);
        await prefs.setString(AppState._keyThemeMode, themeStr);
      }
      if (settings.containsKey('syncServerUrl')) {
        _state._syncServerUrl = settings['syncServerUrl'] as String? ?? '';
        await prefs.setString(
          AppState._keySyncServerUrl,
          _state._syncServerUrl,
        );
      }
      if (settings.containsKey('syncUserId')) {
        _state._syncUserId = settings['syncUserId'] as String? ?? 'user-1';
        await prefs.setString(AppState._keySyncUserId, _state._syncUserId);
      }
      if (settings.containsKey('syncEnabled')) {
        _state._syncEnabled = settings['syncEnabled'] as bool? ?? false;
        await prefs.setBool(AppState._keySyncEnabled, _state._syncEnabled);
      }
      if (settings.containsKey('notificationsEnabled')) {
        _state._notificationsEnabled =
            settings['notificationsEnabled'] as bool? ?? true;
        await prefs.setBool(
          AppState._keyNotificationsEnabled,
          _state._notificationsEnabled,
        );
      }
      if (settings.containsKey('aiProvider')) {
        _state._aiProvider =
            settings['aiProvider'] as String? ??
            AIServiceConfig.defaultProvider;
        await prefs.setString(AppState._keyAiProvider, _state._aiProvider);
      }
      if (settings.containsKey('aiModel')) {
        _state._aiModel =
            settings['aiModel'] as String? ??
            AIServiceConfig.getDefaultModelForProvider(_state._aiProvider);
        await prefs.setString(AppState._keyAiModel, _state._aiModel);
        final String pKey = _state._aiProvider.trim().toLowerCase();
        await prefs.setString('ai_model_$pKey', _state._aiModel);
      }
      if (settings.containsKey('aiCustomUrl')) {
        _state._aiCustomUrl = settings['aiCustomUrl'] as String? ?? '';
        await prefs.setString(AppState._keyAiCustomUrl, _state._aiCustomUrl);
        final String pKey = _state._aiProvider.trim().toLowerCase();
        await prefs.setString('ai_custom_url_$pKey', _state._aiCustomUrl);
      }
      if (settings.containsKey('aiReasoningEffort')) {
        _state._aiReasoningEffort =
            settings['aiReasoningEffort'] as String? ?? 'none';
        await prefs.setString(
          AppState._keyAiReasoningEffort,
          _state._aiReasoningEffort,
        );
        final String pKey = _state._aiProvider.trim().toLowerCase();
        await prefs.setString(
          'ai_reasoning_effort_$pKey',
          _state._aiReasoningEffort,
        );
      }

      // Import provider-specific maps if present
      if (settings.containsKey('aiProviderModels')) {
        final Map<String, dynamic> models =
            settings['aiProviderModels'] as Map<String, dynamic>? ?? {};
        for (final entry in models.entries) {
          _state._aiProviderModels[entry.key] = entry.value.toString();
          await prefs.setString(
            'ai_model_${entry.key}',
            entry.value.toString(),
          );
        }
      }
      if (settings.containsKey('aiProviderCustomUrls')) {
        final Map<String, dynamic> urls =
            settings['aiProviderCustomUrls'] as Map<String, dynamic>? ?? {};
        for (final entry in urls.entries) {
          _state._aiProviderCustomUrls[entry.key] = entry.value.toString();
          await prefs.setString(
            'ai_custom_url_${entry.key}',
            entry.value.toString(),
          );
        }
      }
      if (settings.containsKey('aiProviderReasoningEfforts')) {
        final Map<String, dynamic> efforts =
            settings['aiProviderReasoningEfforts'] as Map<String, dynamic>? ??
            {};
        for (final entry in efforts.entries) {
          _state._aiProviderReasoningEfforts[entry.key] = entry.value
              .toString();
          await prefs.setString(
            'ai_reasoning_effort_${entry.key}',
            entry.value.toString(),
          );
        }
      }

      await _state.loadAISettings();

      notifyListeners();
    } finally {
      _state._isLoading = false;
      notifyListeners();
    }
  }
}
