import 'dart:io';

import 'package:health_connector/health_connector.dart' as hc;

import '../models/meal_model.dart';

/// Health Connect identifies a record by the writing app and this stable ID.
/// Meal short IDs are synchronized, so the same meal upserts on every device.
const healthConnectNutritionClientIdPrefix = 'nutriscan:meal:';

enum HealthConnectPublishOutcome { ran, unsupported, noPermission, failed }

class HealthConnectPublishResult {
  final HealthConnectPublishOutcome outcome;
  final int published;
  final int failed;

  const HealthConnectPublishResult(
    this.outcome, {
    this.published = 0,
    this.failed = 0,
  });
}

class HealthConnectNutritionPublisher {
  HealthConnectNutritionPublisher._();

  static final HealthConnectNutritionPublisher instance =
      HealthConnectNutritionPublisher._();

  bool _isPublishing = false;

  Future<HealthConnectPublishResult> publishMeals(
    List<Meal> meals, {
    void Function(int processed, int total)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.unsupported,
      );
    }
    if (_isPublishing) {
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.failed,
      );
    }

    _isPublishing = true;
    try {
      final connector = await hc.HealthConnector.create();
      if (!await _ensureWriteAccess(connector)) {
        return const HealthConnectPublishResult(
          HealthConnectPublishOutcome.noPermission,
        );
      }

      var published = 0;
      var failed = 0;
      final mealRecords = meals.where((meal) => meal.isMeal).toList();
      for (var index = 0; index < mealRecords.length; index++) {
        final meal = mealRecords[index];
        try {
          await connector.writeRecords([_recordFor(meal)]);
          published++;
        } catch (error) {
          failed++;
          stderr.writeln(
            '[HealthConnect] Failed to publish ${meal.shortId}: $error',
          );
        }
        onProgress?.call(index + 1, mealRecords.length);
      }
      return HealthConnectPublishResult(
        HealthConnectPublishOutcome.ran,
        published: published,
        failed: failed,
      );
    } catch (error) {
      stderr.writeln('[HealthConnect] Nutrition publishing failed: $error');
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.failed,
        failed: 1,
      );
    } finally {
      _isPublishing = false;
    }
  }

  /// Removes only Nutrition records written by NutriScan, then recreates the
  /// active meal set. This is used after a meal deletion and by the explicit
  /// removal control in settings.
  Future<HealthConnectPublishResult> reconcileMeals(
    List<Meal> meals, {
    void Function(int processed, int total)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.unsupported,
      );
    }
    if (_isPublishing) {
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.failed,
      );
    }

    _isPublishing = true;
    try {
      final connector = await hc.HealthConnector.create();
      if (!await _ensureWriteAccess(connector)) {
        return const HealthConnectPublishResult(
          HealthConnectPublishOutcome.noPermission,
        );
      }
      await connector.deleteRecords(
        hc.HealthDataType.nutrition.deleteInTimeRange(
          startTime: DateTime(2000),
          endTime: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      var published = 0;
      var failed = 0;
      final mealRecords = meals.where((meal) => meal.isMeal).toList();
      for (var index = 0; index < mealRecords.length; index++) {
        final meal = mealRecords[index];
        try {
          await connector.writeRecords([_recordFor(meal)]);
          published++;
        } catch (error) {
          failed++;
          stderr.writeln(
            '[HealthConnect] Failed to publish ${meal.shortId}: $error',
          );
        }
        onProgress?.call(index + 1, mealRecords.length);
      }
      return HealthConnectPublishResult(
        HealthConnectPublishOutcome.ran,
        published: published,
        failed: failed,
      );
    } catch (error) {
      stderr.writeln('[HealthConnect] Nutrition reconciliation failed: $error');
      return const HealthConnectPublishResult(
        HealthConnectPublishOutcome.failed,
        failed: 1,
      );
    } finally {
      _isPublishing = false;
    }
  }

  Future<HealthConnectPublishResult> removeAll() async {
    return reconcileMeals(const []);
  }

  Future<bool> _ensureWriteAccess(hc.HealthConnector connector) async {
    final permission = hc.HealthDataType.nutrition.writePermission;
    final results = await connector.requestPermissions([permission]);
    if (results.any((result) => result.status == hc.PermissionStatus.granted)) {
      return true;
    }
    try {
      return (await connector.getGrantedPermissions()).contains(permission);
    } catch (error) {
      stderr.writeln('[HealthConnect] Permission lookup failed: $error');
      return false;
    }
  }

  hc.NutritionRecord _recordFor(Meal meal) {
    final start = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
    return hc.NutritionRecord(
      startTime: start,
      endTime: start.add(const Duration(seconds: 1)),
      foodName: meal.foodName,
      energy: hc.Energy.kilocalories(meal.calories.toDouble()),
      protein: hc.Mass.grams(meal.protein.toDouble()),
      totalCarbohydrate: hc.Mass.grams(meal.carbs.toDouble()),
      totalFat: hc.Mass.grams(meal.fat.toDouble()),
      metadata: hc.Metadata.manualEntry(
        clientRecordId: '$healthConnectNutritionClientIdPrefix${meal.shortId}',
        clientRecordVersion: meal.updatedAt,
      ),
    );
  }
}
