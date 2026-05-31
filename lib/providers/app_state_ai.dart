part of 'app_state.dart';

mixin _AiState on ChangeNotifier {
  AppState get _state => this as AppState;

  // Getters
  String get aiProvider => _state._aiProvider;
  String get aiModel => _state._aiModel;
  String get aiApiKey => _state._aiApiKey;
  String get aiCustomUrl => _state._aiCustomUrl;
  String get aiReasoningEffort => _state._aiReasoningEffort;

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

    // Fallback/Migration for legacy Gemini key
    final legacyGeminiKey = prefs.getString(AppState._keyGeminiApiKey);
    if (_state._aiApiKey.isEmpty &&
        legacyGeminiKey != null &&
        legacyGeminiKey.isNotEmpty) {
      _state._aiApiKey = legacyGeminiKey;
      await prefs.setString(AppState._keyAiApiKey, _state._aiApiKey);
    }
    notifyListeners();
  }

  Future<void> saveAISettings({
    required String provider,
    required String model,
    required String apiKey,
    required String customUrl,
    required String reasoningEffort,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _state._aiProvider = provider.trim();
    _state._aiModel = model.trim();
    _state._aiApiKey = apiKey.trim();
    _state._aiCustomUrl = customUrl.trim();
    _state._aiReasoningEffort = reasoningEffort.trim();

    await prefs.setString(AppState._keyAiProvider, _state._aiProvider);
    await prefs.setString(AppState._keyAiModel, _state._aiModel);
    await prefs.setString(AppState._keyAiApiKey, _state._aiApiKey);
    await prefs.setString(AppState._keyAiCustomUrl, _state._aiCustomUrl);
    await prefs.setString(
      AppState._keyAiReasoningEffort,
      _state._aiReasoningEffort,
    );

    notifyListeners();
  }

  Future<AIAnalysisResult> performAIAnalysis({
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
  }) async {
    final provider = _state._aiProvider;
    final model = _state._aiModel;
    final apiKey = _state._aiApiKey.trim();

    final service = AIServiceFactory.getService(provider);
    return await service.performAIAnalysis(
      apiKey: apiKey,
      imageBytes: imageBytes,
      mimeType: mimeType,
      userHint: userHint,
      languageCode: _state._appLocale,
      model: model,
      customUrl: _state._aiCustomUrl,
      reasoningEffort: _state._aiReasoningEffort,
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

  Uint8List _resizeAndNormalizeImage(Uint8List bytes) {
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

  Future<void> handleIncomingImageBytes(Uint8List rawBytes) async {
    final processedBytes = _resizeAndNormalizeImage(rawBytes);
    setScanImage(processedBytes, 'image/jpeg');

    _state.selectTab(1);
    _state._scanShowForm = false;
    _state._scanResult = null;
    notifyListeners();
  }
}
