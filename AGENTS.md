# AI Developer Guidelines & Project Playbook (AGENTS.md)

Welcome, AI Developer! This playbook provides the technical rules, architectural guardrails, design aesthetics, and structured extension guides for maintaining and scaling the **NutriScan Calorie Tracker** codebase. 

Please read and follow these instructions meticulously to maintain code quality and prevent regressions.

---

## Priority Model

- `ALWAYS`: Hard constraints. Do not violate.
- `PREFER`: Default behavior. Use unless there is a clear reason not to.
- `WHEN RELEVANT`: Apply only when the task needs it.

---

## ALWAYS

- **Caveman terse style** (caveman.md): REQUIRED. Drop filler, articles, pleasantries.
- Do not run production compilation or release builds unless the user explicitly asks or final verification was requested.
- **Git Write Consent**: Do not `git add`, `git commit`, `git push`, or run any git write operation unless the user explicitly says "commit" or "push". Prior consent does not carry forward — each write requires a fresh explicit command.
- Never mention AI agents, co-authorship, or AI generation in commit messages or code.
- **State Management & Data Flow**: Always channel database operations, macro targets, and date navigations through `AppState` in `lib/providers/app_state.dart`. Never update local state variables in individual views for data that should persist.
- **SQLite Constraints**: Database operations are strictly asynchronous. Always return `Future<T>` and handle interactions inside `AppState`. Store images as `Uint8List? imageBytes` (`BLOB` in SQL). Never use native local file paths for persistence.
- **PDF Class Overlaps**: Always import the PDF layout framework as `pw` (`import 'package:pdf/widgets.dart' as pw;`) to prevent class namespace collisions between PDF widgets (e.g. `pw.Text`) and standard Flutter Material widgets.

---

## PREFER

- Keep answers short and concise.
- Use English for code, comments, and docs.
- Use explicit return types for methods and actions.
- Avoid using custom hex codes inside individual views. Always reference static variables from `AppTheme` in `lib/theme/theme.dart`.
- Bind UI screens to state changes using `Consumer<AppState>` or `Provider.of<AppState>(context)`. Use `listen: false` when accessing state inside button callbacks or helper actions.
- Log errors with context, for example: `print('[Service/Page Name] message: $error')`.

---

## Architectural Guardrails

### 1. State Management & Data Flow
- **Standard**: We use the `provider` package combined with Dart's native `ChangeNotifier` (`AppState`) for state management.
- **Rule**: Never update local state variables in views for data that should persist. All database operations, daily macro targets, date navigations, and preferences MUST be channeled through `AppState` in `lib/providers/app_state.dart`.
- **UI Binding**: Always read or listen to state fields using `Consumer<AppState>` or `Provider.of<AppState>(context)` to ensure screens rebuild automatically on database changes. Use `listen: false` when accessing state inside button callbacks.

### 2. SQLite Database Constraints
- **Standard**: We use `sqflite` with dynamic `sqflite_common_ffi` loading for Windows Desktop.
- **Ffi Binding**: The initialization inside `DbHelper._initDatabase` must remain intact. If you modify database helpers, ensure you never block platform checks (`Platform.isWindows`, etc.).
- **Image Blobs**: Store images as `Uint8List? imageBytes` in SQLite (mapped as `BLOB` type in SQL). Never use native local file paths for persistence, as paths differ between Android scopes and Windows file systems.
- **Async Execution**: SQLite operations are strictly asynchronous. Always return `Future<T>` and handle database interactions inside `AppState` to prevent blocking the UI thread.

### 3. Gemini AI structured Scanning
- **Standard**: Visual meal scanning in `lib/services/gemini_service.dart` utilizes Gemini's native structured JSON capability.
- **Response Schema**: When updating prompt guidelines or fields, you **must** update the corresponding `Schema.object` definition in the `GenerativeModel` config. This ensures the AI model returns valid JSON conforming to our `AIAnalysisResult` model.
- **API Key Storage**: API keys are securely handled in `AppState` and persisted via `shared_preferences`. Never hardcode an API key in any service or file!

