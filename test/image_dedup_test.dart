import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_tracker/helpers/db_helper.dart';
import 'package:calorie_tracker/models/meal_model.dart';

Meal _meal(String shortId, Uint8List? image) => Meal(
  shortId: shortId,
  foodName: shortId,
  calories: 100,
  protein: 1,
  carbs: 1,
  fat: 1,
  confidence: 100,
  imageBytes: image,
  timestamp: DateTime.now().millisecondsSinceEpoch,
  updatedAt: DateTime.now().millisecondsSinceEpoch,
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  final helper = DbHelper.instance;
  final imgA = Uint8List.fromList(List.generate(1000, (i) => i % 251));
  final imgB = Uint8List.fromList(List.generate(500, (i) => i % 7));

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await helper.initOnCreateForTesting(db);
    helper.setDatabaseForTesting(db);
  });

  tearDown(() async {
    await db.close();
    helper.setDatabaseForTesting(null);
  });

  Future<int> imageRows() async =>
      (await db.rawQuery('SELECT COUNT(*) AS c FROM meal_images')).first['c']
          as int;

  test('identical images are stored once and resolved for each meal', () async {
    final id1 = await helper.insertMeal(_meal('MEAL-1', imgA));
    final id2 = await helper.insertMeal(_meal('MEAL-2', imgA));
    await helper.insertMeal(_meal('MEAL-3', imgB));

    expect(await imageRows(), 2);
    expect(await helper.getMealImageBytes(id1), imgA);
    expect(await helper.getMealImageBytes(id2), imgA);
    final all = await helper.getAllMeals(includeImages: true);
    expect(all.where((m) => m.imageBytes != null).length, 3);
  });

  test(
    'shared image survives deleting one reference, removed with last',
    () async {
      final id1 = await helper.insertMeal(_meal('MEAL-1', imgA));
      final id2 = await helper.insertMeal(_meal('MEAL-2', imgA));

      await helper.deleteMeal(id1);
      expect(await imageRows(), 1);
      expect(await helper.getMealImageBytes(id2), imgA);

      await helper.deleteMeal(id2);
      expect(await imageRows(), 0);
    },
  );

  test('favorite toggle keeps image, clearing image removes orphan', () async {
    final id = await helper.insertMeal(_meal('MEAL-1', imgA));
    final meal = (await helper.getMealById(id))!;

    await helper.updateMealFavorite(meal.copyWith(isFavorite: 1));
    expect(await helper.getMealImageBytes(id), imgA);

    final noImage = Meal.fromMap({...meal.toMap(), 'imageBytes': null});
    await helper.updateMeal(noImage);
    expect(await helper.getMealImageBytes(id), isNull);
    expect(await imageRows(), 0);
  });

  test('deduplicateImages migrates legacy inline images', () async {
    // Simulate rows written before deduplication existed.
    for (final (id, img) in [
      ('MEAL-1', imgA),
      ('MEAL-2', imgA),
      ('MEAL-3', imgB),
    ]) {
      await db.insert('meals', {..._meal(id, img).toMap()});
    }
    final before = await helper.getImageDedupStats();
    expect(before.legacyCount, 3);

    final result = await helper.deduplicateImages();
    expect(result.processed, 3);
    expect(result.duplicates, 1);
    expect(result.savedBytes, imgA.length);

    final after = await helper.getImageDedupStats();
    expect(after.legacyCount, 0);
    expect(after.sharedCount, 2);
    expect(after.sharedBytes, imgA.length + imgB.length);

    final all = await helper.getAllMeals(includeImages: true);
    expect(all.every((m) => m.imageBytes != null), isTrue);
  });
}
