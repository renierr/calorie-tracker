# NutriScan Calorie Tracker

Welcome to **NutriScan**, the ultimate high-end, premium offline-first calorie and nutrition tracker. Seamlessly blend state-of-the-art visual AI analysis with a beautiful slate-dark interface, keeping you fully in control of your health journey. 

Designed for both daily mobility and desktop efficiency, NutriScan lets you track meals, monitor macronutrients, log body weight, and export elegant reports—all while keeping your personal data completely private on your own device.

---

## The NutriScan Experience

### 📸 Intelligent Visual Scanning & AI Re-Evaluation
Instantly log your meals just by taking a picture. 

Backed by advanced multi-provider visual AI models, NutriScan looks at your food photo, estimates portion weights, and breaks down the meal's exact calories, protein, carbohydrates, and healthy fats. 

Need adjustments? Simply enter an interactive **Correction Prompt** (e.g., *"I only ate half"* or *"add 50g chicken breast"*) during verification or from the edit dialog, and the AI will re-evaluate your macros instantly.

> [!NOTE]
> **API Key & Manual Logging**: To use the visual scanner, you must provide your own API key for your chosen provider (Google Gemini, OpenAI, or Anthropic) in the Settings page. However, **manual meal logging is always fully supported** at all times, even without an API key or active internet connection.

### 🏃‍♀️ Dynamic Activity Tracking
Track workouts, exercises, and physical activities (like running, swimming, and cycling) alongside your meals. 

NutriScan automatically calculates your **daily net calorie balance** as `Intake (meals) - Burned (activities)`, giving you a flexible, interactive breakdown of your daily energy expenditure. Activities are visually integrated into your dashboard, history cards, and custom-generated PDF reports.

### 🔒 Privacy-First & Offline-First
Your health data belongs to you. 

NutriScan stores all of your records, nutritional breakdowns, and food photos directly on your device in a secure, local database. 

No cloud account is required to start tracking, keeping your data private, safe, and available even when you are completely offline.

### ⚖️ Comprehensive Weight Tracking
Log your body weight alongside your meals. 

NutriScan charts your weight trends in relation to your daily intake, letting you see the direct correlation 
between your nutrition goals and your weight progress on a unified dashboard.

### 📂 Favorites & Easy Filtering
Quickly look back at your history or search for your favorite meals. 

With custom tags and favorites tracking, you can instantly find and repeat high-protein breakfasts, low-carb snacks, or balanced dinners with a single tap.

### 📄 Elegant PDF Summary Reports
Create high-end, professional PDF reports of your nutritional logs. 

Generate single-meal summary sheets containing personal notes and photos, 
or comprehensive multi-day summaries featuring full macro tables, activity lists, budget achievements, and share with your nutritionist or trainer.

### 🎮 Premium Gamification & Streak Loop
Keep your healthy eating habits consistent with an interactive, beautifully designed reward system.

Earn Experience Points (XP) for tracking actions, level up across 10 distinct habit milestones, 
maintain daily streaks of calorie budget success, and protect your hard-earned streaks with consumable Streak Shields. 
Unlock gorgeous, high-end achievement badges (like the *Spark*, *Threefold Discipline*, or *Week King*) to visually celebrate your dedication.

Fully optional and togglable off inside the Settings menu.


---

## Developer Guide & Development Setup

This section outlines technical implementation details, architecture patterns, building instructions, and deployment steps.

### Codebase Architecture

Overview of key files and directories under the `lib/` directory:

*   **`lib/main.dart`**: Application entry point and global state initialization.
*   **`lib/version.dart`**: Auto-generated app build version and git commit hash details.
*   **`lib/helpers/`**: Local SQLite database configuration and FFI desktop overrides.
*   **`lib/l10n/`**: Application localization files (English and German).
*   **`lib/layout/`**: Desktop sidebar and mobile tab navigation shells.
*   **`lib/models/`**: Data representation classes (e.g. `Meal`).
*   **`lib/pages/`**: Main application views (Dashboard, Scan, History, Settings).
*   **`lib/providers/`**: State management architecture utilizing ChangeNotifier and split state mixins.
*   **`lib/services/`**: Exterior network clients, multi-provider AI visual scan services, and PDF printers.
*   **`lib/theme/`**: Theme configurations, global styling variables, and color schemes.
*   **`lib/widgets/`**: Reusable component building blocks and specific visual subviews.

### Key Technical Systems

1. **Multi-Provider AI Scanning & Re-Evaluation**:
   - Analyzes photos using Gemini, OpenAI, Anthropic, or Custom AI endpoints with strict structured JSON schemas to guarantee exact calorie and macro totals.
   - Supports live dynamic re-evaluation using correction prompts, merging historical image bytes and new prompt instructions.
   - Interactive Verification Form allows users to review and adjust values before saving.

2. **Dynamic Activity Tracking System**:
   - Tracks exercises using the unified SQLite `meals` table, differentiated by the `shortId` prefix (`ACT-` for exercise, `MEAL-` for food).
   - Computes daily net calories dynamically (`Intake - Burned`) and displays customized layouts and stats on the dashboard.

