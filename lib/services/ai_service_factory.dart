import 'ai_service_interface.dart';
import 'gemini_service.dart';
import 'openai_service.dart';
import 'anthropic_service.dart';
import 'grok_service.dart';
import 'custom_ai_service.dart';

class AIServiceFactory {
  static AIService getService(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return OpenAIService();
      case 'anthropic':
        return AnthropicService();
      case 'grok':
        return GrokService();
      case 'custom':
        return CustomAIService();
      case 'gemini':
      default:
        return GeminiService();
    }
  }
}
