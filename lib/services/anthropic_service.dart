import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'ai_analysis_result.dart';
import 'ai_base_service.dart';
import 'ai_service_config.dart';

class AnthropicService extends BaseAIService {
  @override
  String get defaultModel =>
      AIServiceConfig.getDefaultModelForProvider('anthropic');

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
      includeAnthropicRawBlockInstruction: true,
    );

    final userPrompt = getUserPrompt(
      targetLanguage: targetLanguage,
      userHint: userHint,
      includeOnlyJsonInstruction: true,
    );

    int maxTokens = 1500;
    Map<String, dynamic>? thinkingBlock;

    final bool isThinkingModel =
        activeModel.contains('3-7') ||
        !AIServiceConfig.providerModels['anthropic']!.contains(activeModel);

    if (isThinkingModel && reasoningEffort != 'none') {
      int budgetTokens = 2048;
      if (reasoningEffort == 'low') {
        budgetTokens = 1024;
      } else if (reasoningEffort == 'high') {
        budgetTokens = 4096;
      }
      thinkingBlock = {'type': 'enabled', 'budget_tokens': budgetTokens};
      maxTokens = budgetTokens + 1500;
    }

    final Map<String, dynamic> requestPayload = {
      'model': activeModel,
      'max_tokens': maxTokens,
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': [
            if (imageBytes.isNotEmpty)
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mimeType,
                  'data': base64Image,
                },
              },
            {'type': 'text', 'text': userPrompt},
          ],
        },
      ],
    };

    if (thinkingBlock != null) {
      requestPayload['thinking'] = thinkingBlock;
    }

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Anthropic API Error: status code ${response.statusCode}, body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    if (content.isEmpty) {
      throw Exception('Empty content returned from Anthropic API.');
    }

    String? messageText;
    for (final block in content) {
      if (block is Map<String, dynamic> && block['type'] == 'text') {
        messageText = block['text'] as String?;
        break;
      }
    }

    if (messageText == null || messageText.trim().isEmpty) {
      throw Exception('Received empty text content from Anthropic.');
    }

    String jsonString = messageText.trim();
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
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': activeModel,
        'max_tokens': 1,
        'messages': [
          {'role': 'user', 'content': 'Ping'},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Anthropic API Validation Failed: status code ${response.statusCode}, body: ${response.body}',
      );
    }
  }
}