3. **Offline-First SQLite Storage**:
   - Highly performant database schema storing meal descriptions, macro grams (Protein, Carbohydrates, Lipid Fats), total calories, body weight in kg, AI confidence ratings, notes, dates, and raw photo bytes (BLOB).
   - Utilizes `sqflite` on Android and FFI bindings on Windows Desktop.

4. **Multi-Platform Responsiveness**:
   - Mobile Layout (bottom bar) vs. Desktop Layout (left sidebar).
   - Handled dynamically via `ResponsiveLayout`.

5. **Analytical Dashboard**:
   - Calorie ring progress indicator (incorporating exercise balance), sliding calendar date selector, and a vertical bar chart displaying calorie history over the last 7 days.

6. **Gamification System**:
   - Fully persistent, offline SQLite habit state (`gamification_stats` table).
   - Fast retroactive $O(N)$ chronological in-memory re-evaluations via a single database query.
   - High-fidelity visual feedback including dynamic dialog transitions, levels, stars, shields, and custom-rendered confetti particles.

7. **Bidirectional Cloud Sync**:
   - Optional sync with a Bun-based HTTP cloud server using metadata handshakes and sync/deleted state flags.

---

### How to Build & Run

Ensure you are in the project workspace directory.

#### 1. Run the App
Launch the developer workspace with live-reload support:

*   **Windows Desktop**:
    ```bash
    flutter run -d windows
    ```
*   **Android (Device or Emulator)**:
    ```bash
    flutter run -d android
    ```

#### 2. Run Automated Unit Tests
Verify model schemas and serialization tests:
```bash
flutter test
```

#### 3. Build Release Packages
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

### Settings & Initial Setup

On first startup, navigate to the **Settings** panel:
1.  Configure your preferred **AI Provider** (Gemini, OpenAI, Anthropic, or Custom AI).
2.  Input your **API Key** and verify credentials.
3.  Tune your daily goals: Calorie Budget (kcal), Protein (g), Carbohydrates (g), and Lipid Fats (g).
4.  Save preferences to arm the automated visual scanning!

---

### Production Packaging & Distribution Guide

Follow these precise steps to package, compile, and distribute the NutriScan Calorie Tracker app on Windows Desktop and Android.

#### 1. Windows Desktop (Standalone Executable)

##### A. Build Command
Compile the highly optimized, native C++ desktop release bundle:
```bash
flutter build windows --release
```

##### B. Output Directory & Created Files
The build files are generated under:
`calorie-tracker\build\windows\x64\runner\Release\`

The directory contains:
*   `calorie_tracker.exe`: The primary executable binary file.
*   `flutter_windows.dll`: The core Flutter engine library.
*   `sqlite3.dll`: The dynamic SQLite library needed for local database operations.
*   `data/` (Folder): Contains packaged fonts, assets, raw asset files, and compiled machine code.

##### C. Packaging & Distribution Instruction
> [!IMPORTANT]
> **Do not distribute only the `calorie_tracker.exe` file!** 
> To share the application with other Windows users:
> 1. Zip the **entire** `Release/` directory (including the `.exe`, all `.dll` files, and the `data/` folder).
> 2. The recipient must extract the zip folder and run `calorie_tracker.exe` from inside the folder.
> 3. Alternatively, use installer creators like **Inno Setup** or **WiX Toolset** to bundle this entire directory into a single `.msi` or setup installer.

---

#### 2. Android App (APK & AAB bundles)

##### A. Compile Single Portable Installable (Release APK)
Generates a standalone `.apk` containing resources for all hardware architectures:
```bash
flutter build apk --release
```
*   **Output Path**: `build/app/outputs/flutter-apk/app-release.apk`
*   **Distribution**: This single file can be transferred directly to any Android device via USB, email, or download link. Users can install it instantly (requires "Install from Unknown Sources" permission enabled in device settings).

##### B. Compile Splitted Lightweight Packages (Per-ABI APKs)
Splits the build to generate separate, smaller APK files optimized for specific device processors (arm64-v8a, armeabi-v7a, x86_64), saving user download bandwidth:
```bash
flutter build apk --split-per-abi --release
```
*   **Output Path**: `build/app/outputs/flutter-apk/` (Generates files named `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, etc.)

##### C. Compile App Bundle (AAB for Google Play Store)
Generates the Google Play Store upload format which dynamically serves optimized resources based on the user's specific handset model:
```bash
flutter build appbundle --release
```
*   **Output Path**: `build/app/outputs/bundle/release/app-release.aab`
*   **Distribution**: Upload this `.aab` file directly to the Google Play Console for official application store distribution.

##### D. Production Keystore Signing
To sign your Android build:
1. Generate an upload keystore using Java's `keytool`:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create an `android/key.properties` file:
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. The build system in `android/app/build.gradle` will automatically detect these credentials on subsequent release runs to produce a signed production build.
