import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../widgets/scan/scan_image_selector.dart';
import '../widgets/scan/scan_verification_form.dart';
import '../widgets/scan/scan_favorites_list.dart';
import '../widgets/adaptive/adaptive_card_header.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _hintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = Provider.of<AppState>(context, listen: false);
      _hintController.text = appState.scanUserHint;
      _hintController.addListener(() {
        appState.updateScanUserHint(_hintController.text);
      });
    });
  }

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
        if (!mounted) return;
        final appState = Provider.of<AppState>(context, listen: false);
        appState.setScanImage(bytes, image.mimeType ?? 'image/jpeg');
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
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.scanShowForm) {
      appState.clearScanImage();
    } else {
      appState.clearScanState();
      _hintController.clear();
    }
  }

  // Trigger AI scanning
  Future<void> _scanMeal(AppState appState) async {
    final colors = AppTheme.of(context);
    if (appState.scanImageBytes == null) return;

    appState.setScanIsScanning(true);

    try {
      final result = await appState.performAIAnalysis(
        imageBytes: appState.scanImageBytes!,
        mimeType: appState.scanMimeType,
        userHint: _hintController.text,
      );

      appState.setScanResult(result);
    } catch (e) {
      appState.setScanIsScanning(false);
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
    final String apiKey = appState.aiApiKey;
    final bool hasApiKey =
        appState.aiProvider == 'custom' || apiKey.trim().isNotEmpty;
    final colors = AppTheme.of(context);

    if (appState.templateMeal != null) {
      final template = appState.templateMeal!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        appState.setScanStateFromTemplate(template);
        appState.clearTemplateMeal();
      });
    }

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
                    imageBytes: appState.scanImageBytes,
                    onPickGallery: () => _pickImage(ImageSource.gallery),
                    onPickCamera: () => _pickImage(ImageSource.camera),
                    onClear: _clearImage,
                    onLogManually: () {
                      appState.logManuallyWithoutPhoto();
                    },
                    showForm: appState.scanShowForm,
                  ),
                  const SizedBox(height: 20),

                  if (appState.scanImageBytes == null &&
                      !appState.scanShowForm) ...[
                    ScanFavoritesList(appState: appState),
                    const SizedBox(height: 20),
                  ],

                  if (appState.scanImageBytes != null &&
                      !appState.scanShowForm &&
                      !appState.scanIsScanning) ...[
                    // User context clue input
                    _buildHintField(),
                    const SizedBox(height: 25),

                    // AI Trigger Button
                    _buildTriggerButton(hasApiKey, appState),
                    const SizedBox(height: 20),
                  ],

                  // Phase B: Form verification
                  if (appState.scanShowForm)
                    ScanVerificationForm(
                      appState: appState,
                      scanResult: appState.scanResult,
                      imageBytes: appState.scanImageBytes,
                      onDiscard: () {
                        appState.discardForm();
                        if (!appState.scanShowForm &&
                            appState.scanImageBytes == null) {
                          _hintController.clear();
                        }
                      },
                      onSaveSuccess: () {
                        appState.clearScanState();
                        _hintController.clear();
                      },
                    ),
                ],
              ),
            ),
          ),

          // Scanning full-screen loading spinner
          if (appState.scanIsScanning)
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveCardHeader(
            icon: Icons.lightbulb_outline,
            iconColor: AppTheme.accentEmerald,
            title: AppLocalizations.of(context)!.contextClue,
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
  Widget _buildTriggerButton(bool hasApiKey, AppState appState) {
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
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
              label: Text(
                AppLocalizations.of(context)!.logWithPhoto,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.accentEmerald),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(
                  color: AppTheme.accentEmerald,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openManualFormWithPhoto(appState),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              AppLocalizations.of(context)!.scanAndEstimate,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: () => _scanMeal(appState),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
            label: Text(
              AppLocalizations.of(context)!.logWithPhoto,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.accentEmerald),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _openManualFormWithPhoto(appState),
          ),
        ),
      ],
    );
  }

  void _openManualFormWithPhoto(AppState appState) {
    appState.openManualFormWithPhoto();
  }
}
