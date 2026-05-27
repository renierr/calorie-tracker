import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

part 'gemini_service.dart';
part 'openai_service.dart';
part 'anthropic_service.dart';
part 'custom_ai_service.dart';

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

class AIServiceFactory {
  static AIService getService(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return OpenAIService();
      case 'anthropic':
        return AnthropicService();
      case 'custom':
        return CustomAIService();
      case 'gemini':
      default:
        return GeminiService();
    }
  }
}
