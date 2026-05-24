import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

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

class GeminiService {
  static const String _modelName = 'gemini-2.5-flash';

  static Future<AIAnalysisResult> performAIAnalysis({
    required String apiKey,
    required Uint8List imageBytes,
    required String mimeType,
    required String userHint,
  }) async {
    final systemInstruction =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals.';

    final prompt = 'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations.';

    // Construct the structured JSON schema matching our model
    final responseSchema = Schema.object(
      properties: {
        'foodName': Schema.string(description: 'Brief description of the meal'),
        'calories': Schema.integer(description: 'Estimated energy in kcal'),
        'protein': Schema.integer(description: 'Estimated protein weight in grams'),
        'carbs': Schema.integer(description: 'Estimated carbohydrates weight in grams'),
        'fat': Schema.integer(description: 'Estimated lipids weight in grams'),
        'confidence': Schema.integer(description: 'Estimation confidence rating from 1 to 100'),
        'notes': Schema.string(
            description: 'Breakdown explanation of food portions or components detected'),
      },
      requiredProperties: ['foodName', 'calories', 'protein', 'carbs', 'fat', 'confidence', 'notes'],
    );

    final model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
      ),
    );

    final response = await model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ]),
    ]);

    final responseText = response.text;
    if (responseText == null) {
      throw Exception('Received empty response from Gemini API.');
    }

    final decoded = json.decode(responseText) as Map<String, dynamic>;
    return AIAnalysisResult.fromJson(decoded);
  }
}
