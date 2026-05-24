import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../services/gemini_service.dart';
import '../widgets/scan/scan_image_selector.dart';
import '../widgets/scan/scan_verification_form.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  // State variables for intake
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  final TextEditingController _hintController = TextEditingController();

  // State variables for verified form
  bool _showForm = false;
  bool _isScanning = false;
  AIAnalysisResult? _scanResult;

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  // Pick image helper
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pickImageFailed(e.toString()),
          ),
        ),
      );
    }
  }

  // Clear image helper
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      if (_scanResult != null) {
        _showForm = false;
        _scanResult = null;
      }
    });
  }

  // Trigger Gemini AI scanning
  Future<void> _scanMeal(String apiKey, String languageCode) async {
    final colors = AppTheme.of(context);
    if (_imageBytes == null || _selectedImage == null) return;

    setState(() {
      _isScanning = true;
      _showForm = false;
    });

    try {
      final result = await GeminiService.performAIAnalysis(
        apiKey: apiKey,
        imageBytes: _imageBytes!,
        mimeType: _selectedImage!.mimeType ?? 'image/jpeg',
        userHint: _hintController.text,
        languageCode: languageCode,
      );

      setState(() {
        _scanResult = result;
        _isScanning = false;
        _showForm = true;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context)!.aiError,
            style: const TextStyle(color: AppTheme.accentRed),
          ),
          content: Text(
            AppLocalizations.of(context)!.aiErrorDesc(e.toString()),
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String apiKey = appState.geminiApiKey;
    final bool hasApiKey = apiKey.trim().isNotEmpty;
    final colors = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scanTitle)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phase A: Image Intake
                  ScanImageSelector(
                    imageBytes: _imageBytes,
                    onPickGallery: () => _pickImage(ImageSource.gallery),
                    onPickCamera: () => _pickImage(ImageSource.camera),
                    onClear: _clearImage,
                    onLogManually: () {
                      setState(() {
                        _showForm = true;
                        _imageBytes = null;
                        _selectedImage = null;
                        _scanResult = null;
                      });
                    },
                    showForm: _showForm,
                  ),
                  const SizedBox(height: 20),

                  if (_imageBytes != null && !_showForm && !_isScanning) ...[
                    // User context clue input
                    _buildHintField(),
                    const SizedBox(height: 25),

                    // Gemini Trigger Button
                    _buildTriggerButton(hasApiKey, apiKey, appState.appLocale),
                    const SizedBox(height: 20),
                  ],

                  // Phase B: Form verification
                  if (_showForm)
                    ScanVerificationForm(
                      appState: appState,
                      scanResult: _scanResult,
                      imageBytes: _imageBytes,
                      onDiscard: () {
                        setState(() {
                          _showForm = false;
                          _scanResult = null;
                        });
                      },
                      onSaveSuccess: () {
                        _clearImage();
                        _hintController.clear();
                      },
                    ),
                ],
              ),
            ),
          ),

          // Scanning full-screen loading spinner
          if (_isScanning)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentEmerald,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.scanningTitle,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        AppLocalizations.of(context)!.scanningDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Layout: Optional hint field
  Widget _buildHintField() {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentEmerald,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.contextClue,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hintController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.contextHint,
            ),
          ),
        ],
      ),
    );
  }

  // Layout: Scan trigger action
  Widget _buildTriggerButton(
    bool hasApiKey,
    String apiKey,
    String languageCode,
  ) {
    final colors = AppTheme.of(context);
    if (!hasApiKey) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.premiumCardDecoration(
              context: context,
              glowColor: AppTheme.accentRed,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.accentRed,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.apiKeyMissing,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.apiKeyMissingDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.navigateToSettings,
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.configureApiKey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
              label: Text(
                AppLocalizations.of(context)!.logWithPhoto,
                style: const TextStyle(color: AppTheme.accentEmerald),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppTheme.accentEmerald,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _openManualFormWithPhoto,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: Text(AppLocalizations.of(context)!.scanAndEstimate),
            onPressed: () => _scanMeal(apiKey, languageCode),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
            label: Text(
              AppLocalizations.of(context)!.logWithPhoto,
              style: const TextStyle(color: AppTheme.accentEmerald),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _openManualFormWithPhoto,
          ),
        ),
      ],
    );
  }

  void _openManualFormWithPhoto() {
    setState(() {
      _showForm = true;
      _scanResult = null;
    });
  }
}
