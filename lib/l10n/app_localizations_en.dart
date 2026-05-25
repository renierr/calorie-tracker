// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NutriScan Calorie Tracker';

  @override
  String get dashboardTitle => 'NutriScan Dashboard';

  @override
  String get reloadDatabase => 'Reload Database';

  @override
  String get calorieConsumption => 'Calorie Consumption';

  @override
  String ofKcal(Object goal) {
    return 'of $goal kcal';
  }

  @override
  String kcalRemaining(Object remaining) {
    return '$remaining kcal remaining';
  }

  @override
  String kcalOverBudget(Object over) {
    return '$over kcal over budget';
  }

  @override
  String get macroDistribution => 'Macronutrient Distribution';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get fat => 'Lipid Fats';

  @override
  String get calorieTrend => 'Calorie Trend (7 Days)';

  @override
  String trendGoal(Object goal) {
    return 'Goal: $goal kcal';
  }

  @override
  String get dayLogSummary => 'Day Log Summary';

  @override
  String logs(Object count) {
    return '$count logs';
  }

  @override
  String get noMealsLogged => 'No meals logged for this day.';

  @override
  String perGram(Object carbs, Object fat, Object protein) {
    return 'P: ${protein}g  C: ${carbs}g  F: ${fat}g';
  }

  @override
  String kcalLabel(Object calories) {
    return '+$calories kcal';
  }

  @override
  String get scanTitle => 'AI Meal Scanner';

  @override
  String get noPhotoSelected => 'No Meal Photo Selected';

  @override
  String get scanPrompt => 'Scan a photo to calculate nutrients instantly';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get logManually => 'Log Meal Manually';

  @override
  String get contextClue => 'Add Context Clue (Optional)';

  @override
  String get contextHint =>
      'e.g. \"Two slices of sourdough bread, a whole avocado, and two medium fried eggs.\"';

  @override
  String get scanAndEstimate => 'Scan & Estimate with Gemini';

  @override
  String get logWithPhoto => 'Log Manually with this Photo';

  @override
  String get apiKeyMissing => 'Gemini API Key Missing';

  @override
  String get apiKeyMissingDesc =>
      'A valid API key is required to scan photos. Please go to settings and add your Gemini API Key.';

  @override
  String get navigateToSettings => 'Please navigate to settings panel.';

  @override
  String get configureApiKey => 'Configure API Key';

  @override
  String get verifyEstimates => 'Verify Nutritional Estimates';

  @override
  String aiMatch(Object confidence) {
    return '$confidence% AI Match';
  }

  @override
  String get mealDescription => 'Meal Description';

  @override
  String get avocadoHint => 'e.g. Avocado Toast';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get carbsG => 'Carbohydrates (g)';

  @override
  String get fatG => 'Fat (g)';

  @override
  String get aiNotes => 'AI Breakdown & Notes';

  @override
  String get macroHint => 'Macro breakdown...';

  @override
  String get discard => 'Discard';

  @override
  String get logAndSave => 'Log & Save Meal';

  @override
  String get mealDate => 'Meal Date:';

  @override
  String get notes => 'Notes';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String pickImageFailed(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get provideName => 'Please provide a valid meal name.';

  @override
  String get mealLogged => 'Meal logged successfully!';

  @override
  String get scanningTitle => 'Analyzing Food with Gemini AI...';

  @override
  String get scanningDesc =>
      'Estimating weights, portions, and total nutritional content. This may take a few seconds.';

  @override
  String get aiError => 'AI Scanner Error';

  @override
  String aiErrorDesc(Object error) {
    return 'Failed to analyze image. Please ensure your Gemini API Key is valid and internet connection is active.\n\nError details: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get historyTitle => 'Meal History Logs';

  @override
  String get filterTimeframe => 'Filter Timeframe:';

  @override
  String get allTime => 'All Time';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get customRange => 'Custom Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String logsInFilter(Object count) {
    return '$count logs in active filter';
  }

  @override
  String get compilePdf => 'Compile meals into a nutritional PDF report.';

  @override
  String get reportPdf => 'Report PDF';

  @override
  String get pdf => 'PDF';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Confirm Deletion';

  @override
  String get confirmDeleteDesc =>
      'Are you sure you want to permanently delete this logged meal? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get noHistory => 'No History Found';

  @override
  String get noHistoryDesc => 'Change filters or scan a meal to start logging!';

  @override
  String get mealUpdated => 'Meal updated successfully!';

  @override
  String get editMeal => 'Edit Logged Meal';

  @override
  String get generatePdf => 'Generate PDF Summary Report';

  @override
  String get reportTitle => 'Report Header Title';

  @override
  String get reportComments => 'Report Explanations / Comments';

  @override
  String get addComments => 'Add summary comments...';

  @override
  String get includePhotos => 'Include Photo Album';

  @override
  String get generatePdfBtn => 'Generate PDF';

  @override
  String get generatingPdf => 'Generating PDF Report...';

  @override
  String get generatingMealPdf => 'Generating individual meal PDF...';

  @override
  String get mealDeleted => 'Meal deleted.';

  @override
  String caloriesLabel(Object calories) {
    return 'Calories: $calories kcal';
  }

  @override
  String macroPerGram(Object carbs, Object fat, Object protein) {
    return 'P: ${protein}g  •  C: ${carbs}g  •  F: ${fat}g';
  }

  @override
  String get settingsTitle => 'Goal & API Settings';

  @override
  String get apiCredentials => 'Gemini AI API Credentials';

  @override
  String get apiCredentialsDesc =>
      'The AI Meal Scanner requires a Google Gemini API Key. Your key is saved locally in private app settings.';

  @override
  String get enterApiKey => 'Enter your Gemini API Key';

  @override
  String get apiKeyLabel => 'Gemini API Key';

  @override
  String get dailyTargets => 'Daily Nutritional Targets';

  @override
  String get calorieBudget => 'Daily Calorie Budget (kcal)';

  @override
  String get calorieHint => 'e.g. 2000';

  @override
  String get proteinHint => 'e.g. 130';

  @override
  String get carbsHint => 'e.g. 220';

  @override
  String get fatHint => 'e.g. 70';

  @override
  String get dangerZone => 'Danger Zone & Maintenance';

  @override
  String get dangerDesc =>
      'Clearing your database will permanently remove all tracked foods, calorie metrics, and meal photos from SQLite. This action is irreversible.';

  @override
  String get clearHistory => 'Clear All Food Logs History';

  @override
  String get eraseAll => 'Erase All Data?';

  @override
  String get eraseAllDesc =>
      'Are you absolutely sure you want to permanently clear the SQLite database? This deletes all your logged meal stats, photos, and historical progress. This action cannot be undone.';

  @override
  String get permanentlyErase => 'Permanently Erase Database';

  @override
  String get savePreferences => 'Save Preferences';

  @override
  String get prefsSaved => 'Preferences saved successfully!';

  @override
  String get dbCleared => 'Database log history cleared.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get exportDb => 'Export SQLite Database';

  @override
  String get exportDbDesc =>
      'Download a copy of the database. On Desktop, a save dialog will open. On Android, the copy is stored in your device\'s Android/data folder for backup.';

  @override
  String get exportDbBtn => 'Download Database Copy';

  @override
  String get dbExported => 'Database exported successfully.';

  @override
  String get restoreDb => 'Restore SQLite Database';

  @override
  String get restoreDbDesc =>
      'Restore a previous backup of your complete database. This will overwrite all your current meal records.';

  @override
  String get restoreDbBtn => 'Restore Database Backup';

  @override
  String get confirmRestore => 'Restore Database?';

  @override
  String get confirmRestoreDesc =>
      'Are you absolutely sure you want to restore this database backup? All your current logged meals and photos will be permanently replaced. This action cannot be undone.';

  @override
  String get noBackupsFound => 'No database backup files found.';

  @override
  String get selectBackup => 'Select a Backup File';

  @override
  String get dbRestored => 'Database restored successfully.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sidebarDashboard => 'Dashboard';

  @override
  String get sidebarScan => 'AI Food Scan';

  @override
  String get sidebarHistory => 'Meal History';

  @override
  String get sidebarSettings => 'Goal Settings';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navScan => 'Scan';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSettingsCompact => 'Prefs';

  @override
  String get profileName => 'My Profile';

  @override
  String get profileStatus => 'Offline User';

  @override
  String get pdfDailySummary => 'Daily Nutritional Summary';

  @override
  String get pdfAnalysisSummary => 'Nutritional Analysis Summary';

  @override
  String pdfLoggedOn(Object date) {
    return 'Logged on: $date';
  }

  @override
  String pdfDateRange(Object date) {
    return 'Date: $date';
  }

  @override
  String pdfRangeCustom(Object end, Object start) {
    return 'Range: $start - $end';
  }

  @override
  String get pdfAllTime => 'All-Time Logs';

  @override
  String get pdfRange7Days => 'Range: Last 7 Days';

  @override
  String get pdfActiveFilter => 'Active Filter Range';

  @override
  String get importLabel => 'Import';

  @override
  String get exportLabel => 'Export';

  @override
  String importMealsSuccess(int count) {
    return 'Successfully imported $count meals.';
  }

  @override
  String importMealsError(String error) {
    return 'Failed to import meals: $error';
  }

  @override
  String get exportMealsSuccess => 'Meals exported successfully.';

  @override
  String exportMealsError(String error) {
    return 'Failed to export: $error';
  }

  @override
  String get selectMeals => 'Select';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get reEvaluate => 'Re-Evaluate';

  @override
  String get reEvaluating => 'Re-Evaluating...';

  @override
  String reEvaluationError(String error) {
    return 'Re-Evaluation failed: $error';
  }

  @override
  String get reEvaluationSuccess => 'Meal re-evaluated successfully!';

  @override
  String get syncSettings => 'Cloud Sync Settings';

  @override
  String get syncSettingsDesc =>
      'Configure your backend server connection to backup and synchronize your meal database across multiple devices.';

  @override
  String get syncServerUrl => 'Sync Server URL';

  @override
  String get syncServerUrlHint => 'e.g. http://localhost:3000';

  @override
  String get syncUserId => 'Sync User ID';

  @override
  String get syncUserIdHint => 'e.g. user-1';

  @override
  String get syncNowBtn => 'Sync Database Now';

  @override
  String get syncingStatus => 'Synchronizing with server...';

  @override
  String syncSuccess(int pulled, int pushed) {
    return 'Sync completed! Pulled: $pulled, Pushed: $pushed';
  }

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String lastSyncedLabel(String time) {
    return 'Last Synced: $time';
  }

  @override
  String get neverSynced => 'Never Synced';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String gitHash(String hash) {
    return 'Git Hash: $hash';
  }

  @override
  String get imageSavedSuccess => 'Image saved successfully!';

  @override
  String get imageSavedDownloads => 'Image saved to Downloads folder!';

  @override
  String imageSavedTo(String path) {
    return 'Image saved to: $path';
  }

  @override
  String imageSaveFailed(String error) {
    return 'Failed to save image: $error';
  }

  @override
  String get dbExportedDownloads => 'Database exported to Downloads folder!';

  @override
  String dbExportedTo(String path) {
    return 'Database exported to: $path';
  }

  @override
  String dbExportFailed(String error) {
    return 'Database export failed: $error';
  }
}
