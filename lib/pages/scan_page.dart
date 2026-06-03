import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../widgets/scan/scan_image_selector.dart';
import '../widgets/scan/scan_verification_form.dart';
import '../widgets/scan/scan_favorites_list.dart';
import '../widgets/scan/scan_hint_field.dart';
import '../widgets/scan/scan_trigger_actions.dart';
import '../widgets/scan/ai_fallback_dialog.dart';
import '../widgets/scan/scanning_overlay.dart';

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
      final appState = context.read<AppState>();
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
        final appState = context.read<AppState>();
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
    final appState = context.read<AppState>();
    if (appState.scanShowForm) {
      appState.clearScanImage();
    } else {
      appState.clearScanState();
      _hintController.clear();
    }
  }

  // Trigger AI scanning
  Future<void> _scanMeal(AppState appState, {String? overrideProvider}) async {
    final colors = AppTheme.of(context);
    if (appState.scanImageBytes == null) return;

    appState.setScanIsScanning(true);

    try {
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('Wakelock enable failed: $e');
    }

    try {
      final result = await appState.performAIAnalysis(
        imageBytes: appState.scanImageBytes!,
        mimeType: appState.scanMimeType,
        userHint: _hintController.text,
        overrideProvider: overrideProvider,
      );

      appState.setScanResult(result);
    } catch (e) {
      appState.setScanIsScanning(false);
      if (!mounted) return;

      await AIFallbackDialog.handleFallback(
        context: context,
        appState: appState,
        currentOverrideProvider: overrideProvider,
        error: e,
        onRetry: (fallback) => _scanMeal(appState, overrideProvider: fallback),
        onErrorUnhandled: () {
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
        },
      );
    } finally {
      try {
        await WakelockPlus.disable();
      } catch (e) {
        debugPrint('Wakelock disable failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final String apiKey = appState.aiApiKey;
    final bool hasApiKey =
        appState.aiProvider == 'custom' || apiKey.trim().isNotEmpty;

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
                    onLogActivity: () {
                      appState.logActivityManually();
                    },
                    showForm: appState.scanShowForm,
                  ),
                  const SizedBox(height: 20),

                  if (appState.scanImageBytes == null &&
                      !appState.scanShowForm) ...[
                    const ScanFavoritesList(),
                    const SizedBox(height: 20),
                  ],

                  if (appState.scanImageBytes != null &&
                      !appState.scanShowForm &&
                      !appState.scanIsScanning) ...[
                    // User context clue input
                    ScanHintField(hintController: _hintController),
                    const SizedBox(height: 25),

                    // AI Trigger Button
                    ScanTriggerActions(
                      hasApiKey: hasApiKey,
                      onScanPressed: () => _scanMeal(appState),
                      onManualLogPressed: () =>
                          appState.openManualFormWithPhoto(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Phase B: Form verification
                  if (appState.scanShowForm)
                    ScanVerificationForm(
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

          ScanningOverlay(isScanning: appState.scanIsScanning),
        ],
      ),
    );
  }
}
