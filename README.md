# NutriScan Calorie Tracker 

A high-end, premium **offline-first multi-platform** calorie and macronutrient tracking application built in **Flutter and Dart**. It supports **Android** and **Windows Desktop** out of the box.

The application leverages the **Google Gemini API** to visually scan food photos, estimate portion weights, and automatically calculate nutritional information. It stores all tracked metrics and food photos in a **local SQLite database** and can generate stylized **PDF nutritional reports** with photo galleries.

---

## Key Features

1. **AI Visual Food Scanner**:
   - Take a photo with your camera or import a meal from your gallery.
   - Supply an optional context hint (e.g., "about 150g white rice").
   - Analyzes photos using the Gemini API with strict structured JSON schemas (`responseSchema` and `jsonMode` in Dart) to guarantee exact calorie and macro totals.
   - Displays an interactive **Verification Form** for you to review and adjust values before saving.

2. **Offline-First SQLite Storage**:
   - Fully standalone database schema storing meal descriptions, macro grams (Protein, Carbohydrates, Lipid Fats), total calories, AI confidence ratings, notes, dates, and **raw photo bytes** (BLOB).
   - Dynamically loads native SQLite on Android and utilizes **SQLite FFI** bindings on Windows Desktop to guarantee smooth, self-contained desktop usage without complex compilation requirements.

3. **Premium Visual Aesthetics**:
   - A modern Dark Mode-first UI using deep slate backdrops (`#0B0F19`) and glassmorphic card overlays (`#161F30`).
   - Vivid electric contrast accents: Emerald Green for Calories/Goals, Cobalt Blue for Protein, Amber Orange for Carbs, and Rose Red for Lipid Fats.

4. **Multi-Platform Responsiveness**:
   - **Mobile Layout**: Renders a clean bottom navigation bar.
   - **Desktop Layout**: Shifts navigation to a professional, full-height left sidebar panel, optimizing wide screens.

5. **Analytical Dashboard**:
   - **Calorie ring progress indicator**: Visualizes consumed calories relative to your budget.
   - **Sliding calendar date selector**: Day toggles to view historic logs or plan ahead.
   - **Calorie trend chart**: A highly performant, vertical bar chart displaying calorie history over the last 7 days.

6. **Nutritional PDF Reports**:
   - **Single Meal PDF**: Exports individual logs complete with notes and photos.
   - **Summary PDF**: Generates comprehensive daily or custom date-range summary reports featuring tables, target progress summaries, and an attached **Photo Album Gallery** of logged food scans.

---

## Codebase Architecture

The project is structured logically around clean architecture principles in the `lib/` directory:

*   **`lib/main.dart`**: Core app bootstrapping, initializing global states, loading persistent preferences, and launching the MaterialApp.
*   **`lib/theme/theme.dart`**: Holds our color tokens, custom borders, glassmorphic card styles, and Material 3 Dark Theme setup.
*   **`lib/models/meal_model.dart`**: The `Meal` data model, handling serializations to and from SQLite map datasets.
*   **`lib/helpers/db_helper.dart`**: Setups SQLite, managing FFI overrides for Windows Desktop and native binders for Android.
*   **`lib/providers/app_state.dart`**: State manager (`ChangeNotifier`) caching database tables, computing daily intake totals, and saving target configurations via `shared_preferences`.
*   **`lib/services/`**:
    *   `gemini_service.dart`: Integrates Google's `google_generative_ai` SDK to run visually structured meal analysis scans.
    *   `pdf_service.dart`: Compiles highly stylized single and range-based nutritional summary PDFs.
*   **`lib/pages/`**:
    *   `dashboard_page.dart`: Composition screen for dashboard date strips, radial calorie rings, macro trends, and recent meal logs.
    *   `scan_page.dart`: Coordination page managing Gemini AI visual analysis scans.
    *   `history_page.dart`: Displays comprehensive lists of historic meal logs.
    *   `settings_page.dart`: Collects slider configurations and database backups.
*   **`lib/widgets/`**:
    *   `responsive_layout.dart`: Adaptive shell swapping navigation views between Desktop sidebars and Mobile tab bars.
    *   `edit_meal_dialog.dart`: Pop-up validator dialog to edit log macro targets.
    *   `report_config_dialog.dart`: Parameters collector for compiling ranges summary PDFs.
    *   `history_filter_panel.dart`: Timeframe drop-downs and start/end calendar selectors.
    *   `meal_history_card.dart`: Display card for custom logs with zoomable food photos, delete warnings, and quick single-log PDF downloads.
    *   **`lib/widgets/dashboard/`**:
        *   `date_navigation_strip.dart`: Sliding date-switcher bar.
        *   `calorie_ring_card.dart`: Radial progress consumption circle.
        *   `macros_progress_card.dart`: Linear protein, carb, lipid indicators.
        *   `trend_chart_card.dart`: Calorie 7-day bar charts.
        *   `day_quick_logs_card.dart`: Highlights current display day logs.
    *   **`lib/widgets/scan/`**:
        *   `scan_image_selector.dart`: Image pickers and manual logging triggers.
        *   `scan_verification_form.dart`: Verification editor and calendar logger.
    *   **`lib/widgets/settings/`**:
        *   `api_config_card.dart`: Secure API key controls.
        *   `target_goals_card.dart`: budget targets input sliders.
        *   `maintenance_card.dart`: Purge SQLite database options.
        *   `language_card.dart`: English/German arb localization dropdown.
        *   `theme_card.dart`: App light/dark appearance switches.
        *   `export_card.dart`: SQLite DB copies save selectors.

