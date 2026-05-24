import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../services/gemini_service.dart';
import '../models/meal_model.dart';

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
  DateTime _mealDate = DateTime.now();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _hintController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
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
          // Keep form open if it was already open (e.g. manual logging),
          // otherwise keep it closed so user can scan or log manually
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pickImageFailed(e.toString()))),
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
      _mealDate = DateTime.now();
    });
  }

  // Trigger Gemini AI scanning
  Future<void> _scanMeal(String apiKey) async {
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
      );

      setState(() {
        _scanResult = result;
        _isScanning = false;
        _showForm = true;
        
        // Populate text form fields
        _nameController.text = result.foodName;
        _caloriesController.text = result.calories.toString();
        _proteinController.text = result.protein.toString();
        _carbsController.text = result.carbs.toString();
        _fatController.text = result.fat.toString();
        _notesController.text = result.notes;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(AppLocalizations.of(context)!.aiError, style: const TextStyle(color: AppTheme.accentRed)),
          content: Text(
            AppLocalizations.of(context)!.aiErrorDesc(e.toString()),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(color: AppTheme.accentEmerald)),
            ),
          ],
        ),
      );
    }
  }

  // Save validated meal log helper
  Future<void> _saveMeal(AppState appState) async {
    final String name = _nameController.text.trim();
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int protein = int.tryParse(_proteinController.text) ?? 0;
    final int carbs = int.tryParse(_carbsController.text) ?? 0;
    final int fat = int.tryParse(_fatController.text) ?? 0;
    final String notes = _notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.provideName)),
      );
      return;
    }

    final newMeal = Meal(
      shortId: 'MEAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      foodName: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      confidence: _scanResult?.confidence ?? 100,
      imageBytes: _imageBytes,
      notes: notes,
      timestamp: _mealDate.millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await appState.addMeal(newMeal);

    appState.selectTab(0);
    
    // Clear and reset state on success
    _clearImage();
    _hintController.clear();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.mealLogged),
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final String apiKey = appState.geminiApiKey;
    final bool hasApiKey = apiKey.trim().isNotEmpty;

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
                  _buildIntakeSection(),
                  const SizedBox(height: 20),

                  if (_imageBytes != null && !_showForm && !_isScanning) ...[
                    // User context clue input
                    _buildHintField(),
                    const SizedBox(height: 25),

                    // Gemini Trigger Button
                    _buildTriggerButton(hasApiKey, apiKey),
                    const SizedBox(height: 20),
                  ],

                  // Phase B: Form verification
                  if (_showForm) _buildVerificationForm(appState),
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
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald)),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.scanningTitle,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        AppLocalizations.of(context)!.scanningDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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

  // Layout 1: Photo selection dashboard
  Widget _buildIntakeSection() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: _imageBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppTheme.textSecondary.withValues(alpha: 0.5), size: 48),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)!.noPhotoSelected,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.scanPrompt,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)!.gallery),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceLight),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.camera),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                if (!_showForm) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
                    label: Text(AppLocalizations.of(context)!.logManually, style: const TextStyle(color: AppTheme.accentEmerald)),
                    onPressed: () {
                      setState(() {
                        _showForm = true;
                        _imageBytes = null;
                        _selectedImage = null;
                        _scanResult = null;
                        _mealDate = DateTime.now();
                        _nameController.text = 'New Meal';
                        _caloriesController.text = '0';
                        _proteinController.text = '0';
                        _carbsController.text = '0';
                        _fatController.text = '0';
                        _notesController.text = '';
                      });
                    },
                  ),
                ],
              ],
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    onPressed: _clearImage,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }

  // Layout 2: Optional hint field
  Widget _buildHintField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppTheme.accentEmerald, size: 18),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.contextClue,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
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

  // Layout 3: Scan trigger action
  Widget _buildTriggerButton(bool hasApiKey, String apiKey) {
    if (!hasApiKey) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.premiumCardDecoration(glowColor: AppTheme.accentRed),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 32),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.apiKeyMissing,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.apiKeyMissingDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to settings tab via layout controller if possible
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.navigateToSettings)),
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
              label: Text(AppLocalizations.of(context)!.logWithPhoto, style: const TextStyle(color: AppTheme.accentEmerald)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: () => _scanMeal(apiKey),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
            label: Text(AppLocalizations.of(context)!.logWithPhoto, style: const TextStyle(color: AppTheme.accentEmerald)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accentEmerald, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      _mealDate = DateTime.now();
      _nameController.text = 'New Meal';
      _caloriesController.text = '0';
      _proteinController.text = '0';
      _carbsController.text = '0';
      _fatController.text = '0';
      _notesController.text = '';
    });
  }

  // Layout 4: AI verification form
  Widget _buildVerificationForm(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(showGlow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.verifyEstimates,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_scanResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.aiMatch(_scanResult!.confidence),
                    style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Food Name
          Text(AppLocalizations.of(context)!.mealDescription, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(controller: _nameController, decoration: InputDecoration(hintText: AppLocalizations.of(context)!.avocadoHint)),
          const SizedBox(height: 16),

          // Numeric stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.caloriesKcal, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.proteinG, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.carbsG, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.fatG, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Analysis explanations
          Text(AppLocalizations.of(context)!.aiNotes, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.macroHint),
          ),
          const SizedBox(height: 16),

          // Date picker for meal date
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _mealDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _mealDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.accentEmerald, size: 18),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.mealDate, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text(
                    DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(_mealDate),
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_mealDate == DateTime.now().subtract(const Duration(days: 1)) ||
                      _mealDate.isBefore(DateTime.now().subtract(const Duration(days: 1))))
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.edit_calendar, color: AppTheme.accentAmber, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showForm = false;
                      _scanResult = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppLocalizations.of(context)!.discard),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveMeal(appState),
                  child: Text(AppLocalizations.of(context)!.logAndSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
