part of 'app_state.dart';

mixin _AiState on ChangeNotifier {
  AppState get _state => this as AppState;

  // Getters
  String get aiProvider => _state._aiProvider;
  String get aiModel => _state._aiModel;
  String get aiApiKey => _state._aiApiKey;
  String get aiCustomUrl => _state._aiCustomUrl;
  String get aiReasoningEffort => _state._aiReasoningEffort;
  String get aiFallbackProvider => _state._aiFallbackProvider;

  String get activeFallbackProvider {
    final fallback = _state._aiFallbackProvider;
    if (fallback == 'none') return 'none';
    if (isProviderConfigured(fallback)) return fallback;
    return 'none';
  }

  String getFallbackForProvider(String provider) {
    final pKey = provider.toLowerCase();
    return _state._aiProviderFallbacks[pKey] ?? 'none';
  }

  bool isProviderConfigured(String provider) {
    final pKey = provider.toLowerCase();
    if (pKey == 'custom') {
      return getCustomUrlForProvider(pKey).isNotEmpty;
    }
    final key = getApiKeyForProvider(pKey);
    return key.trim().isNotEmpty;
  }

  String getProviderDisplayName(String provider) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return 'Google Gemini';
      case 'openai':
        return 'OpenAI';
      case 'anthropic':
        return 'Anthropic Claude';
      case 'grok':
        return 'xAI Grok';
      case 'custom':
        return 'Custom Endpoint';
      default:
        return provider;
    }
  }

  // Provider-specific getters
  String getModelForProvider(String provider) {
    final pKey = provider.toLowerCase();
    return _state._aiProviderModels[pKey] ??
        AIServiceConfig.getDefaultModelForProvider(pKey);
  }

  String getApiKeyForProvider(String provider) {
    final pKey = provider.toLowerCase();
    return _state._aiProviderApiKeys[pKey] ?? '';
  }

  String getCustomUrlForProvider(String provider) {
    final pKey = provider.toLowerCase();
    return _state._aiProviderCustomUrls[pKey] ?? '';
  }

  String getReasoningEffortForProvider(String provider) {
    final pKey = provider.toLowerCase();
    return _state._aiProviderReasoningEfforts[pKey] ?? 'none';
  }

  Future<void> loadAISettings() async {
    final prefs = await SharedPreferences.getInstance();
    _state._aiProvider =
        prefs.getString(AppState._keyAiProvider) ??
        AIServiceConfig.defaultProvider;
    final savedModel = prefs.getString(AppState._keyAiModel);
    if (savedModel != null && savedModel.isNotEmpty) {
      _state._aiModel = savedModel;
    } else {
      _state._aiModel = AIServiceConfig.getDefaultModelForProvider(
        _state._aiProvider,
      );
    }
    _state._aiApiKey = prefs.getString(AppState._keyAiApiKey) ?? '';
    _state._aiCustomUrl = prefs.getString(AppState._keyAiCustomUrl) ?? '';
    _state._aiReasoningEffort =
        prefs.getString(AppState._keyAiReasoningEffort) ?? 'none';
    _state._aiFallbackProvider =
        prefs.getString(AppState._keyAiFallbackProvider) ?? 'none';

    // Fallback/Migration for legacy Gemini key
    final legacyGeminiKey = prefs.getString(AppState._keyGeminiApiKey);
    if (_state._aiApiKey.isEmpty &&
        legacyGeminiKey != null &&
        legacyGeminiKey.isNotEmpty) {
      _state._aiApiKey = legacyGeminiKey;
      await prefs.setString(AppState._keyAiApiKey, _state._aiApiKey);
    }

    // Load provider-specific settings
    final providers = ['gemini', 'openai', 'anthropic', 'grok', 'custom'];
    for (final p in providers) {
      final pKey = p.toLowerCase();
      // Model:
      final pModel = prefs.getString('ai_model_$pKey');
      if (pModel != null && pModel.isNotEmpty) {
        _state._aiProviderModels[pKey] = pModel;
      } else {
        if (_state._aiProvider.toLowerCase() == pKey) {
          _state._aiProviderModels[pKey] = _state._aiModel;
        } else {
          _state._aiProviderModels[pKey] =
              AIServiceConfig.getDefaultModelForProvider(pKey);
        }
      }

      // API Key:
      final pApiKey = prefs.getString('ai_api_key_$pKey');
      if (pApiKey != null) {
        _state._aiProviderApiKeys[pKey] = pApiKey;
      } else {
        if (_state._aiProvider.toLowerCase() == pKey) {
          _state._aiProviderApiKeys[pKey] = _state._aiApiKey;
        } else if (pKey == 'gemini') {
          _state._aiProviderApiKeys[pKey] = legacyGeminiKey ?? '';
        } else {
          _state._aiProviderApiKeys[pKey] = '';
        }
      }

      // Custom URL:
      final pCustomUrl = prefs.getString('ai_custom_url_$pKey');
      if (pCustomUrl != null) {
        _state._aiProviderCustomUrls[pKey] = pCustomUrl;
      } else {
        if (_state._aiProvider.toLowerCase() == pKey) {
          _state._aiProviderCustomUrls[pKey] = _state._aiCustomUrl;
        } else {
          _state._aiProviderCustomUrls[pKey] = '';
        }
      }

      // Reasoning Effort:
      final pReasoningEffort = prefs.getString('ai_reasoning_effort_$pKey');
      if (pReasoningEffort != null) {
        _state._aiProviderReasoningEfforts[pKey] = pReasoningEffort;
      } else {
        if (_state._aiProvider.toLowerCase() == pKey) {
          _state._aiProviderReasoningEfforts[pKey] = _state._aiReasoningEffort;
        } else {
          _state._aiProviderReasoningEfforts[pKey] = 'none';
        }
      }

      // Fallback:
      final pFallback = prefs.getString('ai_fallback_$pKey');
      _state._aiProviderFallbacks[pKey] = pFallback ?? 'none';
    }
    notifyListeners();
  }

  Future<void> saveAISettings({
    required String provider,
    required String model,
    required String apiKey,
    required String customUrl,
    required String reasoningEffort,
    String fallbackProvider = 'none',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _state._aiProvider = provider.trim();
    _state._aiModel = model.trim();
    _state._aiApiKey = apiKey.trim();
    _state._aiCustomUrl = customUrl.trim();
    _state._aiReasoningEffort = reasoningEffort.trim();
    _state._aiFallbackProvider = fallbackProvider.trim();

    await prefs.setString(AppState._keyAiProvider, _state._aiProvider);
    await prefs.setString(AppState._keyAiModel, _state._aiModel);
    await prefs.setString(AppState._keyAiApiKey, _state._aiApiKey);
    await prefs.setString(AppState._keyAiCustomUrl, _state._aiCustomUrl);
    await prefs.setString(
      AppState._keyAiReasoningEffort,
      _state._aiReasoningEffort,
    );
    await prefs.setString(
      AppState._keyAiFallbackProvider,
      _state._aiFallbackProvider,
    );

    // Save provider-specific settings too
    final String pKey = provider.trim().toLowerCase();
    _state._aiProviderModels[pKey] = model.trim();
    _state._aiProviderApiKeys[pKey] = apiKey.trim();
    _state._aiProviderCustomUrls[pKey] = customUrl.trim();
    _state._aiProviderReasoningEfforts[pKey] = reasoningEffort.trim();
    _state._aiProviderFallbacks[pKey] = fallbackProvider.trim();

    await prefs.setString('ai_model_$pKey', model.trim());
    await prefs.setString('ai_api_key_$pKey', apiKey.trim());
    await prefs.setString('ai_custom_url_$pKey', customUrl.trim());
    await prefs.setString('ai_reasoning_effort_$pKey', reasoningEffort.trim());
    await prefs.setString('ai_fallback_$pKey', fallbackProvider.trim());

    notifyListeners();
  }

  Future<AIAnalysisResult> performAIAnalysis({
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
    String? overrideProvider,
  }) async {
    final provider = overrideProvider ?? _state._aiProvider;
    final model = overrideProvider != null
        ? getModelForProvider(overrideProvider)
        : _state._aiModel;
    final apiKey = overrideProvider != null
        ? getApiKeyForProvider(overrideProvider).trim()
        : _state._aiApiKey.trim();
    final customUrl = overrideProvider != null
        ? getCustomUrlForProvider(overrideProvider).trim()
        : _state._aiCustomUrl.trim();
    final reasoningEffort = overrideProvider != null
        ? getReasoningEffortForProvider(overrideProvider).trim()
        : _state._aiReasoningEffort.trim();

    final service = AIServiceFactory.getService(provider);
    return await service.performAIAnalysis(
      apiKey: apiKey,
      imageBytes: imageBytes,
      mimeType: mimeType,
      userHint: userHint,
      languageCode: _state._appLocale,
      model: model,
      customUrl: customUrl,
      reasoningEffort: reasoningEffort,
    );
  }

  Future<void> validateAISettings({
    required String provider,
    required String model,
    required String apiKey,
    required String customUrl,
    required String reasoningEffort,
  }) async {
    final service = AIServiceFactory.getService(provider);
    await service.validateCredentials(
      apiKey: apiKey.trim(),
      model: model.trim(),
      customUrl: customUrl.trim(),
      reasoningEffort: reasoningEffort.trim(),
    );
  }

  // Getters for Scan Page State
  Uint8List? get scanImageBytes => _state._scanImageBytes;
  String get scanMimeType => _state._scanMimeType;
  String get scanUserHint => _state._scanUserHint;
  bool get scanShowForm => _state._scanShowForm;
  bool get scanIsScanning => _state._scanIsScanning;
  AIAnalysisResult? get scanResult => _state._scanResult;
  bool get scanIsPickedImage => _state._scanIsPickedImage;

  // Getters for Scan Verification Form Draft Values
  String get scanFoodName => _state._scanFoodName;
  String get scanCalories => _state._scanCalories;
  String get scanProtein => _state._scanProtein;
  String get scanCarbs => _state._scanCarbs;
  String get scanFat => _state._scanFat;
  String get scanNotes => _state._scanNotes;
  String get scanWeight => _state._scanWeight;
  DateTime get scanMealDate => _state._scanMealDate;

  // Setters/Helpers
  void setScanImage(Uint8List? bytes, String mimeType) {
    _state._scanImageBytes = bytes;
    _state._scanMimeType = mimeType;
    _state._scanIsPickedImage = bytes != null;
    notifyListeners();
  }

  void updateScanUserHint(String hint) {
    _state._scanUserHint = hint;
  }

  void setScanShowForm(bool show) {
    _state._scanShowForm = show;
    notifyListeners();
  }

  void setScanIsScanning(bool scanning) {
    _state._scanIsScanning = scanning;
    notifyListeners();
  }

  void setScanResult(AIAnalysisResult? result) {
    _state._scanResult = result;
    if (result != null) {
      _state._scanFoodName = result.foodName;
      _state._scanCalories = result.calories.toString();
      _state._scanProtein = result.protein.toString();
      _state._scanCarbs = result.carbs.toString();
      _state._scanFat = result.fat.toString();
      _state._scanNotes = result.notes;
    }
    _state._scanIsAiFlow = true;
    _state._scanShowForm = true;
    _state._scanIsScanning = false;
    notifyListeners();
  }

  void updateScanDraftFields({
    String? foodName,
    String? calories,
    String? protein,
    String? carbs,
    String? fat,
    String? notes,
    String? weight,
    DateTime? mealDate,
  }) {
    if (foodName != null) _state._scanFoodName = foodName;
    if (calories != null) _state._scanCalories = calories;
    if (protein != null) _state._scanProtein = protein;
    if (carbs != null) _state._scanCarbs = carbs;
    if (fat != null) _state._scanFat = fat;
    if (notes != null) _state._scanNotes = notes;
    if (weight != null) _state._scanWeight = weight;
    if (mealDate != null) _state._scanMealDate = mealDate;
  }

  void setScanStateFromTemplate(Meal template) {
    _state._scanImageBytes = template.imageBytes;
    _state._scanMimeType = 'image/jpeg';
    _state._scanIsPickedImage = false;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = template.isActivity;
    _state._scanResult = AIAnalysisResult(
      foodName: template.foodName,
      calories: template.calories,
      protein: template.protein,
      carbs: template.carbs,
      fat: template.fat,
      confidence: template.confidence,
      notes: template.notes ?? '',
    );
    _state._scanFoodName = template.foodName;
    _state._scanCalories = template.calories.toString();
    _state._scanProtein = template.protein.toString();
    _state._scanCarbs = template.carbs.toString();
    _state._scanFat = template.fat.toString();
    _state._scanNotes = template.notes ?? '';
    _state._scanWeight = template.weightKg?.toString() ?? '';
    _state._scanMealDate = DateTime.now();
    _state._scanShowForm = true;
    _state._scanIsScanning = false;
    notifyListeners();
  }

  void openManualFormWithPhoto() {
    _state._scanShowForm = true;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = false;
    _state._scanResult = null;
    _state._scanFoodName = 'New Meal';
    _state._scanCalories = '0';
    _state._scanProtein = '0';
    _state._scanCarbs = '0';
    _state._scanFat = '0';
    _state._scanNotes = '';
    _state._scanWeight = '';
    _state._scanMealDate = DateTime.now();
    notifyListeners();
  }

  void logManuallyWithoutPhoto() {
    _state._scanShowForm = true;
    _state._scanImageBytes = null;
    _state._scanIsPickedImage = false;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = false;
    _state._scanResult = null;
    _state._scanFoodName = 'New Meal';
    _state._scanCalories = '0';
    _state._scanProtein = '0';
    _state._scanCarbs = '0';
    _state._scanFat = '0';
    _state._scanNotes = '';
    _state._scanWeight = '';
    _state._scanMealDate = DateTime.now();
    notifyListeners();
  }

  void logActivityManually({bool hasPhoto = false, Uint8List? imageBytes}) {
    _state._scanShowForm = true;
    _state._scanImageBytes = imageBytes;
    _state._scanIsPickedImage = imageBytes != null;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = true;
    _state._scanResult = null;
    _state._scanFoodName = 'New Activity';
    _state._scanCalories = '0';
    _state._scanProtein = '0';
    _state._scanCarbs = '0';
    _state._scanFat = '0';
    _state._scanNotes = '';
    _state._scanWeight = '';
    _state._scanMealDate = DateTime.now();
    notifyListeners();
  }

  void discardForm() {
    _state._scanShowForm = false;
    if (_state._scanIsAiFlow) {
      if (!_state._scanIsPickedImage) {
        _state._scanImageBytes = null;
      }
    } else {
      _state._scanImageBytes = null;
      _state._scanIsPickedImage = false;
    }
    _state._scanResult = null;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = false;
    _state._scanFoodName = '';
    _state._scanCalories = '';
    _state._scanProtein = '';
    _state._scanCarbs = '';
    _state._scanFat = '';
    _state._scanNotes = '';
    _state._scanWeight = '';
    _state._scanMealDate = DateTime.now();
    notifyListeners();
  }

  void clearScanImage() {
    _state._scanImageBytes = null;
    _state._scanIsPickedImage = false;
    notifyListeners();
  }

  void clearScanState() {
    _state._scanImageBytes = null;
    _state._scanMimeType = 'image/jpeg';
    _state._scanUserHint = '';
    _state._scanShowForm = false;
    _state._scanIsScanning = false;
    _state._scanIsPickedImage = false;
    _state._scanIsAiFlow = false;
    _state._scanIsActivity = false;
    _state._scanResult = null;
    _state._scanFoodName = '';
    _state._scanCalories = '';
    _state._scanProtein = '';
    _state._scanCarbs = '';
    _state._scanFat = '';
    _state._scanNotes = '';
    _state._scanWeight = '';
    _state._scanMealDate = DateTime.now();
    notifyListeners();
  }

  Future<void> handleIncomingImageBytes(Uint8List rawBytes) async {
    final processedBytes = await compute(
      _resizeAndNormalizeImageStandalone,
      rawBytes,
    );
    setScanImage(processedBytes, 'image/jpeg');

    _state.selectTab(1);
    _state._scanShowForm = false;
    _state._scanResult = null;
    notifyListeners();
  }
}

// Top-level function — passable to compute() for background isolate
Uint8List _resizeAndNormalizeImageStandalone(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;

  img.Image resized = image;
  if (image.width > 800 || image.height > 800) {
    if (image.width > image.height) {
      resized = img.copyResize(image, width: 800);
    } else {
      resized = img.copyResize(image, height: 800);
    }
  }

  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}
