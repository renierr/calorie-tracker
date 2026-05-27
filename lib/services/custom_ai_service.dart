part of 'ai_service.dart';

class CustomAIService implements AIService {
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

    final String activeModel = model.isNotEmpty ? model : 'custom-vision-model';

    // Parse the endpoint URL robustly
    String url = (customUrl ?? '').trim();
    if (url.isEmpty) {
      throw Exception('Custom API Endpoint Base URL is required.');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!url.contains('/chat/completions')) {
      if (url.endsWith('/')) {
        url = '${url}chat/completions';
      } else {
        url = '$url/chat/completions';
      }
    }

    final systemPrompt =
        'You are an advanced clinical nutritionist AI. You specialize in visually scanning dishes, estimating portion weights, and breaking down total nutritional content into precise calorie and macronutrient (protein, carbohydrates, lipid fat) totals. '
        'You MUST return a JSON object with the exact keys: \'foodName\' (string, brief description in $targetLanguage), \'calories\' (integer, estimated kcal), \'protein\' (integer, grams), \'carbs\' (integer, grams), \'fat\' (integer, grams), \'confidence\' (integer, 1-100), and \'notes\' (string, breakdown explanation in $targetLanguage). '
        'You MUST write all food description names and explanation notes in $targetLanguage.';

    final userPrompt =
        'Analyze this food meal photo and estimate its total nutritional content. '
        '${userHint.trim().isNotEmpty ? 'Context clue provided by user: "$userHint". ' : ''}'
        'Provide logical, accurate calories, protein, carbs, and fat estimations. Respond with ONLY the requested JSON object.';

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
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
        'Custom OpenAI Endpoint Error: status code ${response.statusCode}, body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw Exception('Empty choices returned from Custom API endpoint.');
    }

    final messageContent = choices[0]['message']['content'] as String?;
    if (messageContent == null || messageContent.trim().isEmpty) {
      throw Exception(
        'Received empty message content from Custom API endpoint.',
      );
    }

    // Handle potential raw JSON string that isn't pre-cleaned
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
    String? customUrl,
  }) async {
    String url = (customUrl ?? '').trim();
    if (url.isEmpty) {
      throw Exception('Custom API Endpoint Base URL is required.');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!url.contains('/chat/completions')) {
      if (url.endsWith('/')) {
        url = '${url}chat/completions';
      } else {
        url = '$url/chat/completions';
      }
    }

    final activeModel = model.isNotEmpty ? model : 'custom-vision-model';

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    // Try a simple ping post request
    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
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
        'Custom Endpoint Validation Failed: status code ${response.statusCode}, body: ${response.body}',
      );
    }
  }
}
