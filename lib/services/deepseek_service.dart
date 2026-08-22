import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'ai_analysis_result.dart';
import 'ai_base_service.dart';
import 'ai_service_config.dart';

class DeepSeekService extends BaseAIService {
  @override
  String get defaultModel =>
      AIServiceConfig.getDefaultModelForProvider('deepseek');

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
      requestPayload['reasoning_effort'] = reasoningEffort;
    }

    final String url = (customUrl != null && customUrl.trim().isNotEmpty)
        ? (customUrl.trim().endsWith('/chat/completions')
              ? customUrl.trim()
              : '${customUrl.trim().replaceAll(RegExp(r'/+$'), '')}/chat/completions')
        : 'https://api.deepseek.com/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'DeepSeek API Error: status code ${response.statusCode}, body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('Empty choices returned from DeepSeek API.');
    }

    final messageContent = choices[0]['message']['content'] as String?;
    if (messageContent == null || messageContent.trim().isEmpty) {
      throw Exception('Received empty message content from DeepSeek.');
    }

    String jsonString = messageContent.trim();
    if (jsonString.startsWith('```json')) {
      jsonString = jsonString.substring(7);
    }
    if (jsonString.endsWith('```')) {
      jsonString = jsonString.substring(0, jsonString.length - 3);
    }
    jsonString = jsonString.trim();

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
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
    final String url = (customUrl != null && customUrl.trim().isNotEmpty)
        ? (customUrl.trim().endsWith('/chat/completions')
              ? customUrl.trim()
              : '${customUrl.trim().replaceAll(RegExp(r'/+$'), '')}/chat/completions')
        : 'https://api.deepseek.com/chat/completions';

    final response = await http
        .post(
          Uri.parse(url),
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
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timed out after 10 seconds.');
          },
        );

    if (response.statusCode != 200) {
      throw Exception(
        'DeepSeek API Validation Failed: status code ${response.statusCode}, body: ${response.body}',
      );
    }
  }
}
