# NutriScan Calorie Tracker

Welcome to **NutriScan**, the ultimate high-end, premium offline-first calorie and nutrition tracker. Seamlessly blend state-of-the-art visual AI analysis with a beautiful slate-dark interface, keeping you fully in control of your health journey. 

Designed for both daily mobility and desktop efficiency, NutriScan lets you track meals, monitor macronutrients, log body weight, and export elegant reports—all while keeping your personal data completely private on your own device.

---

## The NutriScan Experience

### 📸 Intelligent Visual Scanning
Instantly log your meals just by taking a picture. Backed by advanced multi-provider visual AI models, NutriScan looks at your food photo, estimates portion weights, and breaks down the meal's exact calories, protein, carbohydrates, and healthy fats. You can even add custom text hints (e.g. *"about 150g white rice"*) to guide the estimation, then verify and adjust the details in an elegant review screen before saving.

> [!NOTE]
> **API Key & Manual Logging**: To use the visual scanner, you must provide your own API key for your chosen provider (Google Gemini, OpenAI, or Anthropic) in the Settings page. However, **manual meal logging is always fully supported** at all times, even without an API key or active internet connection.

### 🔒 Privacy-First & Offline-First
Your health data belongs to you. NutriScan stores all of your records, nutritional breakdowns, and food photos directly on your device in a secure, high-performance local database. No cloud account is required to start tracking, keeping your data private, safe, and available even when you are completely offline.

### 🎨 Elite Visual Aesthetics
Immerse yourself in a luxurious slate-dark environment engineered to be easy on the eyes. Featuring vibrant emerald green progress rings, cobalt blue protein highlights, warm amber carbohydrate indicators, and crimson red fat trackers. Subtle micro-interactions, responsive hover states, and smooth layouts make keeping logs a delightful part of your day.

### ⚖️ Comprehensive Weight Tracking
Log your body weight alongside your meals. NutriScan charts your weight trends in relation to your daily intake, letting you see the direct correlation between your nutrition goals and your weight progress on a unified dashboard.

### 📂 Favorites & Easy Filtering
Quickly look back at your history or search for your favorite meals. With custom tags and favorites tracking, you can instantly find and repeat high-protein breakfasts, low-carb snacks, or balanced dinners with a single tap.

### 📄 Elegant PDF Summary Reports
Create high-end, professional PDF reports of your nutritional logs. Generate single-meal summary sheets containing personal notes and photos, or comprehensive multi-day summaries featuring full macro tables, budget achievements, and a stylized food photo album gallery to share with your nutritionist or trainer.

### 🌐 Seamless Multi-Platform Navigation
Whether you are on your Android phone or your Windows Desktop, NutriScan adapts beautifully. Enjoy a clean bottom navigation bar on mobile viewports, or switch to a full-screen, multi-column dashboard with a professional left-hand sidebar on desktop.

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

1. **Multi-Provider AI Scanning**:
   - Analyzes photos using Gemini, OpenAI, Anthropic, or Custom AI endpoints with strict structured JSON schemas to guarantee exact calorie and macro totals.
   - Interactive Verification Form allows users to review and adjust values before saving.

2. **Offline-First SQLite Storage**:
   - Highly performant database schema storing meal descriptions, macro grams (Protein, Carbohydrates, Lipid Fats), total calories, body weight in kg, AI confidence ratings, notes, dates, and raw photo bytes (BLOB).
   - Utilizes `sqflite` on Android and FFI bindings on Windows Desktop.

3. **Multi-Platform Responsiveness**:
   - Mobile Layout (bottom bar) vs. Desktop Layout (left sidebar).
   - Handled dynamically via `ResponsiveLayout`.

4. **Analytical Dashboard**:
   - Calorie ring progress indicator, sliding calendar date selector, and a vertical bar chart displaying calorie history over the last 7 days.

5. **Bidirectional Cloud Sync**:
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
