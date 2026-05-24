import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/meal_model.dart';

class DbHelper {
  static const String _dbName = 'calorie_tracker.db';
  static const int _dbVersion = 1;
  static const String tableMeals = 'meals';

  // Private constructor
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // If running on Desktop (Windows, macOS, Linux), initialize FFI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory docDir = await getApplicationSupportDirectory();
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    final String path = p.join(docDir.path, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMeals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shortId TEXT NOT NULL,
        foodName TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein INTEGER NOT NULL,
        carbs INTEGER NOT NULL,
        fat INTEGER NOT NULL,
        confidence INTEGER NOT NULL,
        imageBytes BLOB,
        notes TEXT,
        timestamp INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // CRUD Operations

  Future<int> insertMeal(Meal meal) async {
    final Database db = await database;
    return await db.insert(
      tableMeals,
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meal>> getAllMeals() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return Meal.fromMap(maps[i]);
    });
  }

  Future<Meal?> getMealById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Meal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMeal(Meal meal) async {
    final Database db = await database;
    return await db.update(
      tableMeals,
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(int id) async {
    final Database db = await database;
    return await db.delete(tableMeals, where: 'id = ?', whereArgs: [id]);
  }

  Future<String> get databasePath async {
    final Database db = await database;
    return db.path;
  }

  Future<File> exportDatabase({required String destPath}) async {
    final String src = await databasePath;
    final dest = File(destPath);
    await File(src).copy(dest.path);
    return dest;
  }

  Future<int> clearDatabase() async {
    final Database db = await database;
    return await db.delete(tableMeals);
  }
}
