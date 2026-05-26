import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/meal_model.dart';

class DbHelper {
  static const String _dbName = 'calorie_tracker.db';
  static const int _dbVersion = 3;
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

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
        updatedAt INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableMeals ADD COLUMN synced INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE $tableMeals ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $tableMeals ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
      );
    }
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

  Future<List<Meal>> getAllMeals({bool includeImages = false}) async {
    final Database db = await database;

    final List<String> columns = [
      'id',
      'shortId',
      'foodName',
      'calories',
      'protein',
      'carbs',
      'fat',
      'confidence',
      'notes',
      'timestamp',
      'updatedAt',
      'synced',
      'deleted',
      'isFavorite',
      if (includeImages) 'imageBytes',
    ];

    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: columns,
      where: 'deleted = 0',
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
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Meal.fromMap(maps.first);
    }
    return null;
  }

  Future<Meal?> getMealByShortId(String shortId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      where: 'shortId = ? AND deleted = 0',
      whereArgs: [shortId],
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
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: ['synced', 'shortId'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final int synced = maps.first['synced'] as int? ?? 0;
      if (synced == 0) {
        return await db.delete(tableMeals, where: 'id = ?', whereArgs: [id]);
      } else {
        return await db.update(
          tableMeals,
          {
            'deleted': 1,
            'synced': 0,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
    return 0;
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

  Future<void> restoreDatabase({required String backupPath}) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final Directory docDir = await getApplicationSupportDirectory();
    final String path = p.join(docDir.path, _dbName);
    final backupFile = File(backupPath);
    if (await backupFile.exists()) {
      await backupFile.copy(path);
    } else {
      throw Exception("Backup file does not exist");
    }
    await database;
  }

  Future<int> clearDatabase() async {
    final Database db = await database;
    return await db.delete(tableMeals);
  }

  Future<List<Meal>> getUnsyncedMeals() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      where: 'synced = 0',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<List<Meal>> getActiveAndDeletedMeals() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableMeals);
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<void> finalizeSync(String shortId, bool wasDeleted) async {
    final Database db = await database;
    if (wasDeleted) {
      await db.delete(tableMeals, where: 'shortId = ?', whereArgs: [shortId]);
    } else {
      await db.update(
        tableMeals,
        {'synced': 1},
        where: 'shortId = ?',
        whereArgs: [shortId],
      );
    }
  }

  Future<List<Meal>> getMealsPaginated({
    int? limit,
    int? beforeTimestamp,
    String filterType = 'all',
    DateTime? customStart,
    DateTime? customEnd,
    bool includeImages = false,
  }) async {
    final Database db = await database;

    final List<String> columns = [
      'id',
      'shortId',
      'foodName',
      'calories',
      'protein',
      'carbs',
      'fat',
      'confidence',
      'notes',
      'timestamp',
      'updatedAt',
      'synced',
      'deleted',
      'isFavorite',
      if (includeImages) 'imageBytes',
    ];

    final List<String> whereClauses = ['deleted = 0'];
    final List<dynamic> whereArgs = [];

    if (beforeTimestamp != null) {
      whereClauses.add('timestamp < ?');
      whereArgs.add(beforeTimestamp);
    }

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    if (filterType == 'today') {
      final start = todayMidnight.millisecondsSinceEpoch;
      final end =
          todayMidnight.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    } else if (filterType == 'yesterday') {
      final yesterday = todayMidnight.subtract(const Duration(days: 1));
      final start = yesterday.millisecondsSinceEpoch;
      final end =
          yesterday.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    } else if (filterType == 'week') {
      final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 6));
      final start = sevenDaysAgo.millisecondsSinceEpoch;
      whereClauses.add('timestamp >= ?');
      whereArgs.add(start);
    } else if (filterType == 'custom' &&
        customStart != null &&
        customEnd != null) {
      final start = DateTime(
        customStart.year,
        customStart.month,
        customStart.day,
      ).millisecondsSinceEpoch;
      final end = DateTime(
        customEnd.year,
        customEnd.month,
        customEnd.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: columns,
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<List<Meal>> getMealsForDate(
    DateTime date, {
    bool includeImages = true,
  }) async {
    final Database db = await database;
    final todayMidnight = DateTime(date.year, date.month, date.day);
    final start = todayMidnight.millisecondsSinceEpoch;
    final end =
        todayMidnight.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;

    final List<String> columns = [
      'id',
      'shortId',
      'foodName',
      'calories',
      'protein',
      'carbs',
      'fat',
      'confidence',
      'notes',
      'timestamp',
      'updatedAt',
      'synced',
      'deleted',
      'isFavorite',
      if (includeImages) 'imageBytes',
    ];

    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: columns,
      where: 'deleted = 0 AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [start, end],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<int> getMealsCount({
    String filterType = 'all',
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final Database db = await database;
    final List<String> whereClauses = ['deleted = 0'];
    final List<dynamic> whereArgs = [];

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    if (filterType == 'today') {
      final start = todayMidnight.millisecondsSinceEpoch;
      final end =
          todayMidnight.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    } else if (filterType == 'yesterday') {
      final yesterday = todayMidnight.subtract(const Duration(days: 1));
      final start = yesterday.millisecondsSinceEpoch;
      final end =
          yesterday.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    } else if (filterType == 'week') {
      final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 6));
      final start = sevenDaysAgo.millisecondsSinceEpoch;
      whereClauses.add('timestamp >= ?');
      whereArgs.add(start);
    } else if (filterType == 'custom' &&
        customStart != null &&
        customEnd != null) {
      final start = DateTime(
        customStart.year,
        customStart.month,
        customStart.day,
      ).millisecondsSinceEpoch;
      final end = DateTime(
        customEnd.year,
        customEnd.month,
        customEnd.day,
        23,
        59,
        59,
        999,
      ).millisecondsSinceEpoch;
      whereClauses.add('timestamp >= ? AND timestamp <= ?');
      whereArgs.addAll([start, end]);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableMeals WHERE ${whereClauses.join(' AND ')}',
      whereArgs,
    );
    if (maps.isNotEmpty && maps.first.isNotEmpty) {
      return maps.first.values.first as int? ?? 0;
    }
    return 0;
  }

  Future<Uint8List?> getMealImageBytes(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: ['imageBytes'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first['imageBytes'] as Uint8List?;
    }
    return null;
  }

  Future<List<Meal>> getFavoriteMeals({bool includeImages = true}) async {
    final Database db = await database;
    final List<String> columns = [
      'id',
      'shortId',
      'foodName',
      'calories',
      'protein',
      'carbs',
      'fat',
      'confidence',
      'notes',
      'timestamp',
      'updatedAt',
      'synced',
      'deleted',
      'isFavorite',
      if (includeImages) 'imageBytes',
    ];
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: columns,
      where: 'deleted = 0 AND isFavorite = 1',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }
}
