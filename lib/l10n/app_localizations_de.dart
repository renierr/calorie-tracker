// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'NutriScan Kalorien Tracker';

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
  String get noMealsLogged => 'Keine Einträge für diesen Tag.';

  @override
  String perGram(Object carbs, Object fat, Object protein) {
    return 'E: ${protein}g  K: ${carbs}g  F: ${fat}g';
  }

  @override
  String kcalLabel(Object calories) {
    return '+$calories kcal';
  }

  @override
  String get scanTitle => 'Aktivität erfassen';

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
  String get scanAndEstimate => 'Scannen & mit KI analysieren';

  @override
  String get logWithPhoto => 'Mit Foto manuell erfassen';

  @override
  String get apiKeyMissing => 'API-Schlüssel fehlt';

  @override
  String get apiKeyMissingDesc =>
      'Für die Fotoanalyse wird ein gültiger API-Schlüssel benötigt. Bitte in den Einstellungen hinterlegen.';

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
  String get mealDescription => 'Beschreibung';

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
  String get mealDate => 'Datum:';

  @override
  String get notes => 'Notizen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String pickImageFailed(Object error) {
    return 'Fehler beim Laden des Bildes: $error';
  }

  @override
  String get provideName => 'Bitte gib einen gültigen Namen ein.';

  @override
  String get mealLogged => 'Erfolgreich erfasst!';

  @override
  String get scanningTitle => 'Analyse mit KI...';

  @override
  String get scanningDesc =>
      'Gewichte, Portionen und Nährstoffe werden berechnet. Dies kann einige Sekunden dauern.';

  @override
  String get aiError => 'KI-Scanner Fehler';

  @override
  String aiErrorDesc(Object error) {
    return 'Bildanalyse fehlgeschlagen. Bitte stelle sicher, dass dein API-Schlüssel gültig ist und eine Internetverbindung besteht.\n\nFehlerdetails: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get historyTitle => 'Verlauf';

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
  String get compilePdf => 'Einträge in einen PDF-Bericht umwandeln.';

  @override
  String get reportPdf => 'PDF-Bericht';

  @override
  String get pdf => 'PDF';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get templateAsNew => 'Neu';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String get confirmDeleteDesc =>
      'Bist du sicher, dass du diesen Eintrag endgültig löschen möchtest? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noHistory => 'Kein Verlauf gefunden';

  @override
  String get noHistoryDesc =>
      'Filter ändern oder einen Eintrag erfassen, um zu beginnen!';

  @override
  String get mealUpdated => 'Eintrag erfolgreich aktualisiert!';

  @override
  String get editMeal => 'Eintrag bearbeiten';

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
  String get mealDeleted => 'Eintrag gelöscht.';

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
  String get apiCredentials => 'KI API-Zugangsdaten';

  @override
  String get apiCredentialsDesc =>
      'Der KI-Scanner benötigt einen API-Schlüssel. Dein Schlüssel wird lokal in den App-Einstellungen gespeichert.';

  @override
  String get enterApiKey => 'Geben Sie Ihren API-Schlüssel ein';

  @override
  String get apiKeyLabel => 'API-Autorisierungsschlüssel';

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
      'Daten endgültig löschen oder Datenbank-/Einstellungs-Sicherungen wiederherstellen.';

  @override
  String get clearHistory => 'Gesamten Verlauf löschen';

  @override
  String get eraseAll => 'Alle Daten löschen?';

  @override
  String get eraseAllDesc =>
      'Bist du absolut sicher, dass du die SQLite-Datenbank dauerhaft löschen möchtest? Dies löscht alle deine Einträge, Fotos und Verlaufsdaten. Diese Aktion kann nicht rückgängig gemacht werden.';

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
  String get exportSectionTitle => 'Sicherungscenter';

  @override
  String get exportSectionDesc =>
      'Exportiere deine SQLite-Datenbank oder die lokalen App-Einstellungen.';

  @override
  String get exportDbBtn => 'Datenbank exportieren';

  @override
  String get exportSettingsBtn => 'Einstellungen exportieren';

  @override
  String get dbExported => 'Datenbank erfolgreich exportiert.';

  @override
  String get settingsExported => 'Einstellungen erfolgreich exportiert.';

  @override
  String settingsExportFailed(String error) {
    return 'Export der Einstellungen fehlgeschlagen: $error';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Import der Einstellungen fehlgeschlagen: $error';
  }

  @override
  String get restoreDbBtn => 'Datenbank wiederherstellen';

  @override
  String get restoreSettingsBtn => 'Einstellungen wiederherstellen';

  @override
  String get confirmRestore => 'Datenbank wiederherstellen?';

  @override
  String get confirmRestoreDesc =>
      'Bist du dir absolut sicher, dass du diese Datenbanksicherung wiederherstellen möchtest? Alle deine aktuellen protokollierten Einträge und Fotos werden dauerhaft ersetzt. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get confirmRestoreSettings => 'Einstellungen wiederherstellen?';

  @override
  String get confirmRestoreSettingsDesc =>
      'Bist du dir absolut sicher, dass du diese Einstellungen wiederherstellen möchtest? Dies überschreibt deine aktuellen täglichen Ziele, den API-Schlüssel und deine Einstellungen. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get noBackupsFound => 'Keine Datenbanksicherungsdateien gefunden.';

  @override
  String get noSettingsBackupsFound =>
      'Keine Einstellungs-Sicherungsdateien gefunden.';

  @override
  String get selectBackup => 'Wähle eine Datenbank-Sicherungsdatei';

  @override
  String get selectSettingsBackup => 'Wähle eine Einstellungs-Sicherungsdatei';

  @override
  String get dbRestored => 'Datenbank erfolgreich wiederhergestellt.';

  @override
  String get settingsRestored => 'Einstellungen erfolgreich wiederhergestellt.';

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
  String get sidebarScan => 'Aktivität erfassen';

  @override
  String get sidebarHistory => 'Verlauf';

  @override
  String get sidebarSettings => 'Einstellungen';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navScan => 'Erfassen';

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
  String pdfEntriesFollowing(int count) {
    return '$count Einträge folgen';
  }

  @override
  String get pdfEntriesLabel => 'Einträge gesamt';

  @override
  String get pdfCalorieTrend => 'Kalorientrend';

  @override
  String get pdfSingleMealReport => 'Ernährungsbericht des Eintrags';

  @override
  String get pdfNotes => 'KI-Analyse & Notizen';

  @override
  String get pdfAiConfidence => 'KI-Konfidenz';

  @override
  String get importLabel => 'Importieren';

  @override
  String get exportLabel => 'Exportieren';

  @override
  String importMealsSuccess(int count) {
    return '$count Einträge erfolgreich importiert.';
  }

  @override
  String importMealsError(String error) {
    return 'Fehler beim Importieren: $error';
  }

  @override
  String get exportMealsSuccess => 'Einträge erfolgreich exportiert.';

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
  String get reEvaluationSuccess => 'Eintrag erfolgreich neu bewertet!';

  @override
  String get reEvaluateInstruction =>
      'Korrektur-Eingabe (z.B. \'Ich habe nur die Hälfte gegessen\')';

  @override
  String get reEvaluateInstructionHint =>
      'Geben Sie Anpassungen ein oder was Sie tatsächlich verzehrt haben...';

  @override
  String get syncSettings => 'Cloud-Synchronisation';

  @override
  String get syncSettingsDesc =>
      'Konfigurieren Sie Ihre Serververbindung, um Ihre Datenbank auf mehreren Geräten zu sichern und zu synchronisieren.';

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
  String get favoriteMeals => 'Favoriten';

  @override
  String get noFavoritesYet =>
      'Noch keine Favoriten. Markiere einen Eintrag in den Details als Favorit.';

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

  @override
  String get pdfExportedDownloads =>
      'PDF-Bericht in den Download-Ordner exportiert!';

  @override
  String pdfExportedTo(String path) {
    return 'PDF-Bericht exportiert nach: $path';
  }

  @override
  String pdfExportFailed(String error) {
    return 'PDF-Generierung fehlgeschlagen: $error';
  }

  @override
  String get bodyWeightKg => 'Körpergewicht (kg)';

  @override
  String get bodyWeightTrend => 'Gewichtstrend';

  @override
  String get optionalWeight => 'Körpergewicht (optional in kg)';

  @override
  String get weightShort => 'G';

  @override
  String get aiSettingsTitle => 'KI-Bilderkennung konfigurieren';

  @override
  String get aiSettingsDesc =>
      'Konfigurieren Sie Ihr bevorzugtes KI-Bilderkennungsmodell für das Scannen von Fotos.';

  @override
  String get fallbackProviderLabel => 'Ausweichanbieter';

  @override
  String get fallbackProviderDesc =>
      'Wählen Sie einen Ausweichanbieter aus, der automatisch vorgeschlagen wird, wenn der aktive KI-Scanner einen Fehler ausgibt. Ein Anbieter ist nur dann als Ausweichanbieter gültig, wenn er über einen konfigurierten API-Schlüssel/Zugangsdaten verfügt.';

  @override
  String get fallbackNone => 'Keiner';

  @override
  String get aiFallbackPromptTitle => 'Ausweichanbieter ausprobieren?';

  @override
  String aiFallbackPrompt(String fallbackName) {
    return 'Die aktive KI-Analyse ist fehlgeschlagen. Möchten Sie den Ausweichanbieter $fallbackName ausprobieren?';
  }

  @override
  String get aiProviderLabel => 'KI-Anbieter';

  @override
  String get aiModelLabel => 'Erkennungsmodell';

  @override
  String get customUrlLabel => 'Eigene API-Endpunkt-Basis-URL';

  @override
  String get customUrlHint => 'z. B. http://localhost:11434/v1';

  @override
  String get customModelHint => 'z. B. llama3.2-vision';

  @override
  String get customModelOption => 'Eigenes Modell...';

  @override
  String get customModelRequired =>
      'Bitte geben Sie einen eigenen Modellnamen an';

  @override
  String get customUrlRequired =>
      'Eigene API-Endpunkt-Basis-URL ist erforderlich';

  @override
  String get apiKeyRequired => 'API-Autorisierungsschlüssel ist erforderlich';

  @override
  String get validateConnection => 'Verbindung prüfen';

  @override
  String get validateSuccess => 'Zugangsdaten sind gültig!';

  @override
  String validationFailed(String error) {
    return 'Validierung fehlgeschlagen: $error';
  }

  @override
  String get aiSettingsSaved => 'KI-Konfiguration erfolgreich gespeichert!';

  @override
  String activeAiConfig(String provider, String model) {
    return 'Aktiv: $provider ($model)';
  }

  @override
  String get aiReasoningEffortLabel => 'Denkaufwand';

  @override
  String get reasoningNone => 'Keine / Standard';

  @override
  String get reasoningLow => 'Niedrig';

  @override
  String get reasoningMedium => 'Mittel';

  @override
  String get reasoningHigh => 'Hoch';

  @override
  String get configureAiProvider => 'KI-Anbieter konfigurieren';

  @override
  String get configureAiProviderDesc =>
      'Ändern Sie KI-Modelle, Endpunkte oder Schlüssel';

  @override
  String get geminiInfoTitle => 'Gemini API-Schlüssel erhalten';

  @override
  String get geminiInfoDesc =>
      'Der KI-Scanner verbindet sich sicher mit den Gemini-Modellen von Google, um Kalorien und Portionsgewichte aus Ihren Essensfotos zu schätzen.';

  @override
  String get geminiStep1 =>
      '1. Öffnen Sie Google AI Studio unter: https://aistudio.google.com/api-keys';

  @override
  String get geminiStep2 =>
      '2. Melden Sie sich mit Ihrem standardmäßigen Google-Konto an.';

  @override
  String get geminiStep3 =>
      '3. Klicken Sie auf die Schaltfläche \"Create API Key\".';

  @override
  String get geminiStep4 =>
      '4. Kopieren Sie den generierten Schlüssel und fügen Sie ihn hier ein.';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get linkCopied => 'Link in die Zwischenablage kopiert!';

  @override
  String get apiDisclaimerTitle => 'API- & Kosten-Disclaimer';

  @override
  String get apiDisclaimerLink => 'API-Nutzung & Kosten-Disclaimer';

  @override
  String get apiDisclaimerDesc =>
      'Bitte lesen Sie diesen wichtigen Hinweis zur Verwendung Ihrer eigenen API-Schlüssel und Verbindungen in dieser Anwendung:';

  @override
  String get apiDisclaimerPoint1Title => 'Kosten der Cloud-Anbieter';

  @override
  String get apiDisclaimerPoint1Desc =>
      'Die Nutzung von Cloud-Anbietern (wie Google Gemini, OpenAI, Anthropic oder Grok) verursacht Kosten basierend auf Ihrer Token-Nutzung. Selbst wenn Sie mit einem kostenlosen Kontingent starten, können je nach Ihren Kontoeinstellungen Nutzungslimits oder automatische Abrechnungsübergänge gelten.';

  @override
  String get apiDisclaimerPoint2Title => 'Verantwortung des Nutzers';

  @override
  String get apiDisclaimerPoint2Desc =>
      'Sie sind allein verantwortlich für die Verwaltung Ihrer API-Schlüssel, die Überwachung der Nutzung und alle Gebühren oder Abrechnungen, die durch Ihre Cloud-Anbieter-Konten entstehen. Wir empfehlen dringend, Budget-Warnungen und Nutzungslimits in Ihrer Entwicklerkonsole einzurichten.';

  @override
  String get apiDisclaimerPoint3Title => 'Keine Haftung des App-Erstellers';

  @override
  String get apiDisclaimerPoint3Desc =>
      'Als Ersteller dieser App bin ich nicht verantwortlich für direkte, indirekte oder zufällige Kosten, Abrechnungsüberraschungen, API-Missbrauch, Dienstunterbrechungen oder Fehler, die bei der Nutzung von KI-Modellen von Drittanbietern auftreten können.';

  @override
  String get apiDisclaimerButton => 'Ich verstehe';

  @override
  String get notificationsTitle => 'System-Benachrichtigungen';

  @override
  String get notificationsDesc =>
      'Aktivieren oder deaktivieren Sie native System-Benachrichtigungen in der Android-Statusleiste für Downloads.';

  @override
  String get enableNotifications => 'System-Benachrichtigungen anzeigen';

  @override
  String get gamificationTitle => 'Erfolge & Levels';

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
    return '$xp XP zum nächsten Level';
  }

  @override
  String xpToNextStar(int xp) {
    return '$xp XP zum nächsten Stern';
  }

  @override
  String currentStreakLabel(int days) {
    return 'Serie: $days Tage';
  }

  @override
  String highestStreakLabel(int days) {
    return 'Bestwert: $days Tage';
  }

  @override
  String shieldsLabel(int count) {
    return 'Schilde: $count';
  }

  @override
  String get badgesTitle => 'Freigeschaltete Abzeichen';

  @override
  String get badgeUnlockedPopup => 'Abzeichen freigeschaltet!';

  @override
  String get levelUpPopup => 'Level aufgestiegen!';

  @override
  String levelUpDesc(int lvl, String title) {
    return 'Herzlichen Glückwunsch! Du hast Level $lvl - $title erreicht!';
  }

  @override
  String get streakShieldEarnedTitle => 'Schutzschild verdient!';

  @override
  String get streakShieldEarnedDesc =>
      'Großartige Arbeit! Du hast dir ein Streak-Schutzschild für eine perfekte 7-Tage-Serie verdient!';

  @override
  String get streakShieldConsumedTitle => 'Schild aktiv!';

  @override
  String get streakShieldConsumedDesc =>
      'Deine Serie wurde durch ein Streak-Schutzschild gerettet, da du heute dein Kalorienlimit überschritten hast!';

  @override
  String get streakResetTitle => 'Serie unterbrochen!';

  @override
  String get streakResetDesc =>
      'Deine Serie wurde zurückgesetzt. Bleib dran, Kontinuität ist der Schlüssel!';

  @override
  String get badgeZundfunkeTitle => 'Zündfunke';

  @override
  String get badgeZundfunkeDesc =>
      'Tag 1 unter dem Kalorienlimit beendet. Die Reise beginnt!';

  @override
  String get badgeDreifacheDisziplinTitle => 'Dreifache Disziplin';

  @override
  String get badgeDreifacheDisziplinDesc =>
      '3 Tage in Folge Einträge vorgenommen und unter dem Limit geblieben.';

  @override
  String get badgeWochenKoenigTitle => 'Wochen-König';

  @override
  String get badgeWochenKoenigDesc =>
      'Die perfekte Woche! 7 Tage in Folge diszipliniert geblieben.';

  @override
  String get lvlCouchPotato => 'Couch-Potato';

  @override
  String get lvlMotivatedBeginner => 'Motivierter Einsteiger';

  @override
  String get lvlHabitHero => 'Gewohnheits-Held';

  @override
  String get lvlMetabolismMaster => 'Stoffwechsel-Meister';

  @override
  String get lvlFitnessApprentice => 'Fitness-Lehrling';

  @override
  String get lvlDisciplineAthlete => 'Disziplin-Athlet';

  @override
  String get lvlEnduranceChampion => 'Ausdauer-Champion';

  @override
  String get lvlNutritionGuru => 'Ernährungs-Guru';

  @override
  String get lvlVitalityLegend => 'Vitalitäts-Legende';

  @override
  String get lvlCalorieNinja => 'Kalorien-Ninja';

  @override
  String get xpHint => '+10 XP pro Eintrag • +100 XP pro erfolgreichem Tag';

  @override
  String get gamificationSettingsTitle => 'Gamification-Einstellungen';

  @override
  String get gamificationSettingsDesc =>
      'Verwalte deine Erfolge, Erfahrungswerte, Schutzschilde und Aktivitätsserien.';

  @override
  String get gamificationConfigureBtn => 'Erfolge konfigurieren';

  @override
  String get maintenanceSettingsTitle => 'Wartung & Backup';

  @override
  String get maintenanceSettingsDesc =>
      'Sichere, stelle wieder her und verwalte deine Datenbank und Einstellungen.';

  @override
  String get maintenanceConfigureBtn => 'Wartungscenter öffnen';

  @override
  String get adminTriggersTitle => 'Entwickler- / Admin-Steuerung';

  @override
  String get adminTriggersDesc =>
      'Führe temporär Animationen und Erfolgsdialoge aus, um die visuelle Darstellung direkt zu überprüfen.';

  @override
  String get btnTriggerConfetti => 'Konfetti auslösen';

  @override
  String get btnTriggerLevelUp => 'Level-Up auslösen';

  @override
  String get btnTriggerBadgeZund => 'Zündfunke freischalten';

  @override
  String get btnTriggerBadgeThree => 'Serie 3 freischalten';

  @override
  String get btnTriggerBadgeWeek => 'Wochen-König freischalten';

  @override
  String get btnTriggerShieldEarn => 'Schild verdient Dialog';

  @override
  String get btnTriggerShieldCons => 'Schild verbraucht Dialog';

  @override
  String get btnTriggerStreakReset => 'Serie zurückgesetzt Dialog';

  @override
  String get btnResetAckBadges => 'Gesehene Awards zurücksetzen';

  @override
  String get toggleGamification => 'Gamification-System aktivieren';

  @override
  String get streakProtection => 'Serien-Schutz';

  @override
  String get prestigeTitle => 'Prestige-Stern verdient!';

  @override
  String get prestigeDesc =>
      'Unglaubliche Disziplin! Du hast einen weiteren Meilenstein von 1000 XP über Level 10 hinaus erreicht. Du erhältst +1 Serien-Schutzschild!';

  @override
  String get btnTriggerPrestige => 'Prestige auslösen';

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get enabledLabel => 'Aktiviert';

  @override
  String get disabledLabel => 'Deaktiviert';

  @override
  String get aboutTitle => 'Über NutriScan';

  @override
  String get aboutSubtitle => 'Dein KI-gestützter Ernährungs-Partner';

  @override
  String get aboutDescription =>
      'NutriScan ist ein moderner, datenschutzfreundlicher Kalorien- und Makronährstoff-Tracker, der entwickelt wurde, um dir mit minimalem Aufwand beim Erreichen deiner Ziele zu helfen. Durch fortschrittliche KI-Modellintegrationen wird das Erfassen so einfach wie das Aufnehmen eines Fotos.';

  @override
  String get aboutFeatureAiTitle => 'KI-Scanner';

  @override
  String get aboutFeatureAiDesc =>
      'Fotografiere deine Mahlzeiten für eine sekundenschnelle Analyse von Kalorien und Nährstoffen.';

  @override
  String get aboutFeatureMultiAiTitle => 'Multi-Anbieter-KI';

  @override
  String get aboutFeatureMultiAiDesc =>
      'Integration mit Gemini, OpenAI, Anthropic oder Grok.';

  @override
  String get aboutFeatureGamificationTitle => 'Interaktive Serien';

  @override
  String get aboutFeatureGamificationDesc =>
      'Baue Gewohnheiten auf, schalte Level frei und schütze deine Serie mit Schutzschilden.';

  @override
  String get aboutFeatureOfflineTitle => 'Lokal & Offline-First';

  @override
  String get aboutFeatureOfflineDesc =>
      'Deine Daten werden sicher offline in einer SQLite-Datenbank auf deinem Gerät gespeichert.';

  @override
  String get aboutFeaturePdfTitle => 'PDF-Berichte';

  @override
  String get aboutFeaturePdfDesc =>
      'Fasse deinen Ernährungsverlauf in druckfertigen PDF-Berichten zusammen.';

  @override
  String get aboutOpenSource =>
      'Gewidmet einem gesunden Lebensstil, Privatsphäre und aktiver Entwicklerverantwortung.';

  @override
  String get editActivityDetails => 'Aktivitätsdetails bearbeiten';

  @override
  String get activityName => 'Aktivität / Übungsname';

  @override
  String get caloriesBurnedKcal => 'Verbrannte Kalorien (kcal)';

  @override
  String get caloriesBurned => 'Verbrannte Kalorien';

  @override
  String get activityUpdated => 'Aktivität erfolgreich aktualisiert';

  @override
  String get verifyActivityDetails => 'Aktivitätsdetails überprüfen';

  @override
  String get activityHint => 'Laufen, Schwimmen, Radfahren...';

  @override
  String get activityLogged => 'Aktivität erfolgreich protokolliert';

  @override
  String get activitiesLogged => 'Protokollierte Aktivitäten';

  @override
  String get intakeCalories => 'Aufgenommene Kalorien';

  @override
  String get mealsLogged => 'Protokollierte Mahlzeiten';

  @override
  String get netCalories => 'Netto-Kalorien';

  @override
  String get burned => 'Verbrannt';

  @override
  String get logsCount => 'Anzahl Protokolle';

  @override
  String get allLogs => 'Alle Protokolle';

  @override
  String get mealsOnly => 'Nur Mahlzeiten';

  @override
  String get activitiesOnly => 'Nur Aktivitäten';

  @override
  String get logTypeFilter => 'Protokolltyp-Filter';

  @override
  String get burnExercise => 'Verbrennung / Training';

  @override
  String get logActivity => 'Aktivität protokollieren';

  @override
  String get includeInPdfReport => 'In PDF-Bericht aufnehmen';

  @override
  String intakeLabel(int calories) {
    return 'Aufnahme: $calories kcal';
  }

  @override
  String burnedLabel(int calories) {
    return 'Verbrannt: $calories kcal';
  }

  @override
  String activityLabel(String name) {
    return '[Aktivität] $name';
  }

  @override
  String get dropZonePrompt => 'Ziehen Sie ein Foto hierher oder durchsuchen';

  @override
  String get dropZoneHovering => 'Bild ablegen zum Scannen!';

  @override
  String get pasteFromClipboard => 'Bild einfügen';

  @override
  String get noImageInClipboard => 'Kein Bild in der Zwischenablage gefunden.';

  @override
  String get imageCopiedToClipboard => 'Bild in die Zwischenablage kopiert';

  @override
  String failedToCopyImage(String error) {
    return 'Bild konnte nicht kopiert werden: $error';
  }

  @override
  String pasteImageFailed(String error) {
    return 'Fehler beim Einfügen des Bildes: $error';
  }

  @override
  String readDroppedFileFailed(String error) {
    return 'Fehler beim Lesen der abgelegten Datei: $error';
  }

  @override
  String operationFailed(String error) {
    return 'Fehler: $error';
  }

  @override
  String prestigeStarsLabel(int count) {
    return ' (⭐ x$count)';
  }

  @override
  String macroFormat(int protein, int carbs, int fat) {
    return 'E: ${protein}g • K: ${carbs}g • F: ${fat}g';
  }

  @override
  String get noMealsToExport => 'Keine Mahlzeiten zum Exportieren gefunden.';

  @override
  String get jsonBackup => 'JSON-Backup';

  @override
  String reportDescription(int count) {
    return 'Erstellt ein PDF mit einer Zusammenfassung der $count Mahlzeiten in der aktiven Liste.';
  }

  @override
  String restoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String failedToSaveSettings(String error) {
    return 'Fehler beim Speichern der Einstellungen: $error';
  }
}
