# Gamification System Documentation

Welcome to the **NutriScan Gamification & Habit Loop** framework. This document outlines how the tracking loop operates, when accomplishments are processed, and the underlying technical architecture.

---

## 1. System Overview

The system reinforces daily tracking consistency using game design mechanics:
- **Experience Points (XP)**: Continuous granular rewards for tracking actions.
- **Levels (1-10)**: Progress milestones based on total accumulated XP.
- **Daily Streak**: Track consecutive days stayed under the calorie budget.
- **Streak Protection (Shields)**: Consumable items that safeguard active streaks from breaking due to overeating or missing a day.
- **Accomplishment Badges**: One-time trophy milestones for core achievements.

### What happens when Max Level is reached? (Prestige Stars)
- The maximum level is capped at **Level 10 ("Calorie Ninja")** requiring `5400 XP`.
- Once Level 10 is reached, the user enters the **Prestige Star System**:
  - Every additional **1000 XP** earned beyond `5400 XP` automatically awards **+1 Prestige Star** and **+1 Streak Shield**.
  - Prestige Stars are displayed next to the title (e.g., `Level 10 Calorie Ninja (⭐ x2)`).
  - The progress bar in the `GamificationCard` dynamically tracks progress towards the next 1000 XP Prestige Star (e.g., `400 XP to next Star`).
  - Crossing a prestige threshold triggers an elegant celebratory Indigo/Purple dialog popup with confetti and a +1 Shield reward notification.


---

## 2. Evaluation Cycles & Trigger Conditions

Gamification rules are divided into **Immediate Triggers**, **Daily Transition Processes**, and **Retroactive Historical Re-evaluations**.

### Immediate Triggers (Real-time Actions)
These actions process instantly when user modifies records:

| Event | Action / Condition | Reward | UI/UX Feedback |
|---|---|---|---|
| **Add Meal** | User logs any meal. | `+10 XP` | Updates progress bar instantly. |
| **Delete Meal** | User deletes a logged meal. | `-10 XP` | Recalculates remaining allowance. |
| **First-day Target** | Today's total kcal $\le$ goal (on first logged meal). | `+100 XP` | Confetti animation + "Spark" badge unlocked dialog. |
| **Exceed Budget** | Total kcal exceeds goal on active streak day. | Auto-consumes `1 Shield` (if $>0$). Otherwise resets streak to `0`. | Dialog notification alerting the user of active shield consumption or streak reset. |

### Retroactive Historical Checks (Retroactive Entries)
- **Problem**: Users can log or edit meals retroactively for past days in the calendar.
- **Solution**: Whenever historical logs are modified, added, or deleted, the app automatically executes an extremely fast retroactive database re-evaluation (`recalculateAllGamification()`).
- **Optimization**: To avoid making slow sequential daily database queries over years of calendar records ($O(N)$ DB roundtrips), the re-evaluation uses exactly **one grouped SQL query** via `getDailyCalorieSummaries()` to fetch all daily calorie totals and meal counts.
- **Process**: The system maps the query results into a local date-lookup cache and performs chronological date-traversal and streak checks **entirely in-memory** in $O(N)$ with $O(1)$ database latency. This guarantees instantaneous UI updates and 100% data consistency even if the user logs historical data out of order!

### Daily Transition Check (Startup & Refresh)
Runs once on app startup or database reload when the current date advances past `last_processed_date`. It processes all missing days sequentially:

```
[Fetch meals for missing day D]
         |
         +---> Meals logged?
                 |
                 +---> YES: Total kcal <= goal?
                 |       |
                 |       +---> YES: [Daily Success]
                 |       |            - Streak increments (+1)
                 |       |            - Award +100 XP
                 |       |            - Check & unlock Day 3 or Day 7 badges
                 |       |
                 |       +---> NO: [Daily Overeating]
                 |            - Shields > 0?
                 |                 |
                 |                 +---> YES: Consume 1 Shield (Streak preserved)
                 |                 +---> NO: Streak resets to 0
                 |
                 +---> NO: [No tracking / Skipped day]
                         - Streak resets to 0 (Shield cannot protect empty tracking days)
```

---

## 3. UI/UX Milestones & Render Triggers

Modern visual cues reward user actions at specific thresholds:

### 🔥 Streak Milestones
- **Level 1-2 Streaks**: Regular styling.
- **Streak $\ge$ 3 Days**: Calorie counter ring gains an outer glowing border (`AppTheme.accentAmber`) and a miniature flame emoji loders next to consumption statistics.

