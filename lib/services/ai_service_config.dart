class AIServiceConfig {
  static const Map<String, List<String>> providerModels = {
    'gemini': ['gemini-3.7-flash', 'gemini-3.5-flash', 'gemini-2.5-flash'],
    'openai': ['gpt-5.6-luna', 'gpt-5.6-terra', 'gpt-5.6-sol'],
    'anthropic': ['claude-haiku-4-5', 'claude-sonnet-4-6'],
    'grok': ['grok-4.6', 'grok-4.5', 'grok-4.3'],
    'deepseek': ['deepseek-flash'],
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
