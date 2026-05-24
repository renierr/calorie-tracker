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
*   **`lib/widgets/responsive_layout.dart`**: Adaptive shell swapping navigation views between Desktop sidebars and Mobile tab bars.
*   **`lib/pages/`**:
    *   `dashboard_page.dart`: Interactive statistics circle gauges, day selector, and history bar charts.
    *   `scan_page.dart`: Interactive camera/gallery handlers and AI nutrition verification spreadsheets.
    *   `history_page.dart`: Historic listings, custom date filters, individual PDF exports, and aggregate report dialogs.
    *   `settings_page.dart`: Target macros slider dials, visibility API key controls, and diagnostics reset options.

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
