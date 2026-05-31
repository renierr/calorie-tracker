import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calorie_tracker/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Settings Provider-Specific Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should cache and save settings per provider', () async {
      final appState = AppState();
      await appState.loadAISettings();

      // Set and save settings for OpenAI
      await appState.saveAISettings(
        provider: 'openai',
        model: 'gpt-4o',
        apiKey: 'sk-12345',
        customUrl: '',
        reasoningEffort: 'low',
      );

      // Set and save settings for Anthropic
      await appState.saveAISettings(
        provider: 'anthropic',
        model: 'claude-3-5-sonnet-latest',
        apiKey: 'anthropic-key',
        customUrl: 'http://custom-anthropic.com',
        reasoningEffort: 'medium',
      );

      // Verify general active settings are updated to last saved (Anthropic)
      expect(appState.aiProvider, 'anthropic');
      expect(appState.aiModel, 'claude-3-5-sonnet-latest');
      expect(appState.aiApiKey, 'anthropic-key');
      expect(appState.aiCustomUrl, 'http://custom-anthropic.com');
      expect(appState.aiReasoningEffort, 'medium');

      // Verify that querying for OpenAI retrieves OpenAI's settings
      expect(appState.getModelForProvider('openai'), 'gpt-4o');
      expect(appState.getApiKeyForProvider('openai'), 'sk-12345');
      expect(appState.getCustomUrlForProvider('openai'), '');
      expect(appState.getReasoningEffortForProvider('openai'), 'low');

      // Verify that querying for Anthropic retrieves Anthropic's settings
      expect(
        appState.getModelForProvider('anthropic'),
        'claude-3-5-sonnet-latest',
      );
      expect(appState.getApiKeyForProvider('anthropic'), 'anthropic-key');
      expect(
        appState.getCustomUrlForProvider('anthropic'),
        'http://custom-anthropic.com',
      );
      expect(appState.getReasoningEffortForProvider('anthropic'), 'medium');

      // Load into another AppState instance to test persistence
      final appState2 = AppState();
      await appState2.loadAISettings();

      // Verify settings are loaded and persisted per provider
      expect(appState2.getModelForProvider('openai'), 'gpt-4o');
      expect(appState2.getApiKeyForProvider('openai'), 'sk-12345');
      expect(appState2.getCustomUrlForProvider('openai'), '');
      expect(appState2.getReasoningEffortForProvider('openai'), 'low');

      expect(
        appState2.getModelForProvider('anthropic'),
        'claude-3-5-sonnet-latest',
      );
      expect(appState2.getApiKeyForProvider('anthropic'), 'anthropic-key');
      expect(
        appState2.getCustomUrlForProvider('anthropic'),
        'http://custom-anthropic.com',
      );
      expect(appState2.getReasoningEffortForProvider('anthropic'), 'medium');
    });

    test('should export and import all provider settings correctly', () async {
      final appState = AppState();
      await appState.loadAISettings();

      // Configure provider settings
      await appState.saveAISettings(
        provider: 'openai',
        model: 'gpt-4o',
        apiKey: 'sk-12345',
        customUrl: '',
        reasoningEffort: 'low',
      );
      await appState.saveAISettings(
        provider: 'anthropic',
        model: 'claude-3-5-sonnet-latest',
        apiKey: 'anthropic-key',
        customUrl: 'http://custom-anthropic.com',
        reasoningEffort: 'medium',
      );

      // Export settings to JSON
      final jsonStr = await appState.exportSettingsToJson();

      // Verify that all providers settings exist in the JSON
      expect(jsonStr.contains('aiProviderModels'), true);
      expect(jsonStr.contains('aiProviderApiKeys'), true);
      expect(jsonStr.contains('aiProviderCustomUrls'), true);
      expect(jsonStr.contains('aiProviderReasoningEfforts'), true);
      expect(jsonStr.contains('gpt-4o'), true);
      expect(jsonStr.contains('anthropic-key'), true);

      // Clear shared preferences
      SharedPreferences.setMockInitialValues({});

      // Import settings into a new AppState
      final appState2 = AppState();
      await appState2.loadAISettings(); // will start fresh/empty

      // Expect to be empty
      expect(appState2.getApiKeyForProvider('openai'), '');

      // Import settings from JSON
      await appState2.importSettingsFromJson(jsonStr);

      // Verify settings successfully restored for all providers
      expect(appState2.getModelForProvider('openai'), 'gpt-4o');
      expect(appState2.getApiKeyForProvider('openai'), 'sk-12345');
      expect(appState2.getCustomUrlForProvider('openai'), '');
      expect(appState2.getReasoningEffortForProvider('openai'), 'low');

      expect(
        appState2.getModelForProvider('anthropic'),
        'claude-3-5-sonnet-latest',
      );
      expect(appState2.getApiKeyForProvider('anthropic'), 'anthropic-key');
      expect(
        appState2.getCustomUrlForProvider('anthropic'),
        'http://custom-anthropic.com',
      );
      expect(appState2.getReasoningEffortForProvider('anthropic'), 'medium');
    });
  });
}
