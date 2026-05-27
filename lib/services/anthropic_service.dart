part of 'ai_service.dart';

class AnthropicService implements AIService {
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
    final String base64Image = base64Encode(imageBytes);

    final String activeModel = model.isNotEmpty
        ? model
        : 'claude-3-5-sonnet-latest';

    final systemPrompt =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals. '
        'You MUST return a JSON object with the exact keys: \'foodName\' (string, brief description in $targetLanguage), \'calories\' (integer, estimated kcal), \'protein\' (integer, grams), \'carbs\' (integer, grams), \'fat\' (integer, grams), \'confidence\' (integer, 1-100), and \'notes\' (string, breakdown explanation in $targetLanguage). '
        'You MUST write all food description names and explanation notes in $targetLanguage. '
        'Respond ONLY with valid JSON inside a raw JSON block, do not include any other markdown formatting outside the JSON object.';

    final userPrompt =
        'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations. Respond with ONLY the requested JSON object.';

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': activeModel,
        'max_tokens': 1500,
        'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': [
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
      }),
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

    final messageText = content[0]['text'] as String?;
    if (messageText == null || messageText.trim().isEmpty) {
      throw Exception('Received empty text content from Anthropic.');
    }

    // Attempt to extract JSON if Claude wraps it in backticks
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
    String? customUrl,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is empty.');
    }
    final activeModel = model.isNotEmpty ? model : 'claude-3-5-sonnet-latest';
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
