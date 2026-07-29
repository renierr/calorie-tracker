import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_tracker/helpers/db_helper.dart';
import 'package:calorie_tracker/models/meal_model.dart';
import 'package:calorie_tracker/providers/app_state.dart';
import 'package:calorie_tracker/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for in-memory database execution
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Gamification Production Code Tests (In-Memory SQLite, 0 Disk Touch)', () {
    late Database inMemoryDb;
    late AppState appState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      inMemoryDb = await databaseFactory.openDatabase(inMemoryDatabasePath);
      await DbHelper.instance.initOnCreateForTesting(inMemoryDb);
      DbHelper.instance.setDatabaseForTesting(inMemoryDb);

      appState = AppState(secureStorage: InMemorySecureStorage());
      await appState.loadGamification();
    });

    tearDown(() async {
      await inMemoryDb.close();
      DbHelper.instance.setDatabaseForTesting(null);
    });

    test(
      'awardXp executes real level ups and triggers 10th star milestone celebration',
      () async {
        // Initial state
        expect(appState.gamificationStats.level, 1);
        expect(appState.gamificationStats.xp, 0);

        // Award 200 XP -> Level 2
        await appState.awardXp(200);

        expect(appState.gamificationStats.xp, 200);
        expect(appState.gamificationStats.level, 2);
        expect(appState.showLevelUpNotification, isTrue);
        expect(appState.showConfetti, isTrue);

        appState.dismissLevelUpNotification();
        expect(appState.showLevelUpNotification, isFalse);

        // Award 15,200 XP more -> Total 15,400 XP (Level 10 + 10 Prestige Stars)
        await appState.awardXp(15200);

        expect(appState.gamificationStats.xp, 15400);
        expect(appState.gamificationStats.level, 10);
        expect(appState.gamificationStats.prestigeStars, 10);
        expect(appState.showPrestigeMilestoneNotification, isTrue);
        expect(appState.prestigeMilestoneStarCount, 10);
        expect(appState.showConfetti, isTrue);

        // Verify stats persisted to SQLite
        final dbStats = await DbHelper.instance.getGamificationStats();
        expect(dbStats.xp, 15400);
        expect(dbStats.level, 10);
      },
    );

    test(
      'Adding a meal triggers onMealAdded and unlocks spark badge',
      () async {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final meal = Meal(
          shortId: 'MEAL-0001',
          foodName: 'Oatmeal',
          calories: 350,
          protein: 15,
          carbs: 60,
          fat: 5,
          confidence: 100,
          timestamp: nowMs,
          updatedAt: nowMs,
        );

        await DbHelper.instance.insertMeal(meal);
        await appState.onMealAdded();

        expect(appState.gamificationStats.xp, 10);
        expect(
          appState.gamificationStats.unlockedBadges.contains('spark'),
          isTrue,
        );
        expect(appState.showConfetti, isTrue);

        // Verify persistence in SQLite
        final dbStats = await DbHelper.instance.getGamificationStats();
        expect(dbStats.unlockedBadges, contains('spark'));
      },
    );

    test('Inserting 50 photo meals unlocks photo_gourmet badge', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final dummyImage = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

      for (int i = 1; i <= 50; i++) {
        final meal = Meal(
          shortId: 'MEAL-${1000 + i}',
          foodName: 'Photo Meal $i',
          calories: 200,
          protein: 10,
          carbs: 20,
          fat: 5,
          confidence: 100,
          timestamp: nowMs + i,
          updatedAt: nowMs + i,
          imageBytes: dummyImage,
        );
        await DbHelper.instance.insertMeal(meal);
      }

      await appState.onMealAdded();

      expect(
        appState.gamificationStats.unlockedBadges.contains('photo_gourmet'),
        isTrue,
      );
    });

    test('Inserting 10 favorite meals unlocks favorite_chef badge', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      for (int i = 1; i <= 10; i++) {
        final meal = Meal(
          shortId: 'MEAL-${2000 + i}',
          foodName: 'Favorite Meal $i',
          calories: 400,
          protein: 20,
          carbs: 40,
          fat: 10,
          confidence: 100,
          timestamp: nowMs + i,
          updatedAt: nowMs + i,
          isFavorite: 1,
        );
        await DbHelper.instance.insertMeal(meal);
      }

      await appState.onMealAdded();

      expect(
        appState.gamificationStats.unlockedBadges.contains('favorite_chef'),
        isTrue,
      );
    });

    test(
      'Live today meal checks trigger bullseye, protein_pro, macro_balance, and burn_master',
      () async {
        final nowMs = DateTime.now().millisecondsSinceEpoch;

        // Food meal meeting exact calorie goal (2000), protein goal (150), carbs (200), fat (60)
        final meal = Meal(
          shortId: 'MEAL-PERFECT',
          foodName: 'Balanced Dinner',
          calories: 2500,
          protein: 150,
          carbs: 180,
          fat: 50,
          confidence: 100,
          timestamp: nowMs,
          updatedAt: nowMs,
        );
        await DbHelper.instance.insertMeal(meal);

        // Activity burning 500 calories -> Net intake = 2000 kcal (Exact Goal Bullseye!)
        final activity = Meal(
          shortId: Meal.generateRandomActivityShortId(),
          foodName: 'Running Workout',
          calories: 500,
          protein: 0,
          carbs: 0,
          fat: 0,
          confidence: 100,
          timestamp: nowMs + 10,
          updatedAt: nowMs + 10,
        );
        await DbHelper.instance.insertMeal(activity);

        await appState.onMealAdded();

        final unlocked = appState.gamificationStats.unlockedBadges;
        expect(unlocked, contains('bullseye'));
        expect(unlocked, contains('protein_pro'));
        expect(unlocked, contains('macro_balance'));
        expect(unlocked, contains('burn_master'));
      },
    );

    test(
      'recalculateAllGamification processes history and unlocks streak, calorie_saver, and comeback_kid badges',
      () async {
        final now = DateTime.now();

        // Populate past history with:
        // Day 1: Under 50% calorie goal (e.g. 800 kcal) -> unlocks calorie_saver
        // Days 2-8: Successful days -> unlocks triple_discipline & week_king
        for (int i = 8; i >= 1; i--) {
          final date = now.subtract(Duration(days: i));
          final cals = i == 8 ? 800 : 1800; // Day 1 is 800 kcal (<50% of 2000)

          final meal = Meal(
            shortId: 'MEAL-HIST-$i',
            foodName: 'History Meal $i',
            calories: cals,
            protein: 100,
            carbs: 200,
            fat: 50,
            confidence: 100,
            timestamp: date.millisecondsSinceEpoch,
            updatedAt: date.millisecondsSinceEpoch,
          );
          await DbHelper.instance.insertMeal(meal);
        }

        // Set previous highestStreak = 10 so comeback_kid triggers on currentStreak >= 7
        await DbHelper.instance.updateGamificationStats(
          appState.gamificationStats.copyWith(highestStreak: 10),
        );

        await appState.recalculateAllGamification();

        final unlocked = appState.gamificationStats.unlockedBadges;
        expect(unlocked, contains('triple_discipline'));
        expect(unlocked, contains('week_king'));
        expect(unlocked, contains('calorie_saver'));
        expect(unlocked, contains('comeback_kid'));
      },
    );

    test(
      'Milestone badges (hundred_day_legend, year_titan, diary_veteran, calorie_archivist, thousand_club, prestige_pioneer, shield_collector)',
      () async {
        // High XP & Shields -> prestige_pioneer & shield_collector
        await appState.awardXp(15400); // 10 Prestige Stars

        // Insert 100 meals to test diary_veteran
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        for (int i = 1; i <= 100; i++) {
          final meal = Meal(
            shortId: 'MEAL-VOL-$i',
            foodName: 'Meal $i',
            calories: 100,
            protein: 5,
            carbs: 10,
            fat: 2,
            confidence: 100,
            timestamp: nowMs + i,
            updatedAt: nowMs + i,
          );
          await DbHelper.instance.insertMeal(meal);
        }

        // Set high streak (100) directly in SQLite
        await DbHelper.instance.updateGamificationStats(
          appState.gamificationStats.copyWith(
            currentStreak: 100,
            highestStreak: 100,
            shields: 10,
          ),
        );

        // Reload state from SQLite
        await appState.loadGamification();
        await appState.onMealAdded();

        final unlocked = appState.gamificationStats.unlockedBadges;
        expect(unlocked, contains('hundred_day_legend'));
        expect(unlocked, contains('diary_veteran'));
        expect(unlocked, contains('prestige_pioneer'));
        expect(unlocked, contains('shield_collector'));
      },
    );

    test('loadGamification migrates old German badge IDs in SQLite', () async {
      // Directly insert legacy German string into SQLite table
      await inMemoryDb.insert('gamification_stats', {
        'id': 1,
        'xp': 1500,
        'level': 5,
        'shields': 2,
        'current_streak': 7,
        'highest_streak': 7,
        'unlocked_badges': 'zundfunke,dreifache_disziplin,wochen_koenig',
        'acknowledged_badges': 'zundfunke',
        'last_processed_date': '2026-07-28',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Load gamification
      await appState.loadGamification();

      // Check that German IDs were migrated to English IDs in memory
      expect(appState.gamificationStats.unlockedBadges, [
        'spark',
        'triple_discipline',
        'week_king',
      ]);
      expect(appState.gamificationStats.acknowledgedBadges, ['spark']);
    });
  });
}
