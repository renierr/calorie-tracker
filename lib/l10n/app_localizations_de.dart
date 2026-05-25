// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'NutriScan KalorienTracker';

  @override
  String get dashboardTitle => 'NutriScan Dashboard';

  @override
  String get reloadDatabase => 'Datenbank neu laden';

  @override
  String get calorieConsumption => 'Kalorienverbrauch';

  @override
  String ofKcal(Object goal) {
    return 'von $goal kcal';
  }

  @override
  String kcalRemaining(Object remaining) {
    return '$remaining kcal übrig';
  }

  @override
  String kcalOverBudget(Object over) {
    return '$over kcal über dem Limit';
  }

  @override
  String get macroDistribution => 'Makronährstoffverteilung';

  @override
  String get protein => 'Eiweiß';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fat => 'Fette';

  @override
  String get calorieTrend => 'Kalorientrend (7 Tage)';

  @override
  String trendGoal(Object goal) {
    return 'Ziel: $goal kcal';
  }

  @override
  String get dayLogSummary => 'Tagesübersicht';

  @override
  String logs(Object count) {
    return '$count Einträge';
  }

  @override
  String get noMealsLogged => 'Keine Mahlzeiten für diesen Tag.';

  @override
  String perGram(Object carbs, Object fat, Object protein) {
    return 'E: ${protein}g  K: ${carbs}g  F: ${fat}g';
  }

  @override
  String kcalLabel(Object calories) {
    return '+$calories kcal';
  }

  @override
  String get scanTitle => 'KI Lebensmittelscanner';

  @override
  String get noPhotoSelected => 'Kein Foto ausgewählt';

  @override
  String get scanPrompt => 'Foto scannen für sofortige Nährwertanalyse';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Kamera';

  @override
  String get logManually => 'Manuell erfassen';

  @override
  String get contextClue => 'Kontext hinzufügen (optional)';

  @override
  String get contextHint =>
      'z.B. „Zwei Scheiben Sauerteigbrot, eine ganze Avocado und zwei mittlere Spiegeleier.“';

  @override
  String get scanAndEstimate => 'Scannen & mit Gemini analysieren';

  @override
  String get logWithPhoto => 'Mit Foto manuell erfassen';

  @override
  String get apiKeyMissing => 'Gemini API-Schlüssel fehlt';

  @override
  String get apiKeyMissingDesc =>
      'Für die Fotoanalyse wird ein gültiger Gemini API-Schlüssel benötigt. Bitte in den Einstellungen hinterlegen.';

  @override
  String get navigateToSettings => 'Bitte zu den Einstellungen navigieren.';

  @override
  String get configureApiKey => 'API-Schlüssel konfigurieren';

  @override
  String get verifyEstimates => 'Nährwerte überprüfen';

  @override
  String aiMatch(Object confidence) {
    return '$confidence% KI-Übereinstimmung';
  }

  @override
  String get mealDescription => 'Mahlzeitbeschreibung';

  @override
  String get avocadoHint => 'z.B. Avocado Toast';

  @override
  String get caloriesKcal => 'Kalorien (kcal)';

  @override
  String get proteinG => 'Eiweiß (g)';

  @override
  String get carbsG => 'Kohlenhydrate (g)';

  @override
  String get fatG => 'Fett (g)';

  @override
  String get aiNotes => 'KI-Analyse & Notizen';

  @override
  String get macroHint => 'Nährstoffaufschlüsselung...';

  @override
  String get discard => 'Verwerfen';

  @override
  String get logAndSave => 'Speichern & erfassen';

  @override
  String get mealDate => 'Datum der Mahlzeit:';

  @override
  String get notes => 'Notizen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String pickImageFailed(Object error) {
    return 'Fehler beim Laden des Bildes: $error';
  }

  @override
  String get provideName => 'Bitte gib einen gültigen Mahlzeitnamen ein.';

  @override
  String get mealLogged => 'Mahlzeit erfolgreich erfasst!';

  @override
  String get scanningTitle => 'Analyse mit Gemini KI...';

  @override
  String get scanningDesc =>
      'Gewichte, Portionen und Nährstoffe werden berechnet. Dies kann einige Sekunden dauern.';

  @override
  String get aiError => 'KI-Scanner Fehler';

  @override
  String aiErrorDesc(Object error) {
    return 'Bildanalyse fehlgeschlagen. Bitte stelle sicher, dass dein Gemini API-Schlüssel gültig ist und eine Internetverbindung besteht.\n\nFehlerdetails: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get historyTitle => 'Mahlzeitenverlauf';

  @override
  String get filterTimeframe => 'Zeitraum filtern:';

  @override
  String get allTime => 'Alle Einträge';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get last7Days => 'Letzte 7 Tage';

  @override
  String get customRange => 'Benutzerdefiniert';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String logsInFilter(Object count) {
    return '$count Einträge im aktiven Filter';
  }

  @override
  String get compilePdf => 'Mahlzeiten in einen PDF-Bericht umwandeln.';

  @override
  String get reportPdf => 'PDF-Bericht';

  @override
  String get pdf => 'PDF';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmDeleteDesc =>
      'Bist du sicher, dass du diese Mahlzeit endgültig löschen möchtest? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noHistory => 'Kein Verlauf gefunden';

  @override
  String get noHistoryDesc =>
      'Filter ändern oder eine Mahlzeit scannen, um zu beginnen!';

  @override
  String get mealUpdated => 'Mahlzeit erfolgreich aktualisiert!';

  @override
  String get editMeal => 'Mahlzeit bearbeiten';

  @override
  String get generatePdf => 'PDF-Zusammenfassung erstellen';

  @override
  String get reportTitle => 'Berichtstitel';

  @override
  String get reportComments => 'Berichtsanmerkungen';

  @override
  String get addComments => 'Anmerkungen hinzufügen...';

  @override
  String get includePhotos => 'Fotoalbum einfügen';

  @override
  String get generatePdfBtn => 'PDF erstellen';

  @override
  String get generatingPdf => 'PDF-Bericht wird erstellt...';

  @override
  String get generatingMealPdf => 'Einzel-PDF wird erstellt...';

  @override
  String get mealDeleted => 'Mahlzeit gelöscht.';

  @override
  String caloriesLabel(Object calories) {
    return 'Kalorien: $calories kcal';
  }

  @override
  String macroPerGram(Object carbs, Object fat, Object protein) {
    return 'E: ${protein}g  •  K: ${carbs}g  •  F: ${fat}g';
  }

  @override
  String get settingsTitle => 'Ziele & API-Einstellungen';

  @override
  String get apiCredentials => 'Gemini KI API-Zugangsdaten';

  @override
  String get apiCredentialsDesc =>
      'Der KI-Scanner benötigt einen Google Gemini API-Schlüssel. Dein Schlüssel wird lokal in den App-Einstellungen gespeichert.';

  @override
  String get enterApiKey => 'Gemini API-Schlüssel eingeben';

  @override
  String get apiKeyLabel => 'Gemini API-Schlüssel';

  @override
  String get dailyTargets => 'Tägliche Nährstoffziele';

  @override
  String get calorieBudget => 'Tägliches Kalorienbudget (kcal)';

  @override
  String get calorieHint => 'z.B. 2000';

  @override
  String get proteinHint => 'z.B. 130';

  @override
  String get carbsHint => 'z.B. 220';

  @override
  String get fatHint => 'z.B. 70';

  @override
  String get dangerZone => 'Gefahrenzone & Wartung';

  @override
  String get dangerDesc =>
      'Das Zurücksetzen der Datenbank entfernt dauerhaft alle erfassten Lebensmittel, Kalorienmesswerte und Mahlzeitfotos aus SQLite. Diese Aktion ist unwiderruflich.';

  @override
  String get clearHistory => 'Gesamten Verlauf löschen';

  @override
  String get eraseAll => 'Alle Daten löschen?';

  @override
  String get eraseAllDesc =>
      'Bist du absolut sicher, dass du die SQLite-Datenbank dauerhaft löschen möchtest? Dies löscht alle deine Mahlzeiten, Fotos und Verlaufsdaten. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get permanentlyErase => 'Datenbank endgültig löschen';

  @override
  String get savePreferences => 'Einstellungen speichern';

  @override
  String get prefsSaved => 'Einstellungen erfolgreich gespeichert!';

  @override
  String get dbCleared => 'Datenbankverlauf gelöscht.';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get exportDb => 'SQLite-Datenbank exportieren';

  @override
  String get exportDbDesc =>
      'Lade eine Kopie der Datenbank herunter. Auf dem Desktop öffnet sich ein Speicher-Dialog. Auf Android wird sie im Android/data Ordner des Geräts gesichert.';

  @override
  String get exportDbBtn => 'Datenbank-Kopie herunterladen';

  @override
  String get dbExported => 'Datenbank erfolgreich exportiert.';

  @override
  String get restoreDb => 'SQLite-Datenbank wiederherstellen';

  @override
  String get restoreDbDesc =>
      'Stelle eine vorherige Sicherung deiner gesamten Datenbank wieder her. Dies überschreibt alle deine aktuellen Mahlzeiteneinträge.';

  @override
  String get restoreDbBtn => 'Datenbank-Sicherung wiederherstellen';

  @override
  String get confirmRestore => 'Datenbank wiederherstellen?';

  @override
  String get confirmRestoreDesc =>
      'Bist du dir absolut sicher, dass du diese Datenbanksicherung wiederherstellen möchtest? Alle deine aktuellen protokollierten Mahlzeiten und Fotos werden dauerhaft ersetzt. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get noBackupsFound => 'Keine Datenbanksicherungsdateien gefunden.';

  @override
  String get selectBackup => 'Wähle eine Sicherungsdatei';

  @override
  String get dbRestored => 'Datenbank erfolgreich wiederhergestellt.';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeMode => 'Design';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get sidebarDashboard => 'Dashboard';

  @override
  String get sidebarScan => 'KI Scan';

  @override
  String get sidebarHistory => 'Verlauf';

  @override
  String get sidebarSettings => 'Einstellungen';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navScan => 'Scannen';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navSettingsCompact => 'Einst.';

  @override
  String get profileName => 'Mein Profil';

  @override
  String get profileStatus => 'Offline';

  @override
  String get pdfDailySummary => 'Tägliche Nährwertübersicht';

  @override
  String get pdfAnalysisSummary => 'Nährwertanalyse-Zusammenfassung';

  @override
  String pdfLoggedOn(Object date) {
    return 'Erfasst am: $date';
  }

  @override
  String pdfDateRange(Object date) {
    return 'Datum: $date';
  }

  @override
  String pdfRangeCustom(Object end, Object start) {
    return 'Zeitraum: $start - $end';
  }

  @override
  String get pdfAllTime => 'Alle Einträge';

  @override
  String get pdfRange7Days => 'Zeitraum: Letzte 7 Tage';

  @override
  String get pdfActiveFilter => 'Aktiver Filterzeitraum';

  @override
  String get importLabel => 'Importieren';

  @override
  String get exportLabel => 'Exportieren';

  @override
  String importMealsSuccess(int count) {
    return '$count Mahlzeiten erfolgreich importiert.';
  }

  @override
  String importMealsError(String error) {
    return 'Fehler beim Importieren: $error';
  }

  @override
  String get exportMealsSuccess => 'Mahlzeiten erfolgreich exportiert.';

  @override
  String exportMealsError(String error) {
    return 'Fehler beim Exportieren: $error';
  }

  @override
  String get selectMeals => 'Auswählen';

  @override
  String get deselectAll => 'Auswahl aufheben';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get reEvaluate => 'Neu bewerten';

  @override
  String get reEvaluating => 'Neu bewertung...';

  @override
  String reEvaluationError(String error) {
    return 'Neu-Bewertung fehlgeschlagen: $error';
  }

  @override
  String get reEvaluationSuccess => 'Mahlzeit erfolgreich neu bewertet!';

  @override
  String get syncSettings => 'Cloud-Synchronisation';

  @override
  String get syncSettingsDesc =>
      'Konfigurieren Sie Ihre Serververbindung, um Ihre Mahlzeiten-Datenbank auf mehreren Geräten zu sichern und zu synchronisieren.';

  @override
  String get syncServerUrl => 'Server-URL';

  @override
  String get syncServerUrlHint => 'z.B. http://localhost:3000';

  @override
  String get syncUserId => 'Benutzer-ID';

  @override
  String get syncUserIdHint => 'z.B. user-1';

  @override
  String get syncNowBtn => 'Jetzt synchronisieren';

  @override
  String get syncingStatus => 'Synchronisierung mit dem Server...';

  @override
  String syncSuccess(int pulled, int pushed) {
    return 'Synchronisation erfolgreich! Empfangen: $pulled, Gesendet: $pushed';
  }

  @override
  String syncFailed(String error) {
    return 'Synchronisation fehlgeschlagen: $error';
  }

  @override
  String lastSyncedLabel(String time) {
    return 'Zuletzt synchronisiert: $time';
  }

  @override
  String get neverSynced => 'Noch nie synchronisiert';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String gitHash(String hash) {
    return 'Git-Hash: $hash';
  }

  @override
  String get imageSavedSuccess => 'Bild erfolgreich gespeichert!';

  @override
  String get imageSavedDownloads => 'Bild im Download-Ordner gespeichert!';

  @override
  String imageSavedTo(String path) {
    return 'Bild gespeichert unter: $path';
  }

  @override
  String imageSaveFailed(String error) {
    return 'Bild konnte nicht gespeichert werden: $error';
  }

  @override
  String get dbExportedDownloads =>
      'Datenbank in den Download-Ordner exportiert!';

  @override
  String dbExportedTo(String path) {
    return 'Datenbank exportiert nach: $path';
  }

  @override
  String dbExportFailed(String error) {
    return 'Datenbankexport fehlgeschlagen: $error';
  }
}
