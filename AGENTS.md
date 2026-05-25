# AI Developer Guidelines & Project Playbook (AGENTS.md)

Welcome, AI Developer! This playbook provides the technical rules, architectural guardrails, and design aesthetics for maintaining and scaling the **NutriScan Calorie Tracker** codebase.

For detailed schemas, protocol sequences, and format specifications, refer to [AGENTS.detail.md](file:///C:/dev/flutter/calorie-tracker/AGENTS.detail.md).

---

## Priority Model

- `ALWAYS`: Hard constraints. Do not violate.
- `PREFER`: Default behavior. Use unless there is a clear reason not to.

---

## ALWAYS

- **Caveman terse style** (caveman.md): REQUIRED. Drop filler, articles, pleasantries.
- Do not run production compilation or release builds unless explicitly requested.
- **Git Write Consent**: Never run git write operations (`git add`, `git commit`, `git push`) without fresh explicit approval for each write command.
- Never mention AI agents, co-authorship, or AI generation in commit messages or code.
- **Resilience to Rejected Commands**: If a user rejects or stops a command execution, continue the task and provide the alternative results or plan. A rejected command must not abort the overall execution.
- **State Management & Data Flow**: Always channel database operations, macro targets, and date navigations through `AppState` in `lib/providers/app_state.dart`. Never update local state variables in views for persistent data.
- **SQLite Constraints**: Database operations are strictly asynchronous. Return `Future<T>` and handle inside `AppState`. Store images as `Uint8List? imageBytes` (`BLOB` in SQL). Never use native local file paths for persistence.
- **PDF Class Overlaps**: Import PDF framework as `pw` (`import 'package:pdf/widgets.dart' as pw;`) to prevent collisions with standard Material widgets.
- **Small Screen Fitting**: Always use responsive layouts (like `Wrap` instead of horizontal `Row` for actions, and scrollable/grid metrics) in dialogs, modals, and cards to prevent overflow on mobile.

---

## PREFER

- Keep answers extremely short and concise.
- Use English for code, comments, and docs.
- Use explicit return types for methods.
- Avoid custom hex codes. Reference variables from `AppTheme` in `lib/theme/theme.dart`.
- Bind UI screens to state using `Consumer<AppState>` or `Provider.of<AppState>(context)`. Use `listen: false` in button callbacks.
- Log errors with clear service or page context prefixes to make debugging easy.
- Extract dialogs, detailed cards, or list items to `lib/widgets/` to promote modular codebase structure.
- Extract repetitive visual components to shared reusable widgets to maintain consistency.

---

## Core Guardrails

### 1. State Management & UI Binding
- Standard: `provider` + `ChangeNotifier` (`AppState`).
- Ensure UI automatically rebuilds by binding via standard consumers.

### 2. Database & Assets
- Standard: `sqflite` + dynamic `sqflite_common_ffi` (Desktop).
- Images must persist exclusively as SQLite `BLOB` bytes, never raw OS absolute file paths.

### 3. Gemini AI Scanning
- Service: `gemini-2.5-flash` with native structured JSON matching `AIAnalysisResult`.
- Ensure schema fields are updated in `GenerativeModel` config if rules/prompts change.

### 4. Styling & Layouts
- Theme variables from `AppTheme`: `background`, `surface`, `accentEmerald`, `accentBlue`, `accentAmber`, `accentRed`.
- Responsive layout container: `ResponsiveLayout` (`lib/widgets/responsive_layout.dart`).

### 5. Multi-Language & Localization
- Rule: Always use `AppLocalizations.of(context)!` for UI text. Never hardcode English strings.
- Process: Regenerate l10n code via `flutter gen-l10n` after modifying `.arb` assets. Detail specifications in [AGENTS.detail.md](file:///C:/dev/flutter/calorie-tracker/AGENTS.detail.md#4-multi-language--localization).

---

## Package Dependencies Reference

| Package | Purpose |
|---|---|
| `sqflite_common_ffi` | SQLite on Windows Desktop |
| `provider` | State management via `ChangeNotifier` |
| `shared_preferences` | API key and preferences persistence |
| `intl` / `flutter_localizations` | Date formatting and l10n |
| `image_picker` | Image selection |
| `file_selector` | Native Save As / Open dialogs |
| `pdf` (as `pw`) / `printing` | PDF reports generation and printing |
| `google_generative_ai` | Gemini structured scanning |

---

## Verification Procedures

1. **Formatting**: `dart format ./lib`
2. **Analysis**: `flutter analyze`
