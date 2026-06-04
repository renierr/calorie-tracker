import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'ai_analysis_result.dart';
import 'ai_base_service.dart';
import 'ai_service_config.dart';

class OpenAIService extends BaseAIService {
  @override
  String get defaultModel =>
      AIServiceConfig.getDefaultModelForProvider('openai');

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
    final String base64Image = imageBytes.isNotEmpty
        ? base64Encode(imageBytes)
        : '';

    final String activeModel = getActiveModel(model);

    final systemPrompt = getSystemPrompt(
      targetLanguage: targetLanguage,
      includeJsonFormatInstruction: true,
    );

    final userPrompt = getUserPrompt(
      targetLanguage: targetLanguage,
      userHint: userHint,
      includeOnlyJsonInstruction: true,
    );

    final Map<String, dynamic> requestPayload = {
      'model': activeModel,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
            if (imageBytes.isNotEmpty)
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
              },
          ],
        },
      ],
    };

    if (reasoningEffort != 'none') {
      if (activeModel.startsWith('o1') || activeModel.startsWith('o3')) {
        requestPayload['reasoning_effort'] = reasoningEffort;
      }
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI API Error: status code ${response.statusCode}, body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('Empty choices returned from OpenAI API.');
    }

    final messageContent = choices[0]['message']['content'] as String?;
    if (messageContent == null || messageContent.trim().isEmpty) {
      throw Exception('Received empty message content from OpenAI.');
    }

    final decoded = jsonDecode(messageContent) as Map<String, dynamic>;
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
    final activeModel = getActiveModel(model);
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': activeModel,
        'messages': [
          {'role': 'user', 'content': 'Ping'},
        ],
        'max_tokens': 1,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'OpenAI API Validation Failed: status code ${response.statusCode}, body: ${response.body}',
      );
    }
  }
}