### 🏆 Badge Milestones

```
  [Spark / Zündfunke]        [Threefold Discipline]         [Week King / Wochen-König]
     (Lightning Bolt)             (Streak Flame)                  (Gold Trophy)
           |                            |                               |
     First day under             3 consecutive days              7 consecutive days
      calorie budget.             under calorie budget.           under calorie budget.
                                                                  Awards +1 Streak Shield
```

---

## 4. Technical Architecture & Extensions

The system is fully decoupled and ready to support advanced game mechanics.

### SQLite Data Persistence (`gamification_stats` table)
Stats are stored in a single-row configuration to ensure atomic, persistent state transitions.
- **XP**: `INTEGER NOT NULL DEFAULT 0`
- **Level**: `INTEGER NOT NULL DEFAULT 1`
- **Shields**: `INTEGER NOT NULL DEFAULT 0`
- **Current Streak**: `INTEGER NOT NULL DEFAULT 0`
- **Highest Streak**: `INTEGER NOT NULL DEFAULT 0`
- **Unlocked Badges**: `TEXT NOT NULL DEFAULT ''` (Comma-separated IDs)
- **Last Processed Date**: `TEXT` (`YYYY-MM-DD` tracking daily boundary transitions)

### Provider Layer Integration (`_GamificationState` mixin)
Located in [app_state_gamification.dart](file:///C:/dev/flutter/calorie-tracker/lib/providers/app_state_gamification.dart) and mixed into `AppState`.
- Exposes clean reactive getters (`gamificationStats`, `showConfetti`, `recentUnlockedBadge`).
- Call `AppState.awardXp(int amount)` to add XP from external integrations (e.g. step counters or weight logs).

### Overlay Execution Pattern (Anti-Collision Dialogs)
To prevent widget tree rebuild errors and stop duplicate dialog windows from cascading, notifications are immediately dismissed inside post-frame callbacks before launching the dialog route. Dialog methods accept specific parameters directly rather than reading dynamic state:

```dart
if (appState.recentUnlockedBadge != null) {
  final badge = appState.recentUnlockedBadge!;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    appState.dismissBadgeNotification(); // Dismisses instantly to clear trigger state
    GamificationDialogs.showBadgeUnlocked(context, appState, badge);
  });
}
```

### Immersive Confetti Presentation
To prevent the colorful falling particle graphics from rendering underneath the dialog route, the `ConfettiWidget` is placed directly inside a `Stack` within the `Dialog`'s `ClipRRect` content wrapper:
```dart
Dialog(
  child: ClipRRect(
    child: Stack(
      children: [
        Padding(child: Column(...)), // Dialog Content
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiWidget(onFinished: () {}),
          ),
        ),
      ],
    ),
  ),
)
```

### User Preferences & Switch Controls
The gamification experience is fully optional.
- **Toggle Setting**: A custom toggle card inside `SettingsPage` navigates the user to a dedicated `GamificationSettingsPage`.
- **State Switch**: Users can toggle `Enable Gamification Mechanics` to shut off XP gains, hide the `GamificationCard` from the dashboard, and deactivate burning flame animations inside the `CalorieRingCard`.
- **Material Ink Splash Compliance**: When placing `SwitchListTile` inside card decors, always wrap it in a transparent `Material` widget (`color: Colors.transparent`) to provide the necessary canvas for rendering ink splash indicators without throwing Flutter framework assertion exceptions.
- **Administrative Testing Tools**: Developers can use the custom button grid in the admin panel to trigger each individual dialog (including standard levels, badges, shields, and prestige stars) alongside confetti particle emitters immediately in real-time, verifying correct rendering instantly.

### Adding New Badges
To add a new badge (e.g. *Water Intake Hero*):
1. Add badge translation keys to [app_en.arb](file:///C:/dev/flutter/calorie-tracker/lib/l10n/app_en.arb) and [app_de.arb](file:///C:/dev/flutter/calorie-tracker/lib/l10n/app_de.arb).
2. Append evaluation condition in `runDailyTransitionCheck()` or `checkImmediateAchievements()` inside `app_state_gamification.dart`.
3. Add the badge mapping details to `_showBadgesSheet` inside `gamification_card.dart` and `showBadgeUnlocked` in `gamification_dialogs.dart`.
4. Run `flutter gen-l10n` to rebuild localizations.
