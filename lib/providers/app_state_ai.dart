part of 'app_state.dart';

mixin _AiState on ChangeNotifier {
  AppState get _state => this as AppState;

  // Getters
  String get aiProvider => _state._aiProvider;
  String get aiModel => _state._aiModel;
  String get aiApiKey => _state._aiApiKey;
  String get aiCustomUrl => _state._aiCustomUrl;

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

    // Fallback/Migration for legacy Gemini key
    if (_state._aiApiKey.isEmpty && _state._geminiApiKey.isNotEmpty) {
      _state._aiApiKey = _state._geminiApiKey;
    }
    notifyListeners();
  }

  Future<void> saveAISettings({
    required String provider,
    required String model,
    required String apiKey,
    required String customUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _state._aiProvider = provider.trim();
    _state._aiModel = model.trim();
    _state._aiApiKey = apiKey.trim();
    _state._aiCustomUrl = customUrl.trim();

    await prefs.setString(AppState._keyAiProvider, _state._aiProvider);
    await prefs.setString(AppState._keyAiModel, _state._aiModel);
    await prefs.setString(AppState._keyAiApiKey, _state._aiApiKey);
    await prefs.setString(AppState._keyAiCustomUrl, _state._aiCustomUrl);

    // Mirror to legacy gemini key to avoid breaking other legacy components
    if (_state._aiProvider == 'gemini') {
      _state._geminiApiKey = _state._aiApiKey;
      await prefs.setString(AppState._keyGeminiApiKey, _state._geminiApiKey);
    }

    notifyListeners();
  }

  Future<AIAnalysisResult> performAIAnalysis({
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
  }) async {
    final provider = _state._aiProvider;
    final model = _state._aiModel;
    String apiKey = _state._aiApiKey.trim();
    if (apiKey.isEmpty && provider == 'gemini') {
      apiKey = _state._geminiApiKey.trim();
    }

    final service = AIServiceFactory.getService(provider);
    return await service.performAIAnalysis(
      apiKey: apiKey,
      imageBytes: imageBytes,
      mimeType: mimeType,
      userHint: userHint,
      languageCode: _state._appLocale,
      model: model,
      customUrl: _state._aiCustomUrl,
    );
  }

  Future<void> validateAISettings({
    required String provider,
    required String model,
    required String apiKey,
    required String customUrl,
  }) async {
    final service = AIServiceFactory.getService(provider);
    await service.validateCredentials(
      apiKey: apiKey.trim(),
      model: model.trim(),
      customUrl: customUrl.trim(),
    );
  }
}
