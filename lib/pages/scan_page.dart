import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Clear image helper
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      if (_scanResult != null) {
        // Only reset form if it was an AI scan, keep form open if it's a manual log
        _showForm = false;
        _scanResult = null;
      }
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
          title: const Text('AI Scanner Error', style: TextStyle(color: AppTheme.accentRed)),
          content: Text(
            'Failed to analyze image. Please ensure your Gemini API Key is valid and internet connection is active.\n\nError details: $e',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppTheme.accentEmerald)),
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
        const SnackBar(content: Text('Please provide a valid meal name.')),
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
      timestamp: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await appState.addMeal(newMeal);
    
    // Clear and reset state on success
    _clearImage();
    _hintController.clear();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal logged successfully!'),
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
      appBar: AppBar(title: const Text('AI Meal Scanner')),
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
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald)),
                    const SizedBox(height: 24),
                    const Text(
                      'Analyzing Food with Gemini AI...',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Estimating weights, portions, and total nutritional content. This may take a few seconds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: _imageBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppTheme.textSecondary.withOpacity(0.5), size: 48),
                const SizedBox(height: 14),
                const Text(
                  'No Meal Photo Selected',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Scan a photo to calculate nutrients instantly',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceLight),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                if (!_showForm) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
                    label: const Text('Log Meal Manually', style: TextStyle(color: AppTheme.accentEmerald)),
                    onPressed: () {
                      setState(() {
                        _showForm = true;
                        _imageBytes = null;
                        _selectedImage = null;
                        _scanResult = null;
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
                    backgroundColor: Colors.black.withOpacity(0.6),
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
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.accentEmerald, size: 18),
              SizedBox(width: 8),
              Text(
                'Add Context Clue (Optional)',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hintController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. "Two slices of sourdough bread, a whole avocado, and two medium fried eggs."',
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
                const Text(
                  'Gemini API Key Missing',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A valid API key is required to scan photos. Please go to settings and add your Gemini API Key.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to settings tab via layout controller if possible
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please navigate to settings panel.')),
                    );
                  },
                  child: const Text('Configure API Key'),
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
              label: const Text('Log Manually with this Photo', style: TextStyle(color: AppTheme.accentEmerald)),
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
            label: const Text('Scan & Estimate with Gemini'),
            onPressed: () => _scanMeal(apiKey),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, color: AppTheme.accentEmerald),
            label: const Text('Log Manually with this Photo', style: TextStyle(color: AppTheme.accentEmerald)),
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
              const Text(
                'Verify Nutritional Estimates',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_scanResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_scanResult!.confidence}% AI Match',
                    style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Food Name
          const Text('Meal Description', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'e.g. Avocado Toast')),
          const SizedBox(height: 16),

          // Numeric stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calories (kcal)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protein (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
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
                    const Text('Carbohydrates (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fat (g)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Analysis explanations
          const Text('AI Breakdown & Notes', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Macro breakdown...'),
          ),
          const SizedBox(height: 25),

          // Actions Form Toggles
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
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveMeal(appState),
                  child: const Text('Log & Save Meal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
