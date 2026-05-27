part of 'ai_service.dart';

class OpenAIService implements AIService {
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

    final String activeModel = model.isNotEmpty ? model : 'gpt-4o-mini';

    final systemPrompt =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals. '
        'You MUST return a JSON object with the exact keys: \'foodName\' (string, brief description in $targetLanguage), \'calories\' (integer, estimated kcal), \'protein\' (integer, grams), \'carbs\' (integer, grams), \'fat\' (integer, grams), \'confidence\' (integer, 1-100), and \'notes\' (string, breakdown explanation in $targetLanguage). '
        'You MUST write all food description names and explanation notes in $targetLanguage.';

    final userPrompt =
        'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations. Respond with ONLY the requested JSON object.';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': activeModel,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userPrompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
              },
            ],
          },
        ],
      }),
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
    String? customUrl,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is empty.');
    }
    final activeModel = model.isNotEmpty ? model : 'gpt-4o-mini';
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
