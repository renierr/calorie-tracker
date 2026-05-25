import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NutriScan Calorie Tracker'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'NutriScan Dashboard'**
  String get dashboardTitle;

  /// No description provided for @reloadDatabase.
  ///
  /// In en, this message translates to:
  /// **'Reload Database'**
  String get reloadDatabase;

  /// No description provided for @calorieConsumption.
  ///
  /// In en, this message translates to:
  /// **'Calorie Consumption'**
  String get calorieConsumption;

  /// No description provided for @ofKcal.
  ///
  /// In en, this message translates to:
  /// **'of {goal} kcal'**
  String ofKcal(Object goal);

  /// No description provided for @kcalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} kcal remaining'**
  String kcalRemaining(Object remaining);

  /// No description provided for @kcalOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{over} kcal over budget'**
  String kcalOverBudget(Object over);

  /// No description provided for @macroDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient Distribution'**
  String get macroDistribution;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Lipid Fats'**
  String get fat;

  /// No description provided for @calorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Calorie Trend (7 Days)'**
  String get calorieTrend;

  /// No description provided for @trendGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal} kcal'**
  String trendGoal(Object goal);

  /// No description provided for @dayLogSummary.
  ///
  /// In en, this message translates to:
  /// **'Day Log Summary'**
  String get dayLogSummary;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'{count} logs'**
  String logs(Object count);

  /// No description provided for @noMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged for this day.'**
  String get noMealsLogged;

  /// No description provided for @perGram.
  ///
  /// In en, this message translates to:
  /// **'P: {protein}g  C: {carbs}g  F: {fat}g'**
  String perGram(Object carbs, Object fat, Object protein);

  /// No description provided for @kcalLabel.
  ///
  /// In en, this message translates to:
  /// **'+{calories} kcal'**
  String kcalLabel(Object calories);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Meal Scanner'**
  String get scanTitle;

  /// No description provided for @noPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'No Meal Photo Selected'**
  String get noPhotoSelected;

  /// No description provided for @scanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan a photo to calculate nutrients instantly'**
  String get scanPrompt;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @logManually.
  ///
  /// In en, this message translates to:
  /// **'Log Meal Manually'**
  String get logManually;

  /// No description provided for @contextClue.
  ///
  /// In en, this message translates to:
  /// **'Add Context Clue (Optional)'**
  String get contextClue;

  /// No description provided for @contextHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Two slices of sourdough bread, a whole avocado, and two medium fried eggs.\"'**
  String get contextHint;

  /// No description provided for @scanAndEstimate.
  ///
  /// In en, this message translates to:
  /// **'Scan & Estimate with Gemini'**
  String get scanAndEstimate;

  /// No description provided for @logWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'Log Manually with this Photo'**
  String get logWithPhoto;

  /// No description provided for @apiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key Missing'**
  String get apiKeyMissing;

  /// No description provided for @apiKeyMissingDesc.
  ///
  /// In en, this message translates to:
  /// **'A valid API key is required to scan photos. Please go to settings and add your Gemini API Key.'**
  String get apiKeyMissingDesc;

  /// No description provided for @navigateToSettings.
  ///
  /// In en, this message translates to:
  /// **'Please navigate to settings panel.'**
  String get navigateToSettings;

  /// No description provided for @configureApiKey.
  ///
  /// In en, this message translates to:
  /// **'Configure API Key'**
  String get configureApiKey;

  /// No description provided for @verifyEstimates.
  ///
  /// In en, this message translates to:
  /// **'Verify Nutritional Estimates'**
  String get verifyEstimates;

  /// No description provided for @aiMatch.
  ///
  /// In en, this message translates to:
  /// **'{confidence}% AI Match'**
  String aiMatch(Object confidence);

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'Meal Description'**
  String get mealDescription;

  /// No description provided for @avocadoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Avocado Toast'**
  String get avocadoHint;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates (g)'**
  String get carbsG;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @aiNotes.
  ///
  /// In en, this message translates to:
  /// **'AI Breakdown & Notes'**
  String get aiNotes;

  /// No description provided for @macroHint.
  ///
  /// In en, this message translates to:
  /// **'Macro breakdown...'**
  String get macroHint;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @logAndSave.
  ///
  /// In en, this message translates to:
  /// **'Log & Save Meal'**
  String get logAndSave;

  /// No description provided for @mealDate.
  ///
  /// In en, this message translates to:
  /// **'Meal Date:'**
  String get mealDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pickImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String pickImageFailed(Object error);

  /// No description provided for @provideName.
  ///
  /// In en, this message translates to:
  /// **'Please provide a valid meal name.'**
  String get provideName;

  /// No description provided for @mealLogged.
  ///
  /// In en, this message translates to:
  /// **'Meal logged successfully!'**
  String get mealLogged;

  /// No description provided for @scanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Food with Gemini AI...'**
  String get scanningTitle;

  /// No description provided for @scanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Estimating weights, portions, and total nutritional content. This may take a few seconds.'**
  String get scanningDesc;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI Scanner Error'**
  String get aiError;

  /// No description provided for @aiErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image. Please ensure your Gemini API Key is valid and internet connection is active.\n\nError details: {error}'**
  String aiErrorDesc(Object error);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal History Logs'**
  String get historyTitle;

  /// No description provided for @filterTimeframe.
  ///
  /// In en, this message translates to:
  /// **'Filter Timeframe:'**
  String get filterTimeframe;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @logsInFilter.
  ///
  /// In en, this message translates to:
  /// **'{count} logs in active filter'**
  String logsInFilter(Object count);

  /// No description provided for @compilePdf.
  ///
  /// In en, this message translates to:
  /// **'Compile meals into a nutritional PDF report.'**
  String get compilePdf;

  /// No description provided for @reportPdf.
  ///
  /// In en, this message translates to:
  /// **'Report PDF'**
  String get reportPdf;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this logged meal? This cannot be undone.'**
  String get confirmDeleteDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No History Found'**
  String get noHistory;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Change filters or scan a meal to start logging!'**
  String get noHistoryDesc;

  /// No description provided for @mealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal updated successfully!'**
  String get mealUpdated;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Logged Meal'**
  String get editMeal;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF Summary Report'**
  String get generatePdf;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Header Title'**
  String get reportTitle;

  /// No description provided for @reportComments.
  ///
  /// In en, this message translates to:
  /// **'Report Explanations / Comments'**
  String get reportComments;

  /// No description provided for @addComments.
  ///
  /// In en, this message translates to:
  /// **'Add summary comments...'**
  String get addComments;

  /// No description provided for @includePhotos.
  ///
  /// In en, this message translates to:
  /// **'Include Photo Album'**
  String get includePhotos;

  /// No description provided for @generatePdfBtn.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdfBtn;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF Report...'**
  String get generatingPdf;

  /// No description provided for @generatingMealPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating individual meal PDF...'**
  String get generatingMealPdf;

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted.'**
  String get mealDeleted;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories: {calories} kcal'**
  String caloriesLabel(Object calories);

  /// No description provided for @macroPerGram.
  ///
  /// In en, this message translates to:
  /// **'P: {protein}g  •  C: {carbs}g  •  F: {fat}g'**
  String macroPerGram(Object carbs, Object fat, Object protein);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal & API Settings'**
  String get settingsTitle;

  /// No description provided for @apiCredentials.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI API Credentials'**
  String get apiCredentials;

  /// No description provided for @apiCredentialsDesc.
  ///
  /// In en, this message translates to:
  /// **'The AI Meal Scanner requires a Google Gemini API Key. Your key is saved locally in private app settings.'**
  String get apiCredentialsDesc;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API Key'**
  String get enterApiKey;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key'**
  String get apiKeyLabel;

  /// No description provided for @dailyTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutritional Targets'**
  String get dailyTargets;

  /// No description provided for @calorieBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Budget (kcal)'**
  String get calorieBudget;

  /// No description provided for @calorieHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2000'**
  String get calorieHint;

  /// No description provided for @proteinHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 130'**
  String get proteinHint;

  /// No description provided for @carbsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 220'**
  String get carbsHint;

  /// No description provided for @fatHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 70'**
  String get fatHint;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone & Maintenance'**
  String get dangerZone;

  /// No description provided for @dangerDesc.
  ///
  /// In en, this message translates to:
  /// **'Clearing your database will permanently remove all tracked foods, calorie metrics, and meal photos from SQLite. This action is irreversible.'**
  String get dangerDesc;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear All Food Logs History'**
  String get clearHistory;

  /// No description provided for @eraseAll.
  ///
  /// In en, this message translates to:
  /// **'Erase All Data?'**
  String get eraseAll;

  /// No description provided for @eraseAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to permanently clear the SQLite database? This deletes all your logged meal stats, photos, and historical progress. This action cannot be undone.'**
  String get eraseAllDesc;

  /// No description provided for @permanentlyErase.
  ///
  /// In en, this message translates to:
  /// **'Permanently Erase Database'**
  String get permanentlyErase;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// No description provided for @prefsSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully!'**
  String get prefsSaved;

  /// No description provided for @dbCleared.
  ///
  /// In en, this message translates to:
  /// **'Database log history cleared.'**
  String get dbCleared;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @exportDb.
  ///
  /// In en, this message translates to:
  /// **'Export SQLite Database'**
  String get exportDb;

  /// No description provided for @exportDbDesc.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of the database. On Desktop, a save dialog will open. On Android, the copy is stored in your device\'s Android/data folder for backup.'**
  String get exportDbDesc;

  /// No description provided for @exportDbBtn.
  ///
  /// In en, this message translates to:
  /// **'Download Database Copy'**
  String get exportDbBtn;

  /// No description provided for @dbExported.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully.'**
  String get dbExported;

  /// No description provided for @restoreDb.
  ///
  /// In en, this message translates to:
  /// **'Restore SQLite Database'**
  String get restoreDb;

  /// No description provided for @restoreDbDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore a previous backup of your complete database. This will overwrite all your current meal records.'**
  String get restoreDbDesc;

  /// No description provided for @restoreDbBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore Database Backup'**
  String get restoreDbBtn;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Database?'**
  String get confirmRestore;

  /// No description provided for @confirmRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to restore this database backup? All your current logged meals and photos will be permanently replaced. This action cannot be undone.'**
  String get confirmRestoreDesc;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No database backup files found.'**
  String get noBackupsFound;

  /// No description provided for @selectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select a Backup File'**
  String get selectBackup;

  /// No description provided for @dbRestored.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully.'**
  String get dbRestored;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sidebarDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get sidebarDashboard;

  /// No description provided for @sidebarScan.
  ///
  /// In en, this message translates to:
  /// **'AI Food Scan'**
  String get sidebarScan;

  /// No description provided for @sidebarHistory.
  ///
  /// In en, this message translates to:
  /// **'Meal History'**
  String get sidebarHistory;

  /// No description provided for @sidebarSettings.
  ///
  /// In en, this message translates to:
  /// **'Goal Settings'**
  String get sidebarSettings;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSettingsCompact.
  ///
  /// In en, this message translates to:
  /// **'Prefs'**
  String get navSettingsCompact;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileName;

  /// No description provided for @profileStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline User'**
  String get profileStatus;

  /// No description provided for @pdfDailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Nutritional Summary'**
  String get pdfDailySummary;

  /// No description provided for @pdfAnalysisSummary.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Analysis Summary'**
  String get pdfAnalysisSummary;

  /// No description provided for @pdfLoggedOn.
  ///
  /// In en, this message translates to:
  /// **'Logged on: {date}'**
  String pdfLoggedOn(Object date);

  /// No description provided for @pdfDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String pdfDateRange(Object date);

  /// No description provided for @pdfRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Range: {start} - {end}'**
  String pdfRangeCustom(Object end, Object start);

  /// No description provided for @pdfAllTime.
  ///
  /// In en, this message translates to:
  /// **'All-Time Logs'**
  String get pdfAllTime;

  /// No description provided for @pdfRange7Days.
  ///
  /// In en, this message translates to:
  /// **'Range: Last 7 Days'**
  String get pdfRange7Days;

  /// No description provided for @pdfActiveFilter.
  ///
  /// In en, this message translates to:
  /// **'Active Filter Range'**
  String get pdfActiveFilter;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @importMealsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} meals.'**
  String importMealsSuccess(int count);

  /// No description provided for @importMealsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to import meals: {error}'**
  String importMealsError(String error);

  /// No description provided for @exportMealsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meals exported successfully.'**
  String get exportMealsSuccess;

  /// No description provided for @exportMealsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String exportMealsError(String error);

  /// No description provided for @selectMeals.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectMeals;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @reEvaluate.
  ///
  /// In en, this message translates to:
  /// **'Re-Evaluate'**
  String get reEvaluate;

  /// No description provided for @reEvaluating.
  ///
  /// In en, this message translates to:
  /// **'Re-Evaluating...'**
  String get reEvaluating;

  /// No description provided for @reEvaluationError.
  ///
  /// In en, this message translates to:
  /// **'Re-Evaluation failed: {error}'**
  String reEvaluationError(String error);

  /// No description provided for @reEvaluationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal re-evaluated successfully!'**
  String get reEvaluationSuccess;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Settings'**
  String get syncSettings;

  /// No description provided for @syncSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure your backend server connection to backup and synchronize your meal database across multiple devices.'**
  String get syncSettingsDesc;

  /// No description provided for @syncServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Sync Server URL'**
  String get syncServerUrl;

  /// No description provided for @syncServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. http://localhost:3000'**
  String get syncServerUrlHint;

  /// No description provided for @syncUserId.
  ///
  /// In en, this message translates to:
  /// **'Sync User ID'**
  String get syncUserId;

  /// No description provided for @syncUserIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. user-1'**
  String get syncUserIdHint;

  /// No description provided for @syncNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Sync Database Now'**
  String get syncNowBtn;

  /// No description provided for @syncingStatus.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing with server...'**
  String get syncingStatus;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed! Pulled: {pulled}, Pushed: {pushed}'**
  String syncSuccess(int pulled, int pushed);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @lastSyncedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Synced: {time}'**
  String lastSyncedLabel(String time);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never Synced'**
  String get neverSynced;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @gitHash.
  ///
  /// In en, this message translates to:
  /// **'Git Hash: {hash}'**
  String gitHash(String hash);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
