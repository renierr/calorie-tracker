import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/meal_model.dart';
import '../models/gamification_model.dart';

class DbHelper {
  static const String _dbName = 'calorie_tracker.db';
  static const int _dbVersion = 6;
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
        isFavorite INTEGER NOT NULL DEFAULT 0,
        weightKg REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE gamification_stats (
        id INTEGER PRIMARY KEY,
        xp INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        shields INTEGER NOT NULL DEFAULT 0,
        current_streak INTEGER NOT NULL DEFAULT 0,
        highest_streak INTEGER NOT NULL DEFAULT 0,
        unlocked_badges TEXT NOT NULL DEFAULT '',
        last_processed_date TEXT,
        acknowledged_badges TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      INSERT INTO gamification_stats (id, xp, level, shields, current_streak, highest_streak, unlocked_badges, last_processed_date, acknowledged_badges)
      VALUES (1, 0, 1, 0, 0, 0, '', NULL, '')
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
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableMeals ADD COLUMN weightKg REAL');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE gamification_stats (
          id INTEGER PRIMARY KEY,
          xp INTEGER NOT NULL DEFAULT 0,
          level INTEGER NOT NULL DEFAULT 1,
          shields INTEGER NOT NULL DEFAULT 0,
          current_streak INTEGER NOT NULL DEFAULT 0,
          highest_streak INTEGER NOT NULL DEFAULT 0,
          unlocked_badges TEXT NOT NULL DEFAULT '',
          last_processed_date TEXT
        )
      ''');
      await db.execute('''
        INSERT OR IGNORE INTO gamification_stats (id, xp, level, shields, current_streak, highest_streak, unlocked_badges, last_processed_date)
        VALUES (1, 0, 1, 0, 0, 0, '', NULL)
      ''');
    }
    if (oldVersion < 6) {
      try {
        await db.execute(
          'ALTER TABLE gamification_stats ADD COLUMN acknowledged_badges TEXT NOT NULL DEFAULT ""',
        );
        await db.execute(
          'UPDATE gamification_stats SET acknowledged_badges = unlocked_badges',
        );
      } catch (e) {
        debugPrint('[DbHelper] Migration v6: $e');
      }
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
      'weightKg',
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
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: [
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
        'weightKg',
      ],
    );
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
    String typeFilter = 'all',
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
      'weightKg',
      if (includeImages) 'imageBytes',
    ];

    final filter = _buildFilterConditions(
      filterType: filterType,
      typeFilter: typeFilter,
      customStart: customStart,
      customEnd: customEnd,
    );
    final List<String> whereClauses = ['deleted = 0', ...filter.clauses];
    final List<dynamic> whereArgs = [...filter.args];

    if (beforeTimestamp != null) {
      whereClauses.add('timestamp < ?');
      whereArgs.add(beforeTimestamp);
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
      'weightKg',
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
    String typeFilter = 'all',
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    final Database db = await database;
    final filter = _buildFilterConditions(
      filterType: filterType,
      typeFilter: typeFilter,
      customStart: customStart,
      customEnd: customEnd,
    );
    final List<String> whereClauses = ['deleted = 0', ...filter.clauses];
    final List<dynamic> whereArgs = [...filter.args];

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $tableMeals WHERE ${whereClauses.join(' AND ')}',
      whereArgs,
    );
    return result.isNotEmpty ? result.first['cnt'] as int? ?? 0 : 0;
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
      'weightKg',
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

  /// Builds shared WHERE clause conditions for filterType/typeFilter.
  /// Returns (clauses, args). Caller prepends 'deleted = 0' and appends any
  /// query-specific conditions (e.g. beforeTimestamp).
  ({List<String> clauses, List<dynamic> args}) _buildFilterConditions({
    required String filterType,
    required String typeFilter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final clauses = <String>[];
    final args = <dynamic>[];

    if (typeFilter == 'meals') {
      clauses.add("shortId NOT LIKE 'ACT-%'");
    } else if (typeFilter == 'activities') {
      clauses.add("shortId LIKE 'ACT-%'");
    }

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    if (filterType == 'today') {
      final start = todayMidnight.millisecondsSinceEpoch;
      final end =
          todayMidnight.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      clauses.add('timestamp >= ? AND timestamp <= ?');
      args.addAll([start, end]);
    } else if (filterType == 'yesterday') {
      final yesterday = todayMidnight.subtract(const Duration(days: 1));
      final start = yesterday.millisecondsSinceEpoch;
      final end =
          yesterday.add(const Duration(days: 1)).millisecondsSinceEpoch - 1;
      clauses.add('timestamp >= ? AND timestamp <= ?');
      args.addAll([start, end]);
    } else if (filterType == 'week') {
      final sevenDaysAgo = todayMidnight.subtract(const Duration(days: 6));
      final start = sevenDaysAgo.millisecondsSinceEpoch;
      clauses.add('timestamp >= ?');
      args.add(start);
    } else if (filterType == 'favorites') {
      clauses.add('isFavorite = 1');
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
      clauses.add('timestamp >= ? AND timestamp <= ?');
      args.addAll([start, end]);
    }

    return (clauses: clauses, args: args);
  }

  // Gamification operations
  Future<GamificationStats> getGamificationStats() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gamification_stats',
      where: 'id = 1',
    );
    if (maps.isNotEmpty) {
      return GamificationStats.fromMap(maps.first);
    }
    return GamificationStats.initial();
  }

  Future<int> updateGamificationStats(GamificationStats stats) async {
    final Database db = await database;
    return await db.update(
      'gamification_stats',
      stats.toMap(),
      where: 'id = 1',
    );
  }

  Future<List<Map<String, dynamic>>> getDailyCalorieSummaries() async {
    final Database db = await database;
    return await db.rawQuery('''
      SELECT 
        date(timestamp / 1000, 'unixepoch', 'localtime') as log_date,
        SUM(CASE WHEN shortId LIKE 'ACT-%' THEN -calories ELSE calories END) as total_calories,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN 1 ELSE 0 END) as meal_count
      FROM $tableMeals
      WHERE deleted = 0
      GROUP BY log_date
      ORDER BY log_date ASC
    ''');
  }

  Future<Map<String, dynamic>> getImageStorageStats() async {
    final Database db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(LENGTH(imageBytes)), 0) as total_bytes
      FROM $tableMeals
      WHERE imageBytes IS NOT NULL AND deleted = 0
    ''');
    return result.first;
  }

  Future<int> getNotesCount() async {
    final Database db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM $tableMeals
      WHERE notes IS NOT NULL AND notes != '' AND deleted = 0
    ''');
    return result.first['count'] as int;
  }

  Future<Map<String, dynamic>> getDateRangeStats() async {
    final Database db = await database;
    final result = await db.rawQuery('''
      SELECT 
        MIN(timestamp) as first_entry,
        MAX(timestamp) as last_entry,
        COUNT(*) as total_entries,
        SUM(CASE WHEN shortId LIKE 'ACT-%' THEN 1 ELSE 0 END) as activity_count,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN 1 ELSE 0 END) as meal_count
      FROM $tableMeals
      WHERE deleted = 0
    ''');
    return result.first;
  }
}
