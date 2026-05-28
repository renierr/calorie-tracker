part of 'ai_service.dart';

class GeminiService implements AIService {
  @override
  Future<AIAnalysisResult> performAIAnalysis({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
    required String languageCode,
    required String model,
    String? customUrl,
  }) async {
    final String targetLanguage = languageCode == 'de' ? 'German' : 'English';

    final systemInstruction =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals. '
        'You MUST write all food description names and explanation notes in $targetLanguage.';

    final prompt =
        'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations. '
        'You MUST provide the response text fields (foodName and notes) in $targetLanguage.';

    final responseSchema = Schema.object(
      properties: {
        'foodName': Schema.string(
          description: 'Brief description of the meal in $targetLanguage',
        ),
        'calories': Schema.integer(description: 'Estimated energy in kcal'),
        'protein': Schema.integer(
          description: 'Estimated protein weight in grams',
        ),
        'carbs': Schema.integer(
          description: 'Estimated carbohydrates weight in grams',
        ),
        'fat': Schema.integer(description: 'Estimated lipids weight in grams'),
        'confidence': Schema.integer(
          description: 'Estimation confidence rating from 1 to 100',
        ),
        'notes': Schema.string(
          description:
              'Breakdown explanation of food portions or components detected in $targetLanguage',
        ),
      },
      requiredProperties: [
        'foodName',
        'calories',
        'protein',
        'carbs',
        'fat',
        'confidence',
        'notes',
      ],
    );

    final generativeModel = GenerativeModel(
      model: model.isNotEmpty ? model : AIServiceConfig.defaultModel,
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      ),
    );

    final response = await generativeModel.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)]),
    ]);

    final responseText = response.text;
    if (responseText == null) {
      throw Exception('Received empty response from Gemini API.');
    }

    final decoded = json.decode(responseText) as Map<String, dynamic>;
    return AIAnalysisResult.fromJson(decoded);
  }

  @override
  Future<void> validateCredentials({
    required String apiKey,
    required String model,
    String? customUrl,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is empty.');
    }
    final generativeModel = GenerativeModel(
      model: model.isNotEmpty ? model : AIServiceConfig.defaultModel,
      apiKey: apiKey,
    );
    // Execute a cheap operation like counting tokens to verify key
    await generativeModel.countTokens([Content.text('Ping')]);
  }
}
