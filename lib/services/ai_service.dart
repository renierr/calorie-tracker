import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

part 'gemini_service.dart';
part 'openai_service.dart';
part 'anthropic_service.dart';
part 'custom_ai_service.dart';
part 'grok_service.dart';

class AIServiceConfig {
  static const Map<String, List<String>> providerModels = {
    'gemini': [
      'gemini-3.5-flash',
      'gemini-3.1-flash-lite',
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
      'gemini-2.5-pro',
    ],
    'openai': ['gpt-4o-mini', 'gpt-4o'],
    'anthropic': ['claude-3-5-sonnet-latest', 'claude-3-5-haiku-latest'],
    'grok': ['grok-4.3','grok-2-vision'],
  };

  static const String defaultProvider = 'gemini';
  static String get defaultModel => providerModels[defaultProvider]!.first;

  static String getDefaultModelForProvider(String provider) {
    final models = providerModels[provider.toLowerCase()];
    if (models != null && models.isNotEmpty) {
      return models.first;
    }
    return '';
  }
}

class AIAnalysisResult {
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int confidence;
  final String notes;

  AIAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.notes,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      foodName: json['foodName'] as String? ?? 'Meal',
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      confidence: json['confidence'] as int? ?? 85,
      notes: json['notes'] as String? ?? '',
    );
  }
}

abstract class AIService {
  Future<AIAnalysisResult> performAIAnalysis({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
    required String languageCode,
    required String model,
    String? customUrl,
  });

  Future<void> validateCredentials({
    required String apiKey,
    required String model,
    String? customUrl,
  });
}

abstract class BaseAIService implements AIService {
  String get defaultModel;

  String getActiveModel(String model) =>
      model.trim().isNotEmpty ? model.trim() : defaultModel;

  String getTargetLanguage(String languageCode) =>
      languageCode == 'de' ? 'German' : 'English';

  String getSystemPrompt({
    required String targetLanguage,
    bool includeJsonFormatInstruction = false,
    bool includeAnthropicRawBlockInstruction = false,
  }) {
    final base =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals. '
        'You MUST write all food description names and explanation notes in $targetLanguage.';
    if (!includeJsonFormatInstruction) {
      return base;
    }

    var instruction =
        "$base You MUST return a JSON object with the exact keys: "
        "'foodName' (string, brief description in $targetLanguage), "
        "'calories' (integer, estimated kcal), "
        "'protein' (integer, grams), "
        "'carbs' (integer, grams), "
        "'fat' (integer, grams), "
        "'confidence' (integer, 1-100), and "
        "'notes' (string, breakdown explanation in $targetLanguage).";
    if (includeAnthropicRawBlockInstruction) {
      instruction +=
          ' Respond ONLY with valid JSON inside a raw JSON block, do not include any other markdown formatting outside the JSON object.';
    }
    return instruction;
  }

  String getUserPrompt({
    required String targetLanguage,
    required String userHint,
    bool includeOnlyJsonInstruction = false,
    bool includeGeminiLanguageFieldsInstruction = false,
  }) {
    var prompt =
        'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations.';
    if (includeOnlyJsonInstruction) {
      prompt += ' Respond with ONLY the requested JSON object.';
    }
    if (includeGeminiLanguageFieldsInstruction) {
      prompt +=
          ' You MUST provide the response text fields (foodName and notes) in $targetLanguage.';
    }
    return prompt;
  }
}

class AIServiceFactory {
  static AIService getService(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return OpenAIService();
      case 'anthropic':
        return AnthropicService();
      case 'grok':
        return GrokService();
      case 'custom':
        return CustomAIService();
      case 'gemini':
      default:
        return GeminiService();
    }
  }
}
