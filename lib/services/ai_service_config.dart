class AIServiceConfig {
  static const Map<String, List<String>> providerModels = {
    'gemini': [
      'gemini-3.5-flash',
      'gemini-3.1-flash-lite',
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
      'gemini-2.5-pro',
    ],
    'openai': ['gpt-4o-mini', 'gpt-4o', 'o1'],
    'anthropic': ['claude-haiku-4-5', 'claude-sonnet-4-6'],
    'grok': ['grok-4.3-latest', 'grok-4.3', 'grok-4-1-fast-non-reasoning'],
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
