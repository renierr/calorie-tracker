import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_tracker/models/meal_model.dart';

void main() {
  group('Meal Model Tests', () {
    test('Meal initialization and map serialization', () {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4]);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final meal = Meal(
        id: 1,
        shortId: 'MEAL-TEST123',
        foodName: 'Avocado Salad',
        calories: 350,
        protein: 8,
        carbs: 12,
        fat: 30,
        confidence: 95,
        imageBytes: sampleBytes,
        notes: 'Delicious healthy meal',
        timestamp: timestamp,
        updatedAt: timestamp,
      );

      // Verify fields
      expect(meal.id, 1);
      expect(meal.shortId, 'MEAL-TEST123');
      expect(meal.foodName, 'Avocado Salad');
      expect(meal.calories, 350);
      expect(meal.protein, 8);
      expect(meal.carbs, 12);
      expect(meal.fat, 30);
      expect(meal.confidence, 95);
      expect(meal.imageBytes, sampleBytes);
      expect(meal.notes, 'Delicious healthy meal');
      expect(meal.timestamp, timestamp);
      expect(meal.updatedAt, timestamp);

      // Convert to Map
      final map = meal.toMap();
      expect(map['id'], 1);
      expect(map['shortId'], 'MEAL-TEST123');
      expect(map['foodName'], 'Avocado Salad');
      expect(map['calories'], 350);
      expect(map['protein'], 8);
      expect(map['carbs'], 12);
      expect(map['fat'], 30);
      expect(map['confidence'], 95);
      expect(map['imageBytes'], sampleBytes);
      expect(map['notes'], 'Delicious healthy meal');
      expect(map['timestamp'], timestamp);
      expect(map['updatedAt'], timestamp);
    });

    test('Meal factory deserialization from Map', () {
      final sampleBytes = Uint8List.fromList([5, 6, 7, 8]);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final map = {
        'id': 2,
        'shortId': 'MEAL-TEST456',
        'foodName': 'Steak with Broccoli',
        'calories': 550,
        'protein': 45,
        'carbs': 10,
        'fat': 35,
        'confidence': 90,
        'imageBytes': sampleBytes,
        'notes': 'High protein dinner',
        'timestamp': timestamp,
        'updatedAt': timestamp,
      };

      final meal = Meal.fromMap(map);

      expect(meal.id, 2);
      expect(meal.shortId, 'MEAL-TEST456');
      expect(meal.foodName, 'Steak with Broccoli');
      expect(meal.calories, 550);
      expect(meal.protein, 45);
      expect(meal.carbs, 10);
      expect(meal.fat, 35);
      expect(meal.confidence, 90);
      expect(meal.imageBytes, sampleBytes);
      expect(meal.notes, 'High protein dinner');
      expect(meal.timestamp, timestamp);
      expect(meal.updatedAt, timestamp);
    });
  });
}
