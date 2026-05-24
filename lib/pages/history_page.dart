import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../providers/app_state.dart';
import '../models/meal_model.dart';
import '../services/pdf_service.dart';
import '../l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterType = 'all'; // 'all', 'today', 'yesterday', 'week', 'custom'
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _filterType = appState.historyFilter;
      });
    });
  }

  DateFormat get _timeFormat =>
      DateFormat.jm(Localizations.localeOf(context).toLanguageTag());
  DateFormat get _dateFormat =>
      DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());

  // Filter logic matching active dropdown selections
  List<Meal> _getFilteredMeals(List<Meal> allMeals) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    switch (_filterType) {
      case 'today':
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();

      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.year == yesterday.year &&
              date.month == yesterday.month &&
              date.day == yesterday.day;
        }).toList();

      case 'week':
        final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 6));
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.isAfter(sevenDaysAgo) ||
              date.millisecondsSinceEpoch ==
                  sevenDaysAgo.millisecondsSinceEpoch;
        }).toList();

      case 'custom':
        if (_customStartDate == null || _customEndDate == null) return allMeals;
        final start = DateTime(
          _customStartDate!.year,
          _customStartDate!.month,
          _customStartDate!.day,
        );
        final end = DateTime(
          _customEndDate!.year,
          _customEndDate!.month,
          _customEndDate!.day,
          23,
          59,
          59,
          999,
        );
        return allMeals.where((m) {
          final date = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
          return date.isAfter(start) && date.isBefore(end);
        }).toList();

      case 'all':
      default:
        return allMeals;
    }
  }

  // Trigger inline dialog to edit meal macros
  void _showEditMealDialog(BuildContext context, AppState appState, Meal meal) {
    final nameController = TextEditingController(text: meal.foodName);
    final caloriesController = TextEditingController(
      text: meal.calories.toString(),
    );
    final proteinController = TextEditingController(
      text: meal.protein.toString(),
    );
    final carbsController = TextEditingController(text: meal.carbs.toString());
    final fatController = TextEditingController(text: meal.fat.toString());
    final notesController = TextEditingController(text: meal.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final colors = AppTheme.of(context);
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            AppLocalizations.of(context)!.editMeal,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Description',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                TextField(controller: nameController),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calories (kcal)',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: caloriesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protein (g)',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: proteinController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carbohydrates (g)',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: carbsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lipid Fat (g)',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: fatController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Notes',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                TextField(controller: notesController, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedMeal = meal.copyWith(
                  foodName: nameController.text.trim(),
                  calories: int.tryParse(caloriesController.text) ?? 0,
                  protein: int.tryParse(proteinController.text) ?? 0,
                  carbs: int.tryParse(carbsController.text) ?? 0,
                  fat: int.tryParse(fatController.text) ?? 0,
                  notes: notesController.text.trim(),
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                );
                await appState.updateMeal(updatedMeal);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.mealUpdated),
                    backgroundColor: AppTheme.accentEmerald,
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Trigger Summary Report Config Modal
  void _showReportConfigDialog(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) {
    final titleController = TextEditingController(
      text: _filterType == 'today'
          ? 'Daily Nutritional Summary'
          : 'Nutritional Analysis Summary',
    );
    final notesController = TextEditingController();
    bool includeImages = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final colors = AppTheme.of(context);
            return AlertDialog(
              backgroundColor: colors.surface,
              title: Text(
                AppLocalizations.of(context)!.generatePdf,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This compiles a PDF summarizing the ${filteredMeals.length} meals displayed in the active list.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.reportTitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: titleController),
                    const SizedBox(height: 14),
                    Text(
                      AppLocalizations.of(context)!.reportComments,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.addComments,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.includePhotos,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      value: includeImages,
                      activeColor: AppTheme.accentEmerald,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setStateBuilder(() {
                          includeImages = val ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(AppLocalizations.of(context)!.generatePdfBtn),
                  onPressed: () async {
                    Navigator.pop(context);

                    String rangeText = AppLocalizations.of(
                      context,
                    )!.pdfActiveFilter;
                    if (_filterType == 'today') {
                      rangeText = AppLocalizations.of(context)!.pdfDateRange(
                        DateFormat.yMMMd(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(DateTime.now()),
                      );
                    } else if (_filterType == 'yesterday') {
                      rangeText = AppLocalizations.of(context)!.pdfDateRange(
                        DateFormat.yMMMd(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                      );
                    } else if (_filterType == 'week') {
                      rangeText = AppLocalizations.of(context)!.pdfRange7Days;
                    } else if (_filterType == 'custom' &&
                        _customStartDate != null &&
                        _customEndDate != null) {
                      rangeText = AppLocalizations.of(context)!.pdfRangeCustom(
                        DateFormat.Md(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(_customStartDate!),
                        DateFormat.Md(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(_customEndDate!),
                      );
                    } else {
                      rangeText = AppLocalizations.of(context)!.pdfAllTime;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.generatingPdf,
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    await PdfService.generateSummaryReport(
                      meals: filteredMeals,
                      title: titleController.text.trim(),
                      timeframeStr: rangeText,
                      userNotes: notesController.text.trim(),
                      includeImages: includeImages,
                      calorieGoal: appState.calorieGoal,
                      proteinGoal: appState.proteinGoal,
                      carbsGoal: appState.carbsGoal,
                      fatGoal: appState.fatGoal,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final List<Meal> filteredMeals = _getFilteredMeals(appState.meals);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.historyTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Filter Toolbar Box
            const SizedBox(height: 10),
            _buildFilterPanel(context),
            const SizedBox(height: 15),

            // Top action button card if meals are loaded
            if (filteredMeals.isNotEmpty) ...[
              _buildReportActionCard(context, appState, filteredMeals),
              const SizedBox(height: 15),
            ],

            // Active meals logs listing
            Expanded(
              child: filteredMeals.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredMeals.length,
                      itemBuilder: (context, index) {
                        final Meal meal = filteredMeals[index];
                        return _buildMealLogCard(context, appState, meal);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    final colors = AppTheme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: AppTheme.accentEmerald,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.filterTimeframe,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _filterType,
                dropdownColor: colors.surface,
                iconEnabledColor: colors.textPrimary,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(AppLocalizations.of(context)!.allTime),
                  ),
                  DropdownMenuItem(
                    value: 'today',
                    child: Text(AppLocalizations.of(context)!.today),
                  ),
                  DropdownMenuItem(
                    value: 'yesterday',
                    child: Text(AppLocalizations.of(context)!.yesterday),
                  ),
                  DropdownMenuItem(
                    value: 'week',
                    child: Text(AppLocalizations.of(context)!.last7Days),
                  ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text(AppLocalizations.of(context)!.customRange),
                  ),
                ],
                onChanged: (val) {
                  final filterVal = val ?? 'all';
                  setState(() {
                    _filterType = filterVal;
                  });
                  appState.setHistoryFilter(filterVal);
                },
              ),
            ],
          ),
          if (_filterType == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _customStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _customStartDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _customStartDate == null
                            ? AppLocalizations.of(context)!.startDate
                            : DateFormat.yMd(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(_customStartDate!),
                        style: TextStyle(
                          color: _customStartDate == null
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _customEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _customEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _customEndDate == null
                            ? AppLocalizations.of(context)!.endDate
                            : DateFormat.yMd(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(_customEndDate!),
                        style: TextStyle(
                          color: _customEndDate == null
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Widget 2: Print Report Action Card
  Widget _buildReportActionCard(
    BuildContext context,
    AppState appState,
    List<Meal> filteredMeals,
  ) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration(
        color: colors.surfaceLight.withValues(alpha: 0.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.logsInFilter(filteredMeals.length),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context)!.compilePdf,
                  style: TextStyle(color: colors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.summarize, size: 18),
            label: Text(
              AppLocalizations.of(context)!.reportPdf,
              style: TextStyle(fontSize: 13),
            ),
            onPressed: () =>
                _showReportConfigDialog(context, appState, filteredMeals),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Widget 3: Individual Log Card item
  Widget _buildMealLogCard(BuildContext context, AppState appState, Meal meal) {
    final colors = AppTheme.of(context);
    final mealDate = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Text(
                _dateFormat.format(mealDate),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeFormat.format(mealDate),
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  meal.shortId,
                  style: TextStyle(color: colors.textMuted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Core visual row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail
              GestureDetector(
                onTap: meal.imageBytes != null
                    ? () => _showImagePreview(context, meal.imageBytes!)
                    : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12, width: 0.5),
                  ),
                  child: meal.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            meal.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppTheme.accentEmerald,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Macros Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.foodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.caloriesLabel(meal.calories),
                      style: const TextStyle(
                        color: AppTheme.accentEmerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.macroPerGram(meal.carbs, meal.fat, meal.protein),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              meal.notes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),

          // Action Toolbar Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Single Export PDF
              TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.pdf,
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.generatingMealPdf,
                      ),
                    ),
                  );
                  await PdfService.generateSingleMealPdf(
                    meal,
                    appState.calorieGoal,
                  );
                },
              ),
              const SizedBox(width: 8),

              // Edit
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.edit,
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () => _showEditMealDialog(context, appState, meal),
              ),
              const SizedBox(width: 8),

              // Delete
              TextButton.icon(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppTheme.accentRed,
                ),
                label: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(fontSize: 12, color: AppTheme.accentRed),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: colors.surface,
                        title: Text(
                          AppLocalizations.of(context)!.confirmDelete,
                          style: TextStyle(color: AppTheme.accentRed),
                        ),
                        content: Text(
                          AppLocalizations.of(context)!.confirmDeleteDesc,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentRed,
                            ),
                            onPressed: () async {
                              await appState.deleteMeal(meal.id!);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.mealDeleted,
                                  ),
                                ),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget 4: Empty logs list fallback screen
  Widget _buildEmptyState() {
    final colors = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: colors.textMuted.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noHistory,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.noHistoryDesc,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: FloatingActionButton.small(
                heroTag: 'close_preview',
                backgroundColor: Colors.black54,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
