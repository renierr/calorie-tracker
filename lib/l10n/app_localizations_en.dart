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
  String get scanAndEstimate => 'Scan & Estimate with AI';

  @override
  String get logWithPhoto => 'Log Manually with this Photo';

  @override
  String get apiKeyMissing => 'API Key Missing';

  @override
  String get apiKeyMissingDesc =>
      'A valid API key is required to scan photos. Please go to settings and add your API Key.';

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
  String get scanningTitle => 'Analyzing Food with AI...';

  @override
  String get scanningDesc =>
      'Estimating weights, portions, and total nutritional content. This may take a few seconds.';

  @override
  String get aiError => 'AI Scanner Error';

  @override
  String aiErrorDesc(Object error) {
    return 'Failed to analyze image. Please ensure your API Key is valid and internet connection is active.\n\nError details: $error';
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
  String get templateAsNew => 'New';

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
  String get apiCredentials => 'AI API Credentials';

  @override
  String get apiCredentialsDesc =>
      'The AI Meal Scanner requires a API Key. Your key is saved locally in private app settings.';

  @override
  String get enterApiKey => 'Enter your API credential key';

  @override
  String get apiKeyLabel => 'API Authorization Key';

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
      'Permanently erase data or restore database/settings backups.';

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
  String get exportSectionTitle => 'Backup Center';

  @override
  String get exportSectionDesc =>
      'Export your SQLite database or local app settings.';

  @override
  String get exportDbBtn => 'Export Database';

  @override
  String get exportSettingsBtn => 'Export Settings';

  @override
  String get dbExported => 'Database exported successfully.';

  @override
  String get settingsExported => 'Settings exported successfully.';

  @override
  String settingsExportFailed(String error) {
    return 'Settings export failed: $error';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Settings import failed: $error';
  }

  @override
  String get restoreDbBtn => 'Restore Database';

  @override
  String get restoreSettingsBtn => 'Restore Settings';

  @override
  String get confirmRestore => 'Restore Database?';

  @override
  String get confirmRestoreDesc =>
      'Are you absolutely sure you want to restore this database backup? All your current logged meals and photos will be permanently replaced. This action cannot be undone.';

  @override
  String get confirmRestoreSettings => 'Restore Settings?';

  @override
  String get confirmRestoreSettingsDesc =>
      'Are you absolutely sure you want to restore these settings? This will overwrite your current daily goals, API key, and preferences. This action cannot be undone.';

  @override
  String get noBackupsFound => 'No database backup files found.';

  @override
  String get noSettingsBackupsFound => 'No settings backup files found.';

  @override
  String get selectBackup => 'Select a Database Backup File';

  @override
  String get selectSettingsBackup => 'Select a Settings Backup File';

  @override
  String get dbRestored => 'Database restored successfully.';

  @override
  String get settingsRestored => 'Settings restored successfully.';

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
  String pdfEntriesFollowing(int count) {
    return '$count entries following';
  }

  @override
  String get pdfEntriesLabel => 'Total Entries';

  @override
  String get pdfCalorieTrend => 'Calorie Trend';

  @override
  String get pdfSingleMealReport => 'Nutritional Meal Report';

  @override
  String get pdfNotes => 'AI Analysis & Notes';

  @override
  String get pdfAiConfidence => 'AI Confidence';

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
  String get reEvaluateInstruction =>
      'Correction Prompt (e.g. \'I only ate half\')';

  @override
  String get reEvaluateInstructionHint =>
      'Enter adjustments or what you actually consumed...';

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
  String get favoriteMeals => 'Favorite Meals';

  @override
  String get noFavoritesYet =>
      'No favorite meals yet. Mark a meal as favorite in its details dialog.';

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

  @override
  String get pdfExportedDownloads => 'PDF report exported to Downloads folder!';

  @override
  String pdfExportedTo(String path) {
    return 'PDF report exported to: $path';
  }

  @override
  String pdfExportFailed(String error) {
    return 'PDF generation failed: $error';
  }

  @override
  String get bodyWeightKg => 'Body Weight (kg)';

  @override
  String get bodyWeightTrend => 'Body Weight Trend';

  @override
  String get optionalWeight => 'Body Weight (optional kg)';

  @override
  String get weightShort => 'W';

  @override
  String get aiSettingsTitle => 'AI Vision Configuration';

  @override
  String get aiSettingsDesc =>
      'Configure your preferred AI vision model for meal scanning.';

  @override
  String get aiProviderLabel => 'AI Provider';

  @override
  String get aiModelLabel => 'Vision Model';

  @override
  String get customUrlLabel => 'Custom API Endpoint Base URL';

  @override
  String get customUrlHint => 'e.g. http://localhost:11434/v1';

  @override
  String get customModelHint => 'e.g. llama3.2-vision';

  @override
  String get customModelOption => 'Custom model...';

  @override
  String get customModelRequired => 'Please specify a custom model name';

  @override
  String get customUrlRequired => 'Custom base endpoint URL is required';

  @override
  String get apiKeyRequired => 'API Authorization Key is required';

  @override
  String get validateConnection => 'Validate Connection';

  @override
  String get validateSuccess => 'Credentials are valid!';

  @override
  String validationFailed(String error) {
    return 'Validation failed: $error';
  }

  @override
  String get aiSettingsSaved => 'AI Configuration saved successfully!';

  @override
  String activeAiConfig(String provider, String model) {
    return 'Active: $provider ($model)';
  }

  @override
  String get aiReasoningEffortLabel => 'Reasoning Effort';

  @override
  String get reasoningNone => 'None / Default';

  @override
  String get reasoningLow => 'Low';

  @override
  String get reasoningMedium => 'Medium';

  @override
  String get reasoningHigh => 'High';

  @override
  String get configureAiProvider => 'Configure AI Provider';

  @override
  String get configureAiProviderDesc =>
      'Change AI vision models, endpoints, or keys';

  @override
  String get geminiInfoTitle => 'Get Gemini API Key';

  @override
  String get geminiInfoDesc =>
      'The AI Meal Scanner securely connects to Google\'s Gemini models to estimate calories and portion weights from your food photos.';

  @override
  String get geminiStep1 =>
      '1. Visit Google AI Studio at: https://aistudio.google.com/api-keys';

  @override
  String get geminiStep2 => '2. Sign in with your standard Google account.';

  @override
  String get geminiStep3 => '3. Click the \'Create API Key\' button.';

  @override
  String get geminiStep4 => '4. Copy the generated key and paste it here.';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get apiDisclaimerTitle => 'API & Cost Disclaimer';

  @override
  String get apiDisclaimerLink => 'API Usage & Cost Disclaimer';

  @override
  String get apiDisclaimerDesc =>
      'Please read this important notice regarding the use of your own API keys and connections in this application:';

  @override
  String get apiDisclaimerPoint1Title => 'Cloud Provider Costs';

  @override
  String get apiDisclaimerPoint1Desc =>
      'Using cloud providers (like Google Gemini, OpenAI, Anthropic, or Grok) incurs costs based on your token usage. Even if you start on a free tier, usage limits or automatic billing transitions may apply depending on your provider account settings.';

  @override
  String get apiDisclaimerPoint2Title => 'User Responsibility';

  @override
  String get apiDisclaimerPoint2Desc =>
      'You are solely responsible for managing your API keys, monitoring usage, and any charges or billings generated by your cloud provider accounts. We highly recommend setting up budget alerts and usage limits in your developer console.';

  @override
  String get apiDisclaimerPoint3Title => 'No Creator Liability';

  @override
  String get apiDisclaimerPoint3Desc =>
      'As the creator of this app, I am not responsible for any direct, indirect, or accidental costs, billing surprises, API misuse, service disruptions, or bugs that may occur while using third-party AI models.';

  @override
  String get apiDisclaimerButton => 'I Understand';

  @override
  String get notificationsTitle => 'System Notifications';

  @override
  String get notificationsDesc =>
      'Enable or disable native system notifications in the Android status bar for downloads.';

  @override
  String get enableNotifications => 'Show system notifications';

  @override
  String get gamificationTitle => 'Achievements & Levels';

  @override
  String levelLabel(int lvl) {
    return 'Level $lvl';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String xpToNextLevel(int xp) {
    return '$xp XP to next level';
  }

  @override
  String xpToNextStar(int xp) {
    return '$xp XP to next Star';
  }

  @override
  String currentStreakLabel(int days) {
    return 'Streak: $days Days';
  }

  @override
  String highestStreakLabel(int days) {
    return 'Best: $days Days';
  }

  @override
  String shieldsLabel(int count) {
    return 'Shields: $count';
  }

  @override
  String get badgesTitle => 'Unlocked Badges';

  @override
  String get badgeUnlockedPopup => 'Badge Unlocked!';

  @override
  String get levelUpPopup => 'Level Up!';

  @override
  String levelUpDesc(int lvl, String title) {
    return 'Congratulations! You reached level $lvl - $title!';
  }

  @override
  String get streakShieldEarnedTitle => 'Shield Earned!';

  @override
  String get streakShieldEarnedDesc =>
      'Amazing job! You earned a Streak Protection Shield for a 7-day streak!';

  @override
  String get streakShieldConsumedTitle => 'Shield Active!';

  @override
  String get streakShieldConsumedDesc =>
      'Your streak was saved by a Streak Protection Shield because you exceeded your calorie limit today!';

  @override
  String get streakResetTitle => 'Streak Broken!';

  @override
  String get streakResetDesc =>
      'Your streak has reset. Keep going, consistency is key!';

  @override
  String get badgeZundfunkeTitle => 'Spark';

  @override
  String get badgeZundfunkeDesc =>
      'Completed day 1 under calorie limit. The journey begins!';

  @override
  String get badgeDreifacheDisziplinTitle => 'Threefold Discipline';

  @override
  String get badgeDreifacheDisziplinDesc =>
      'Logged foods and stayed under limit for 3 consecutive days.';

  @override
  String get badgeWochenKoenigTitle => 'Week King';

  @override
  String get badgeWochenKoenigDesc =>
      'The perfect week! Stayed on track 7 consecutive days.';

  @override
  String get lvlCouchPotato => 'Couch-Potato';

  @override
  String get lvlMotivatedBeginner => 'Motivated Beginner';

  @override
  String get lvlHabitHero => 'Habit Hero';

  @override
  String get lvlMetabolismMaster => 'Metabolism Master';

  @override
  String get lvlFitnessApprentice => 'Fitness Apprentice';

  @override
  String get lvlDisciplineAthlete => 'Discipline Athlete';

  @override
  String get lvlEnduranceChampion => 'Endurance Champion';

  @override
  String get lvlNutritionGuru => 'Nutrition Guru';

  @override
  String get lvlVitalityLegend => 'Vitality Legend';

  @override
  String get lvlCalorieNinja => 'Calorie Ninja';

  @override
  String get xpHint => '+10 XP per Meal Logged • +100 XP per Day Complete';

  @override
  String get gamificationSettingsTitle => 'Gamification Loop Settings';

  @override
  String get gamificationSettingsDesc =>
      'Manage your streaks, experience levels, protection shields, and achievement badges.';

  @override
  String get gamificationConfigureBtn => 'Configure Achievements';

  @override
  String get adminTriggersTitle => 'Developer Achievement Controls';

  @override
  String get adminTriggersDesc =>
      'Use these tools to temporarily trigger local notification events and animations to test correct visual rendering.';

  @override
  String get btnTriggerConfetti => 'Trigger Confetti';

  @override
  String get btnTriggerLevelUp => 'Trigger Level Up';

  @override
  String get btnTriggerBadgeZund => 'Unlock Spark Badge';

  @override
  String get btnTriggerBadgeThree => 'Unlock 3-Day Badge';

  @override
  String get btnTriggerBadgeWeek => 'Unlock Week King';

  @override
  String get btnTriggerShieldEarn => 'Earn Shield Dialog';

  @override
  String get btnTriggerShieldCons => 'Use Shield Dialog';

  @override
  String get btnTriggerStreakReset => 'Reset Streak Dialog';

  @override
  String get toggleGamification => 'Enable Gamification Mechanics';

  @override
  String get streakProtection => 'Streak Protection';

  @override
  String get prestigeTitle => 'Prestige Star Earned!';

  @override
  String get prestigeDesc =>
      'Incredible discipline! You surpassed another 1000 XP milestone beyond Level 10. You earned +1 Streak Shield!';

  @override
  String get btnTriggerPrestige => 'Trigger Prestige';

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get aboutTitle => 'About NutriScan';

  @override
  String get aboutSubtitle => 'Your AI-Powered Nutrition Partner';

  @override
  String get aboutDescription =>
      'NutriScan is a modern, privacy-first calorie and macronutrient tracker designed to help you reach your goals with minimal friction. Using advanced AI model integrations, it makes food logging as simple as taking a photo.';

  @override
  String get aboutFeatureAiTitle => 'AI Meal Scanner';

  @override
  String get aboutFeatureAiDesc =>
      'Take photos of your food to instantly analyze calories and macronutrients.';

  @override
  String get aboutFeatureMultiAiTitle => 'Multi-Provider AI';

  @override
  String get aboutFeatureMultiAiDesc =>
      'Integrate with Gemini, OpenAI, Anthropic, or Grok.';

  @override
  String get aboutFeatureGamificationTitle => 'Interactive Streaks';

  @override
  String get aboutFeatureGamificationDesc =>
      'Build habits, unlock levels, and protect your streaks with shields.';

  @override
  String get aboutFeatureOfflineTitle => 'Local & Offline-First';

  @override
  String get aboutFeatureOfflineDesc =>
      'Your data is stored securely in an offline SQLite database on your device.';

  @override
  String get aboutFeaturePdfTitle => 'PDF Summary Reports';

  @override
  String get aboutFeaturePdfDesc =>
      'Compile your nutritional history into beautiful, printable PDF summaries.';

  @override
  String get aboutOpenSource =>
      'Dedicated to healthy living, privacy, and active developer ownership.';
}