## How to Build & Run

Ensure you are in the project workspace directory: `C:\dev\flutter\calorie-tracker`

### 1. Run the App
Launch the developer workspace with live-reload support:

*   **Windows Desktop**:
    ```bash
    flutter run -d windows
    ```
*   **Android (Device or Emulator)**:
    ```bash
    flutter run -d android
    ```

### 2. Run Automated Unit Tests
Verify model schemas and serialization tests:
```bash
flutter test
```

### 3. Build Release Packages
Compile optimized, standalone binary files for deployment:

*   **Windows Desktop (Executable)**:
    ```bash
    flutter build windows --release
    ```
    *The standalone compiled files will be generated under: `build/windows/x64/runner/Release/`*

*   **Android (Release APK)**:
    ```bash
    flutter build apk --release
    ```
    *The output APK will be generated under: `build/app/outputs/flutter-apk/app-release.apk`*

---

## Settings Configuration

On first startup, navigate to the **Goal Settings** panel:
1.  Paste your **Google Gemini API Key** and toggle its visibility to verify it.
2.  Tune your daily goals: Calorie Budget (kcal), Protein (g), Carbohydrates (g), and Lipid Fats (g).
3.  Click **Save Preferences**. The app is now fully armed to perform automated visual food scans!

---

## Production Packaging & Distribution Guide

Follow these precise steps to package, compile, and distribute the NutriScan Calorie Tracker app on Windows Desktop and Android.

### 1. Windows Desktop (Standalone Executable)

#### A. Build Command
Compile the highly optimized, native C++ desktop release bundle:
```bash
flutter build windows --release
```

#### B. Output Directory & Created Files
The build files are generated under:
`C:\dev\flutter\calorie-tracker\build\windows\x64\runner\Release\`

The directory contains:
*   `calorie_tracker.exe`: The primary executable binary file.
*   `flutter_windows.dll`: The core Flutter engine library.
*   `sqlite3.dll`: The dynamic SQLite library needed for local database operations.
*   `data/` (Folder): Contains packaged fonts, assets, raw asset files, and compiled machine code.

#### C. Packaging & Distribution Instruction
> [!IMPORTANT]
> **Do not distribute only the `calorie_tracker.exe` file!** 
> To share the application with other Windows users:
> 1. Zip the **entire** `Release/` directory (including the `.exe`, all `.dll` files, and the `data/` folder).
> 2. The recipient must extract the zip folder and run `calorie_tracker.exe` from inside the folder.
> 3. Alternatively, use installer creators like **Inno Setup** or **WiX Toolset** to bundle this entire directory into a single `.msi` or setup installer.

---

### 2. Android App (APK & AAB bundles)

#### A. Compile Single Portable Installable (Release APK)
Generates a standalone `.apk` containing resources for all hardware architectures:
```bash
flutter build apk --release
```
*   **Output Path**: `build/app/outputs/flutter-apk/app-release.apk`
*   **Distribution**: This single file can be transferred directly to any Android device via USB, email, or download link. Users can install it instantly (requires "Install from Unknown Sources" permission enabled in device settings).

#### B. Compile Splitted Lightweight Packages (Per-ABI APKs)
Splits the build to generate separate, smaller APK files optimized for specific device processors (arm64-v8a, armeabi-v7a, x86_64), saving user download bandwidth:
```bash
flutter build apk --split-per-abi --release
```
*   **Output Path**: `build/app/outputs/flutter-apk/` (Generates files named `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, etc.)

#### C. Compile App Bundle (AAB for Google Play Store)
Generates the Google Play Store upload format which dynamically serves optimized resources based on the user's specific handset model:
```bash
flutter build appbundle --release
```
*   **Output Path**: `build/app/outputs/bundle/release/app-release.aab`
*   **Distribution**: Upload this `.aab` file directly to the Google Play Console for official application store distribution.

#### D. Production Keystore Signing (Optional but Recommended)
To prevent security warnings on install, sign your Android build:
1. Generate a upload keystore using Java's `keytool`:
   ```bash
   keytool -genkey -v -keystore C:\Users\renie\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create an `android/key.properties` file:
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=C:/Users/renie/upload-keystore.jks
   ```
3. The build system in `android/app/build.gradle` will automatically detect these credentials on subsequent release runs to produce a signed production build.
