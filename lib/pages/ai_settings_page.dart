import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/adaptive/adaptive_card_header.dart';
import '../widgets/settings/gemini_info_dialog.dart';
import '../services/ai_service.dart';

class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  late final AppState _appState;

  late String _selectedProvider;
  late String _selectedModel;
  late TextEditingController _customModelController;
  late TextEditingController _apiKeyController;
  late TextEditingController _customUrlController;

  bool _obscureApiKey = true;
  bool _isValidating = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  // Available models mappings
  Map<String, List<String>> get _providerModels =>
      AIServiceConfig.providerModels;

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();

    _selectedProvider = _appState.aiProvider;
    _selectedModel = _appState.aiModel;

    _customModelController = TextEditingController(
      text: _isStandardModel(_selectedProvider, _selectedModel)
          ? ''
          : _selectedModel,
    );
    _apiKeyController = TextEditingController(text: _appState.aiApiKey);
    _customUrlController = TextEditingController(text: _appState.aiCustomUrl);
  }

  @override
  void dispose() {
    _customModelController.dispose();
    _apiKeyController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  bool _isStandardModel(String provider, String model) {
    if (!_providerModels.containsKey(provider)) return false;
    return _providerModels[provider]!.contains(model);
  }

  // Update selected provider and reset model choice to default recommended
  void _onProviderChanged(String? newProvider) {
    if (newProvider == null) return;
    setState(() {
      _selectedProvider = newProvider;
      if (_providerModels.containsKey(newProvider)) {
        _selectedModel = _providerModels[newProvider]!.first;
      } else {
        _selectedModel = '';
      }
    });
  }

  Future<void> _validateConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidating = true;
    });

    final String finalModel = _selectedProvider == 'custom'
        ? _customModelController.text.trim()
        : _selectedModel;

    try {
      await _appState.validateAISettings(
        provider: _selectedProvider,
        model: finalModel,
        apiKey: _apiKeyController.text.trim(),
        customUrl: _customUrlController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.validateSuccess),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          final colors = AppTheme.of(context);
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(
              AppLocalizations.of(context)!.aiError,
              style: const TextStyle(color: AppTheme.accentRed),
            ),
            content: Text(
              AppLocalizations.of(context)!.validationFailed(e.toString()),
              style: TextStyle(color: colors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: const TextStyle(color: AppTheme.accentEmerald),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final String finalModel = _selectedProvider == 'custom'
        ? _customModelController.text.trim()
        : _selectedModel;

    await _appState.saveAISettings(
      provider: _selectedProvider,
      model: finalModel,
      apiKey: _apiKeyController.text.trim(),
      customUrl: _customUrlController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.aiSettingsSaved),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final isCustom = _selectedProvider == 'custom';

    return Scaffold(
      appBar: AppBar(title: Text(localizations.aiSettingsTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info description header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    color: colors.surfaceLight.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insights,
                        color: AppTheme.accentEmerald,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizations.aiSettingsDesc,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Central configuration card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.premiumCardDecoration(
                    context: context,
                    color: colors.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdaptiveCardHeader(
                        icon: Icons.settings_suggest,
                        iconColor: AppTheme.accentEmerald,
                        title: localizations.aiSettingsTitle,
                      ),
                      const SizedBox(height: 20),

                      // Provider Dropdown Selector
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProvider,
                        decoration: InputDecoration(
                          labelText: localizations.aiProviderLabel,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'gemini',
                            child: Text('Google Gemini'),
                          ),
                          DropdownMenuItem(
                            value: 'openai',
                            child: Text('OpenAI'),
                          ),
                          DropdownMenuItem(
                            value: 'anthropic',
                            child: Text('Anthropic Claude'),
                          ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Custom Endpoint'),
                          ),
                        ],
                        onChanged: _onProviderChanged,
                      ),
                      const SizedBox(height: 20),

                      // Model Dropdown or Textfield
                      if (!isCustom)
                        DropdownButtonFormField<String>(
                          initialValue:
                              _providerModels[_selectedProvider]!.contains(
                                _selectedModel,
                              )
                              ? _selectedModel
                              : _providerModels[_selectedProvider]!.first,
                          decoration: InputDecoration(
                            labelText: localizations.aiModelLabel,
                          ),
                          items: _providerModels[_selectedProvider]!
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedModel = v;
                              });
                            }
                          },
                        )
                      else
                        TextFormField(
                          controller: _customModelController,
                          decoration: InputDecoration(
                            labelText: localizations.aiModelLabel,
                            hintText: localizations.customModelHint,
                          ),
                          validator: (v) {
                            if (isCustom && (v == null || v.trim().isEmpty)) {
                              return 'Please specify a custom model name';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 20),

                      // Custom endpoint base URL
                      if (isCustom) ...[
                        TextFormField(
                          controller: _customUrlController,
                          decoration: InputDecoration(
                            labelText: localizations.customUrlLabel,
                            hintText: localizations.customUrlHint,
                          ),
                          validator: (v) {
                            if (isCustom && (v == null || v.trim().isEmpty)) {
                              return 'Custom base endpoint URL is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Credentials Authorization Key field
                      TextFormField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        decoration: InputDecoration(
                          labelText: localizations.apiKeyLabel,
                          hintText: localizations.enterApiKey,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureApiKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: colors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                          ),
                        ),
                        validator: (v) {
                          // Allow empty api key if custom provider (as local services like Ollama often don't need it)
                          if (!isCustom && (v == null || v.trim().isEmpty)) {
                            return 'API Authorization Key is required';
                          }
                          return null;
                        },
                      ),
                      if (_selectedProvider == 'gemini') ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const GeminiInfoDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.help_outline,
                                  size: 14,
                                  color: AppTheme.accentEmerald,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  localizations.geminiInfoTitle,
                                  style: const TextStyle(
                                    color: AppTheme.accentEmerald,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          icon: _isValidating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accentEmerald,
                                  ),
                                )
                              : const Icon(
                                  Icons.bolt,
                                  color: AppTheme.accentEmerald,
                                ),
                          label: Text(
                            localizations.validateConnection,
                            style: const TextStyle(
                              color: AppTheme.accentEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.accentEmerald,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isValidating || _isSaving
                              ? null
                              : _validateConnection,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(localizations.saveChanges),
                          onPressed: _isValidating || _isSaving
                              ? null
                              : _saveSettings,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