### 4. PDF Reporting Constraints
- **Standard**: PDF documents are built using `pdf/widgets.dart` and printed via `printing`.
- **Collision Avoidance**: Always import the PDF layout framework as `pw`:
  ```dart
  import 'package:pdf/widgets.dart' as pw;
  ```
  This prevents class namespace collisions between PDF widgets (e.g. `pw.Text`, `pw.Column`, `pw.Row`) and standard Flutter Material widgets.
- **Image Rendering**: Pass raw SQLite database image bytes to the document using `pw.MemoryImage(meal.imageBytes!)` after verifying the blob is not null.

### 5. Design & Responsive Aesthetics
- **Standard**: We follow a premium, high-contrast Dark Mode-first visual system.
- **Theme Variables**: Never hardcode colors, padding values, or card decorations in individual views. Always reference `AppTheme` from `lib/theme/theme.dart`:
  - Main Backdrop: `AppTheme.background`
  - Cards & Modals: `AppTheme.surface`
  - Calories/Goals: `AppTheme.accentEmerald`
  - Protein: `AppTheme.accentBlue`
  - Carbs: `AppTheme.accentAmber`
  - Lipids: `AppTheme.accentRed`
- **Responsive Layout**: All core views must mount inside `ResponsiveLayout` (`lib/widgets/responsive_layout.dart`). Ensure new pages accommodate both Mobile bottom navigation tabs and Desktop left navigation sidebar drawers.

---

## Further Development Roadmap (Scaling Guides)

Follow these guides to implement new features when requested:

### Guide A: Adding Sync Backend (Multi-Device Sync)
To support multi-device backup and synchronization (matching the reference TypeScript SyncManager framework):
1.  **Introduce Sync Metadata**: Add `synced` (int, 0 or 1) and `deleted` (int, 0 or 1) columns to the `meals` SQLite database table.
2.  **Define REST Client**: Create `lib/services/sync_service.dart` using the `http` package to fetch pulled updates and push un-synced local changes to a cloud backend.
3.  **Implement Sync Engine**:
    - During local CRUD inserts/updates, set `synced = 0` and update `updatedAt`.
    - Create a sync action in `AppState` that pulls recent items from the cloud database where `updatedAt > localLastSyncTime`, applies conflict resolution, and uploads un-synced local changes (`synced = 0`).
    - Save local sync timestamp in `shared_preferences`.

### Guide B: Adding Barcode Nutritional Scanning
To allow users to scan nutritional barcodes on packaged goods:
1.  **Add Barcode Scanner Package**: Include `mobile_scanner: ^5.0.0` in `pubspec.yaml`.
2.  **Integrate Scanner View**: Create `lib/pages/barcode_scanner_page.dart` using a camera preview block overlay. When a barcode is detected, pop the page returning the string code.
3.  **Query Nutrition APIs**: Create `lib/services/openfoodfacts_service.dart` to query barcode data:
    ```dart
    final response = await http.get(Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json'));
    ```
4.  **Parse and Display**: Extract calories, protein, carbs, and fat from the API payload and load the values directly into the **Nutrition Verification Form** in `ScanPage` to let the user log the snack!

### Guide C: Adding Nutrient Limit Alerts (Local Notifications)
To prompt notifications when daily limits are exceeded:
1.  **Add Notification Package**: Add `flutter_local_notifications: ^17.0.0` to `pubspec.yaml`.
2.  **Initialize Notifications**: Setup native channels in `lib/main.dart` for both Android and Windows (e.g. using `win_toast` or local wrappers).
3.  **Check Budgets**: In `AppState.addMeal` or `AppState.updateMeal`, check if `totalCaloriesConsumed > calorieGoal`.
4.  **Trigger Alert**: If target values are exceeded, call the notification helper to display a system tray banner alert:
    - *Title*: "Daily Calorie Budget Exceeded!"
    - *Body*: "You have consumed $totalCaloriesConsumed of $calorieGoal kcal. Watch your macros!"

---

## Verification Procedures

When submitting changes to this codebase, you **must** verify compilation and stability:

1.  **Formatting**:
    Ensure code complies with Dart conventions:
    ```bash
    flutter format ./lib
    ```

2.  **Analysis**:
    Verify there are no static analyzer warnings or errors:
    ```bash
    flutter analyze
    ```

3.  **Unit Testing**:
    Ensure all unit tests pass completely before concluding:
    ```bash
    flutter test
    ```
