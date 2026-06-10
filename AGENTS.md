# AI Developer Guidelines & Project Playbook (AGENTS.md)

Welcome, AI Developer! This playbook provides the technical rules, architectural guardrails, and design aesthetics for maintaining and scaling the **NutriScan Calorie Tracker** codebase.

For detailed schemas, protocol sequences, and format specifications, refer to [AGENTS.detail.md](file:///C:/dev/flutter/calorie-tracker/AGENTS.detail.md).

---

## Priority Model

- `ALWAYS`: Hard constraints. Do not violate.
- `PREFER`: Default behavior. Use unless there is a clear reason not to.

---

## ALWAYS

- **Caveman style**: Short, direct answers. No filler.
- Do not run production compilation or release builds unless explicitly requested.
- **Git Write Consent**: Never run git write operations (`git add`, `git commit`, `git push`) without fresh explicit approval for each write command. "Fix it" or "proceed" is not approval to commit or push — ask first. A single "commit" or "push" in a prompt does not authorize further commits later in the same session — each requires its own explicit approval.
- Never mention AI agents, co-authorship, or AI generation in commit messages or code. This includes `Co-Authored-By: Claude ...` trailers and any "Generated with Claude Code" attribution in commits or PR descriptions — omit them entirely.
- **Resilience to Rejected Commands**: If a user rejects or stops a command execution, continue the task and provide the alternative results or plan. A rejected command must not abort the overall execution.
- **State Management & Data Flow**: Always channel database operations, macro targets, date navigations, body weight logging (`weightKg`), and history filters through `AppState` in `lib/providers/app_state.dart`. Never update local state variables in views for persistent data.
- **SQLite Constraints**: Database operations are strictly asynchronous. Return `Future<T>` and handle inside `AppState`. Store images as `Uint8List? imageBytes` (`BLOB` in SQL). Never use native local file paths for persistence.
- **PDF Class Overlaps**: Import PDF framework as `pw` (`import 'package:pdf/widgets.dart' as pw;`) to prevent collisions with standard Material widgets.
- **Small Screen Fitting**: Always use responsive layouts (like `Wrap` instead of horizontal `Row` for actions, and scrollable/grid metrics) in dialogs, modals, and cards to prevent overflow on mobile.
- **Cross-Platform File Saving**: Always check OS before saving files (e.g. SQLite database copies, downloaded images). On Desktop, use `getSaveLocation()`. On Android, implement automatic fallback from public Download (`/storage/emulated/0/Download`) to app-specific directory (`getExternalStorageDirectory()`) to avoid permission/platform crashes.
- **Prevent Duplicated UI/Dialog Code**: Extract custom dialogs, overlays, notification components, or recurring visual elements to `lib/widgets/` immediately. Never copy-paste presentation logic across views.
- **Use Existing Custom Widgets**: Always reuse existing custom widgets in `lib/widgets/` (such as `ResponsiveIconButton`, `ResponsiveLayout`, or `AdaptiveCardHeader`) rather than declaring standard material buttons, layout parameters, or headers from scratch. Check the codebase for existing reusable options before writing presentation code.

---

## PREFER

- Keep answers extremely short and concise.
- Use English for code, comments, and docs.
- Use explicit return types for methods.
- Reference colors from `AppTheme` in `lib/theme/theme.dart`. No hardcoded hex codes.
- Bind UI screens to state using `Consumer<AppState>`, `context.watch<AppState>()`, or `context.read<AppState>()`. Prefer `context.watch<T>()` over `Provider.of<T>(context)` and `context.read<T>()` over `Provider.of<T>(context, listen: false)` for cleaner, modern 2026 syntax. Use `context.read<T>()` in button callbacks and lifecycle methods.
- Log errors with clear service or page context prefixes to make debugging easy.
- Extract dialogs, detailed cards, or list items to `lib/widgets/` to promote modular codebase structure.
- Extract repetitive visual components to shared reusable widgets to maintain consistency.
- **Private Widgets over Helpers**: Prefer declaring private `StatelessWidget` classes instead of helper methods returning `Widget` to optimize element tree lifecycles and rebuilds.
- **Const Constructors**: Prefer using `const` constructors for widgets and in `build()` methods where possible to reduce rebuilds.
- **Lazy Lists**: Prefer `ListView.builder` or slivers for dynamic, long, or performance-sensitive lists.

---

## Core Guardrails

### 1. State Management & UI Binding
- Standard: `provider` + `ChangeNotifier` (`AppState`).
- Ensure UI automatically rebuilds by binding via standard consumers.

### 2. Database & Assets
- Standard: `sqflite` + dynamic `sqflite_common_ffi` (Desktop).
- Images must persist exclusively as SQLite `BLOB` bytes, never raw OS absolute file paths.
- **Activity Tracking**: Unified `meals` table stores both food and physical activities. Differentiated solely by `shortId` prefix: `MEAL-` for foods, and `ACT-` for physical exercises.

### 3. Multi-Provider AI Scanning
- Service: Supports multiple AI models (Gemini, OpenAI, Anthropic, Custom AI) selected dynamically in settings and routed via `AIServiceConfig` and `AIServiceFactory`.
- Schema: Strict structured JSON matching `AIAnalysisResult` for exact calorie and macro estimations.

### 4. Styling & Layouts
- Theme variables from `AppTheme`: `background`, `surface`, `accentEmerald`, `accentBlue`, `accentAmber`, `accentRed`.
- Responsive layout container: `ResponsiveLayout` (`lib/widgets/responsive_layout.dart`).

### 5. Multi-Language & Localization
- Rule: Always use `AppLocalizations.of(context)!` for UI text. Never hardcode English strings.
- Process: Regenerate l10n code via `flutter gen-l10n` after modifying `.arb` assets. Detail specifications in [AGENTS.detail.md](file:///C:/dev/flutter/calorie-tracker/AGENTS.detail.md#4-multi-language--localization).

---

## Dependencies

Dependencies in `pubspec.yaml`. Check there before adding new packages.

---

## Verification Procedures

*Note: Formatting and static analysis are only required when Dart/source code files are changed. They are not necessary when only markdown documentation, images, or static assets are modified.*

1. **Formatting**: `dart format ./lib`
2. **Analysis**: `flutter analyze`
