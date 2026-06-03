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
  /// **'No logs for this day.'**
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
  /// **'Track Activity'**
  String get scanTitle;

  /// No description provided for @noPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'No Photo Selected'**
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
  /// **'Log Manually'**
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
  /// **'Scan & Estimate with AI'**
  String get scanAndEstimate;

  /// No description provided for @logWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'Log Manually with this Photo'**
  String get logWithPhoto;

  /// No description provided for @apiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'API Key Missing'**
  String get apiKeyMissing;

  /// No description provided for @apiKeyMissingDesc.
  ///
  /// In en, this message translates to:
  /// **'A valid API key is required to scan photos. Please go to settings and add your API Key.'**
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
  /// **'Description'**
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
  /// **'Log & Save'**
  String get logAndSave;

  /// No description provided for @mealDate.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
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
  /// **'Please provide a valid name.'**
  String get provideName;

  /// No description provided for @mealLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged successfully!'**
  String get mealLogged;

  /// No description provided for @scanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Food with AI...'**
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
  /// **'Failed to analyze image. Please ensure your API Key is valid and internet connection is active.\n\nError details: {error}'**
  String aiErrorDesc(Object error);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History Logs'**
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
  /// **'Compile entries into a nutritional PDF report.'**
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

  /// No description provided for @templateAsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get templateAsNew;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this logged entry? This cannot be undone.'**
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
  /// **'Change filters or log an entry to start!'**
  String get noHistoryDesc;

  /// No description provided for @mealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entry updated successfully!'**
  String get mealUpdated;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Logged Entry'**
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
  /// **'Generating individual entry PDF...'**
  String get generatingMealPdf;

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted.'**
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
  /// **'AI API Credentials'**
  String get apiCredentials;

  /// No description provided for @apiCredentialsDesc.
  ///
  /// In en, this message translates to:
  /// **'The AI Vision Scanner requires a API Key. Your key is saved locally in private app settings.'**
  String get apiCredentialsDesc;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your API credential key'**
  String get enterApiKey;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Authorization Key'**
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
  /// **'Permanently erase data or restore database/settings backups.'**
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
  /// **'Are you absolutely sure you want to permanently clear the SQLite database? This deletes all your logged stats, photos, and historical progress. This action cannot be undone.'**
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

  /// No description provided for @exportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Center'**
  String get exportSectionTitle;

  /// No description provided for @exportSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your SQLite database or local app settings.'**
  String get exportSectionDesc;

  /// No description provided for @exportDbBtn.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportDbBtn;

  /// No description provided for @exportSettingsBtn.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettingsBtn;

  /// No description provided for @dbExported.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully.'**
  String get dbExported;

  /// No description provided for @settingsExported.
  ///
  /// In en, this message translates to:
  /// **'Settings exported successfully.'**
  String get settingsExported;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings import failed: {error}'**
  String settingsImportFailed(String error);

  /// No description provided for @restoreDbBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore Database'**
  String get restoreDbBtn;

  /// No description provided for @restoreSettingsBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore Settings'**
  String get restoreSettingsBtn;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Database?'**
  String get confirmRestore;

  /// No description provided for @confirmRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to restore this database backup? All your current logged entries and photos will be permanently replaced. This action cannot be undone.'**
  String get confirmRestoreDesc;

  /// No description provided for @confirmRestoreSettings.
  ///
  /// In en, this message translates to:
  /// **'Restore Settings?'**
  String get confirmRestoreSettings;

  /// No description provided for @confirmRestoreSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to restore these settings? This will overwrite your current daily goals, API key, and preferences. This action cannot be undone.'**
  String get confirmRestoreSettingsDesc;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No database backup files found.'**
  String get noBackupsFound;

  /// No description provided for @noSettingsBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No settings backup files found.'**
  String get noSettingsBackupsFound;

  /// No description provided for @selectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select a Database Backup File'**
  String get selectBackup;

  /// No description provided for @selectSettingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Select a Settings Backup File'**
  String get selectSettingsBackup;

  /// No description provided for @dbRestored.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully.'**
  String get dbRestored;

  /// No description provided for @settingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Settings restored successfully.'**
  String get settingsRestored;

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
  /// **'Track Activity'**
  String get sidebarScan;

  /// No description provided for @sidebarHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
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
  /// **'Track'**
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

  /// No description provided for @pdfEntriesFollowing.
  ///
  /// In en, this message translates to:
  /// **'{count} entries following'**
  String pdfEntriesFollowing(int count);

  /// No description provided for @pdfEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Entries'**
  String get pdfEntriesLabel;

  /// No description provided for @pdfCalorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Calorie Trend'**
  String get pdfCalorieTrend;

  /// No description provided for @pdfSingleMealReport.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Log Report'**
  String get pdfSingleMealReport;

  /// No description provided for @pdfNotes.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis & Notes'**
  String get pdfNotes;

  /// No description provided for @pdfAiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get pdfAiConfidence;

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
  /// **'Successfully imported {count} entries.'**
  String importMealsSuccess(int count);

  /// No description provided for @importMealsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to import entries: {error}'**
  String importMealsError(String error);

  /// No description provided for @exportMealsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Entries exported successfully.'**
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
  /// **'Entry re-evaluated successfully!'**
  String get reEvaluationSuccess;

  /// No description provided for @reEvaluateInstruction.
  ///
  /// In en, this message translates to:
  /// **'Correction Prompt (e.g. \'I only ate half\')'**
  String get reEvaluateInstruction;

  /// No description provided for @reEvaluateInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter adjustments or what you actually consumed...'**
  String get reEvaluateInstructionHint;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Settings'**
  String get syncSettings;

  /// No description provided for @syncSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure your backend server connection to backup and synchronize your database across multiple devices.'**
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

  /// No description provided for @favoriteMeals.
  ///
  /// In en, this message translates to:
  /// **'Favorite Entries'**
  String get favoriteMeals;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite entries yet. Mark as favorite in its details dialog.'**
  String get noFavoritesYet;

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

  /// No description provided for @imageSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully!'**
  String get imageSavedSuccess;

  /// No description provided for @imageSavedDownloads.
  ///
  /// In en, this message translates to:
  /// **'Image saved to Downloads folder!'**
  String get imageSavedDownloads;

  /// No description provided for @imageSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Image saved to: {path}'**
  String imageSavedTo(String path);

  /// No description provided for @imageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image: {error}'**
  String imageSaveFailed(String error);

  /// No description provided for @dbExportedDownloads.
  ///
  /// In en, this message translates to:
  /// **'Database exported to Downloads folder!'**
  String get dbExportedDownloads;

  /// No description provided for @dbExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Database exported to: {path}'**
  String dbExportedTo(String path);

  /// No description provided for @dbExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Database export failed: {error}'**
  String dbExportFailed(String error);

  /// No description provided for @pdfExportedDownloads.
  ///
  /// In en, this message translates to:
  /// **'PDF report exported to Downloads folder!'**
  String get pdfExportedDownloads;

  /// No description provided for @pdfExportedTo.
  ///
  /// In en, this message translates to:
  /// **'PDF report exported to: {path}'**
  String pdfExportedTo(String path);

  /// No description provided for @pdfExportFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF generation failed: {error}'**
  String pdfExportFailed(String error);

  /// No description provided for @bodyWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Body Weight (kg)'**
  String get bodyWeightKg;

  /// No description provided for @bodyWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Body Weight Trend'**
  String get bodyWeightTrend;

  /// No description provided for @optionalWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight (optional kg)'**
  String get optionalWeight;

  /// No description provided for @weightShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weightShort;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Vision Configuration'**
  String get aiSettingsTitle;

  /// No description provided for @aiSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure your preferred AI vision model for photo scanning.'**
  String get aiSettingsDesc;

  /// No description provided for @fallbackProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Fallback Provider'**
  String get fallbackProviderLabel;

  /// No description provided for @fallbackProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a fallback provider that will be automatically suggested if the active AI scanner throws an error. A provider is only valid as fallback if it has a configured API key/credentials.'**
  String get fallbackProviderDesc;

  /// No description provided for @fallbackNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get fallbackNone;

  /// No description provided for @aiFallbackPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Try Fallback Provider?'**
  String get aiFallbackPromptTitle;

  /// No description provided for @aiFallbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Active AI scan failed. Would you like to try the fallback provider {fallbackName}?'**
  String aiFallbackPrompt(String fallbackName);

  /// No description provided for @aiProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get aiProviderLabel;

  /// No description provided for @aiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vision Model'**
  String get aiModelLabel;

  /// No description provided for @customUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom API Endpoint Base URL'**
  String get customUrlLabel;

  /// No description provided for @customUrlHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. http://localhost:11434/v1'**
  String get customUrlHint;

  /// No description provided for @customModelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. llama3.2-vision'**
  String get customModelHint;

  /// No description provided for @customModelOption.
  ///
  /// In en, this message translates to:
  /// **'Custom model...'**
  String get customModelOption;

  /// No description provided for @customModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please specify a custom model name'**
  String get customModelRequired;

  /// No description provided for @customUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom base endpoint URL is required'**
  String get customUrlRequired;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API Authorization Key is required'**
  String get apiKeyRequired;

  /// No description provided for @validateConnection.
  ///
  /// In en, this message translates to:
  /// **'Validate Connection'**
  String get validateConnection;

  /// No description provided for @validateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Credentials are valid!'**
  String get validateSuccess;

  /// No description provided for @validationFailed.
  ///
  /// In en, this message translates to:
  /// **'Validation failed: {error}'**
  String validationFailed(String error);

  /// No description provided for @aiSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'AI Configuration saved successfully!'**
  String get aiSettingsSaved;

  /// No description provided for @activeAiConfig.
  ///
  /// In en, this message translates to:
  /// **'Active: {provider} ({model})'**
  String activeAiConfig(String provider, String model);

  /// No description provided for @aiReasoningEffortLabel.
  ///
  /// In en, this message translates to:
  /// **'Reasoning Effort'**
  String get aiReasoningEffortLabel;

  /// No description provided for @reasoningNone.
  ///
  /// In en, this message translates to:
  /// **'None / Default'**
  String get reasoningNone;

  /// No description provided for @reasoningLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reasoningLow;

  /// No description provided for @reasoningMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get reasoningMedium;

  /// No description provided for @reasoningHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get reasoningHigh;

  /// No description provided for @configureAiProvider.
  ///
  /// In en, this message translates to:
  /// **'Configure AI Provider'**
  String get configureAiProvider;

  /// No description provided for @configureAiProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'Change AI vision models, endpoints, or keys'**
  String get configureAiProviderDesc;

  /// No description provided for @geminiInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Gemini API Key'**
  String get geminiInfoTitle;

  /// No description provided for @geminiInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'The AI Vision Scanner securely connects to Google\'s Gemini models to estimate calories and portion weights from your food photos.'**
  String get geminiInfoDesc;

  /// No description provided for @geminiStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Visit Google AI Studio at: https://aistudio.google.com/api-keys'**
  String get geminiStep1;

  /// No description provided for @geminiStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Sign in with your standard Google account.'**
  String get geminiStep2;

  /// No description provided for @geminiStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Click the \'Create API Key\' button.'**
  String get geminiStep3;

  /// No description provided for @geminiStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Copy the generated key and paste it here.'**
  String get geminiStep4;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @apiDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'API & Cost Disclaimer'**
  String get apiDisclaimerTitle;

  /// No description provided for @apiDisclaimerLink.
  ///
  /// In en, this message translates to:
  /// **'API Usage & Cost Disclaimer'**
  String get apiDisclaimerLink;

  /// No description provided for @apiDisclaimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Please read this important notice regarding the use of your own API keys and connections in this application:'**
  String get apiDisclaimerDesc;

  /// No description provided for @apiDisclaimerPoint1Title.
  ///
  /// In en, this message translates to:
  /// **'Cloud Provider Costs'**
  String get apiDisclaimerPoint1Title;

  /// No description provided for @apiDisclaimerPoint1Desc.
  ///
  /// In en, this message translates to:
  /// **'Using cloud providers (like Google Gemini, OpenAI, Anthropic, or Grok) incurs costs based on your token usage. Even if you start on a free tier, usage limits or automatic billing transitions may apply depending on your provider account settings.'**
  String get apiDisclaimerPoint1Desc;

  /// No description provided for @apiDisclaimerPoint2Title.
  ///
  /// In en, this message translates to:
  /// **'User Responsibility'**
  String get apiDisclaimerPoint2Title;

  /// No description provided for @apiDisclaimerPoint2Desc.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for managing your API keys, monitoring usage, and any charges or billings generated by your cloud provider accounts. We highly recommend setting up budget alerts and usage limits in your developer console.'**
  String get apiDisclaimerPoint2Desc;

  /// No description provided for @apiDisclaimerPoint3Title.
  ///
  /// In en, this message translates to:
  /// **'No Creator Liability'**
  String get apiDisclaimerPoint3Title;

  /// No description provided for @apiDisclaimerPoint3Desc.
  ///
  /// In en, this message translates to:
  /// **'As the creator of this app, I am not responsible for any direct, indirect, or accidental costs, billing surprises, API misuse, service disruptions, or bugs that may occur while using third-party AI models.'**
  String get apiDisclaimerPoint3Desc;

  /// No description provided for @apiDisclaimerButton.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get apiDisclaimerButton;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable native system notifications in the Android status bar for downloads.'**
  String get notificationsDesc;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Show system notifications'**
  String get enableNotifications;

  /// No description provided for @gamificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Levels'**
  String get gamificationTitle;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {lvl}'**
  String levelLabel(int lvl);

  /// No description provided for @xpLabel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpLabel(int xp);

  /// No description provided for @xpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to next level'**
  String xpToNextLevel(int xp);

  /// No description provided for @xpToNextStar.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to next Star'**
  String xpToNextStar(int xp);

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} Days'**
  String currentStreakLabel(int days);

  /// No description provided for @highestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best: {days} Days'**
  String highestStreakLabel(int days);

  /// No description provided for @shieldsLabel.
  ///
  /// In en, this message translates to:
  /// **'Shields: {count}'**
  String shieldsLabel(int count);

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocked Badges'**
  String get badgesTitle;

  /// No description provided for @badgeUnlockedPopup.
  ///
  /// In en, this message translates to:
  /// **'Badge Unlocked!'**
  String get badgeUnlockedPopup;

  /// No description provided for @levelUpPopup.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get levelUpPopup;

  /// No description provided for @levelUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You reached level {lvl} - {title}!'**
  String levelUpDesc(int lvl, String title);

  /// No description provided for @streakShieldEarnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shield Earned!'**
  String get streakShieldEarnedTitle;

  /// No description provided for @streakShieldEarnedDesc.
  ///
  /// In en, this message translates to:
  /// **'Amazing job! You earned a Streak Protection Shield for a 7-day streak!'**
  String get streakShieldEarnedDesc;

  /// No description provided for @streakShieldConsumedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shield Active!'**
  String get streakShieldConsumedTitle;

  /// No description provided for @streakShieldConsumedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your streak was saved by a Streak Protection Shield because you exceeded your calorie limit today!'**
  String get streakShieldConsumedDesc;

  /// No description provided for @streakResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Broken!'**
  String get streakResetTitle;

  /// No description provided for @streakResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Your streak has reset. Keep going, consistency is key!'**
  String get streakResetDesc;

  /// No description provided for @badgeZundfunkeTitle.
  ///
  /// In en, this message translates to:
  /// **'Spark'**
  String get badgeZundfunkeTitle;

  /// No description provided for @badgeZundfunkeDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed day 1 under calorie limit. The journey begins!'**
  String get badgeZundfunkeDesc;

  /// No description provided for @badgeDreifacheDisziplinTitle.
  ///
  /// In en, this message translates to:
  /// **'Threefold Discipline'**
  String get badgeDreifacheDisziplinTitle;

  /// No description provided for @badgeDreifacheDisziplinDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged foods and stayed under limit for 3 consecutive days.'**
  String get badgeDreifacheDisziplinDesc;

  /// No description provided for @badgeWochenKoenigTitle.
  ///
  /// In en, this message translates to:
  /// **'Week King'**
  String get badgeWochenKoenigTitle;

  /// No description provided for @badgeWochenKoenigDesc.
  ///
  /// In en, this message translates to:
  /// **'The perfect week! Stayed on track 7 consecutive days.'**
  String get badgeWochenKoenigDesc;

  /// No description provided for @lvlCouchPotato.
  ///
  /// In en, this message translates to:
  /// **'Couch-Potato'**
  String get lvlCouchPotato;

  /// No description provided for @lvlMotivatedBeginner.
  ///
  /// In en, this message translates to:
  /// **'Motivated Beginner'**
  String get lvlMotivatedBeginner;

  /// No description provided for @lvlHabitHero.
  ///
  /// In en, this message translates to:
  /// **'Habit Hero'**
  String get lvlHabitHero;

  /// No description provided for @lvlMetabolismMaster.
  ///
  /// In en, this message translates to:
  /// **'Metabolism Master'**
  String get lvlMetabolismMaster;

  /// No description provided for @lvlFitnessApprentice.
  ///
  /// In en, this message translates to:
  /// **'Fitness Apprentice'**
  String get lvlFitnessApprentice;

  /// No description provided for @lvlDisciplineAthlete.
  ///
  /// In en, this message translates to:
  /// **'Discipline Athlete'**
  String get lvlDisciplineAthlete;

  /// No description provided for @lvlEnduranceChampion.
  ///
  /// In en, this message translates to:
  /// **'Endurance Champion'**
  String get lvlEnduranceChampion;

  /// No description provided for @lvlNutritionGuru.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Guru'**
  String get lvlNutritionGuru;

  /// No description provided for @lvlVitalityLegend.
  ///
  /// In en, this message translates to:
  /// **'Vitality Legend'**
  String get lvlVitalityLegend;

  /// No description provided for @lvlCalorieNinja.
  ///
  /// In en, this message translates to:
  /// **'Calorie Ninja'**
  String get lvlCalorieNinja;

  /// No description provided for @xpHint.
  ///
  /// In en, this message translates to:
  /// **'+10 XP per Entry Logged • +100 XP per Day Complete'**
  String get xpHint;

  /// No description provided for @gamificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Gamification Loop Settings'**
  String get gamificationSettingsTitle;

  /// No description provided for @gamificationSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your streaks, experience levels, protection shields, and achievement badges.'**
  String get gamificationSettingsDesc;

  /// No description provided for @gamificationConfigureBtn.
  ///
  /// In en, this message translates to:
  /// **'Configure Achievements'**
  String get gamificationConfigureBtn;

  /// No description provided for @adminTriggersTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Achievement Controls'**
  String get adminTriggersTitle;

  /// No description provided for @adminTriggersDesc.
  ///
  /// In en, this message translates to:
  /// **'Use these tools to temporarily trigger local notification events and animations to test correct visual rendering.'**
  String get adminTriggersDesc;

  /// No description provided for @btnTriggerConfetti.
  ///
  /// In en, this message translates to:
  /// **'Trigger Confetti'**
  String get btnTriggerConfetti;

  /// No description provided for @btnTriggerLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Trigger Level Up'**
  String get btnTriggerLevelUp;

  /// No description provided for @btnTriggerBadgeZund.
  ///
  /// In en, this message translates to:
  /// **'Unlock Spark Badge'**
  String get btnTriggerBadgeZund;

  /// No description provided for @btnTriggerBadgeThree.
  ///
  /// In en, this message translates to:
  /// **'Unlock 3-Day Badge'**
  String get btnTriggerBadgeThree;

  /// No description provided for @btnTriggerBadgeWeek.
  ///
  /// In en, this message translates to:
  /// **'Unlock Week King'**
  String get btnTriggerBadgeWeek;

  /// No description provided for @btnTriggerShieldEarn.
  ///
  /// In en, this message translates to:
  /// **'Earn Shield Dialog'**
  String get btnTriggerShieldEarn;

  /// No description provided for @btnTriggerShieldCons.
  ///
  /// In en, this message translates to:
  /// **'Use Shield Dialog'**
  String get btnTriggerShieldCons;

  /// No description provided for @btnTriggerStreakReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Streak Dialog'**
  String get btnTriggerStreakReset;

  /// No description provided for @btnResetAckBadges.
  ///
  /// In en, this message translates to:
  /// **'Reset Seen Awards'**
  String get btnResetAckBadges;

  /// No description provided for @toggleGamification.
  ///
  /// In en, this message translates to:
  /// **'Enable Gamification Mechanics'**
  String get toggleGamification;

  /// No description provided for @streakProtection.
  ///
  /// In en, this message translates to:
  /// **'Streak Protection'**
  String get streakProtection;

  /// No description provided for @prestigeTitle.
  ///
  /// In en, this message translates to:
  /// **'Prestige Star Earned!'**
  String get prestigeTitle;

  /// No description provided for @prestigeDesc.
  ///
  /// In en, this message translates to:
  /// **'Incredible discipline! You surpassed another 1000 XP milestone beyond Level 10. You earned +1 Streak Shield!'**
  String get prestigeDesc;

  /// No description provided for @btnTriggerPrestige.
  ///
  /// In en, this message translates to:
  /// **'Trigger Prestige'**
  String get btnTriggerPrestige;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About NutriScan'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI-Powered Nutrition Partner'**
  String get aboutSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'NutriScan is a modern, privacy-first calorie and macronutrient tracker designed to help you reach your goals with minimal friction. Using advanced AI model integrations, it makes food logging as simple as taking a photo.'**
  String get aboutDescription;

  /// No description provided for @aboutFeatureAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Vision Scanner'**
  String get aboutFeatureAiTitle;

  /// No description provided for @aboutFeatureAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Take photos of your food to instantly analyze calories and macronutrients.'**
  String get aboutFeatureAiDesc;

  /// No description provided for @aboutFeatureMultiAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Provider AI'**
  String get aboutFeatureMultiAiTitle;

  /// No description provided for @aboutFeatureMultiAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Integrate with Gemini, OpenAI, Anthropic, or Grok.'**
  String get aboutFeatureMultiAiDesc;

  /// No description provided for @aboutFeatureGamificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive Streaks'**
  String get aboutFeatureGamificationTitle;

  /// No description provided for @aboutFeatureGamificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Build habits, unlock levels, and protect your streaks with shields.'**
  String get aboutFeatureGamificationDesc;

  /// No description provided for @aboutFeatureOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Local & Offline-First'**
  String get aboutFeatureOfflineTitle;

  /// No description provided for @aboutFeatureOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely in an offline SQLite database on your device.'**
  String get aboutFeatureOfflineDesc;

  /// No description provided for @aboutFeaturePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Summary Reports'**
  String get aboutFeaturePdfTitle;

  /// No description provided for @aboutFeaturePdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Compile your nutritional history into beautiful, printable PDF summaries.'**
  String get aboutFeaturePdfDesc;

  /// No description provided for @aboutOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Dedicated to healthy living, privacy, and active developer ownership.'**
  String get aboutOpenSource;

  /// No description provided for @editActivityDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity Details'**
  String get editActivityDetails;

  /// No description provided for @activityName.
  ///
  /// In en, this message translates to:
  /// **'Activity / Exercise Name'**
  String get activityName;

  /// No description provided for @caloriesBurnedKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned (kcal)'**
  String get caloriesBurnedKcal;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @activityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Activity updated successfully'**
  String get activityUpdated;

  /// No description provided for @verifyActivityDetails.
  ///
  /// In en, this message translates to:
  /// **'Verify Activity Details'**
  String get verifyActivityDetails;

  /// No description provided for @activityHint.
  ///
  /// In en, this message translates to:
  /// **'Running, Swimming, Cycling...'**
  String get activityHint;

  /// No description provided for @activityLogged.
  ///
  /// In en, this message translates to:
  /// **'Activity logged successfully'**
  String get activityLogged;

  /// No description provided for @activitiesLogged.
  ///
  /// In en, this message translates to:
  /// **'Activities Logged'**
  String get activitiesLogged;

  /// No description provided for @intakeCalories.
  ///
  /// In en, this message translates to:
  /// **'Intake Calories'**
  String get intakeCalories;

  /// No description provided for @mealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLogged;

  /// No description provided for @netCalories.
  ///
  /// In en, this message translates to:
  /// **'Net Calories'**
  String get netCalories;

  /// No description provided for @burned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burned;

  /// No description provided for @logsCount.
  ///
  /// In en, this message translates to:
  /// **'Logs Count'**
  String get logsCount;

  /// No description provided for @allLogs.
  ///
  /// In en, this message translates to:
  /// **'All Logs'**
  String get allLogs;

  /// No description provided for @mealsOnly.
  ///
  /// In en, this message translates to:
  /// **'Meals Only'**
  String get mealsOnly;

  /// No description provided for @activitiesOnly.
  ///
  /// In en, this message translates to:
  /// **'Activities Only'**
  String get activitiesOnly;

  /// No description provided for @logTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Log Type Filter'**
  String get logTypeFilter;

  /// No description provided for @burnExercise.
  ///
  /// In en, this message translates to:
  /// **'Burn / Exercise'**
  String get burnExercise;

  /// No description provided for @logActivity.
  ///
  /// In en, this message translates to:
  /// **'Log Activity'**
  String get logActivity;

  /// No description provided for @includeInPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Include in PDF Report'**
  String get includeInPdfReport;

  /// No description provided for @intakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake: {calories} kcal'**
  String intakeLabel(int calories);

  /// No description provided for @burnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Burned: {calories} kcal'**
  String burnedLabel(int calories);

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'[Activity] {name}'**
  String activityLabel(String name);

  /// No description provided for @dropZonePrompt.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop photo here or browse'**
  String get dropZonePrompt;

  /// No description provided for @dropZoneHovering.
  ///
  /// In en, this message translates to:
  /// **'Drop your image to start scanning!'**
  String get dropZoneHovering;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste Image'**
  String get pasteFromClipboard;

  /// No description provided for @noImageInClipboard.
  ///
  /// In en, this message translates to:
  /// **'No image found in your clipboard.'**
  String get noImageInClipboard;

  /// No description provided for @imageCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard'**
  String get imageCopiedToClipboard;

  /// No description provided for @failedToCopyImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy image: {error}'**
  String failedToCopyImage(String error);

  /// No description provided for @pasteImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to paste image: {error}'**
  String pasteImageFailed(String error);

  /// No description provided for @readDroppedFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read dropped file: {error}'**
  String readDroppedFileFailed(String error);

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String operationFailed(String error);
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
