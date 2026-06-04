import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_analysis_result.dart';
import 'ai_base_service.dart';
import 'ai_service_config.dart';

class GeminiService extends BaseAIService {
  @override
  String get defaultModel =>
      AIServiceConfig.getDefaultModelForProvider('gemini');

  @override
  Future<AIAnalysisResult> performAIAnalysis({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
    required String languageCode,
    required String model,
    required String reasoningEffort,
    String? customUrl,
  }) async {
    final String targetLanguage = getTargetLanguage(languageCode);

    final systemInstruction = getSystemPrompt(targetLanguage: targetLanguage);

    final prompt = getUserPrompt(
      targetLanguage: targetLanguage,
      userHint: userHint,
      includeGeminiLanguageFieldsInstruction: true,
    );

    final responseSchema = Schema.object(
      properties: {
        'foodName': Schema.string(
          description:
              'Clean, brief title of the primary dish/meal in $targetLanguage. Do not include calorie counts or extra descriptions here.',
        ),
        'calories': Schema.integer(
          description: 'Total estimated energy in kcal',
        ),
        'protein': Schema.integer(
          description: 'Total estimated protein weight in grams',
        ),
        'carbs': Schema.integer(
          description: 'Total estimated carbohydrates weight in grams',
        ),
        'fat': Schema.integer(
          description: 'Total estimated lipids weight in grams',
        ),
        'confidence': Schema.integer(
          description:
              'Estimation confidence rating from 1 to 100 based on image clarity',
        ),
        'notes': Schema.string(
          description:
              'A concise breakdown in $targetLanguage written as a single, natural, conversational paragraph. '
              'Do NOT use dashes, bullet points, or robotic prefixes like "Identified:" or "Assumptions:". '
              'Smoothly blend the identified ingredients and weights into flowing sentences, '
              'explicitly mention what you assumed for hidden oils/fats, and end with a 1-sentence takeaway.',
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
      model: getActiveModel(model),
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      ),
    );

    final response = await generativeModel.generateContent([
      if (imageBytes.isNotEmpty)
        Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)])
      else
        Content.text(prompt),
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
    required String reasoningEffort,
    String? customUrl,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is empty.');
    }
    final generativeModel = GenerativeModel(
      model: getActiveModel(model),
      apiKey: apiKey,
    );
    await generativeModel.countTokens([Content.text('Ping')]);
  }
}
