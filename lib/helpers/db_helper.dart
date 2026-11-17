import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/meal_model.dart';
import '../models/gamification_model.dart';

class DbHelper {
  static const String _dbName = 'calorie_tracker.db';
  static const int _dbVersion = 7;
  static const String tableMeals = 'meals';
  static const String tableImages = 'meal_images';

  /// Resolves a meal's image: shared (deduplicated) image first, legacy
  /// inline `imageBytes` as fallback for rows not yet optimized.
  static const String _imageColumn =
      'COALESCE((SELECT bytes FROM $tableImages '
      'WHERE $tableImages.hash = $tableMeals.imageHash), '
      '$tableMeals.imageBytes) AS imageBytes';

  static const List<String> _baseColumns = [
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
  ];

  static List<String> _columns({required bool includeImages}) => [
    ..._baseColumns,
    if (includeImages) _imageColumn,
  ];

  // Private constructor
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  Database? _database;

  @visibleForTesting
  void setDatabaseForTesting(Database? db) {
    _database = db;
  }

  @visibleForTesting
  Future<void> initOnCreateForTesting(Database db) async {
    await _onCreate(db, _dbVersion);
  }

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
        weightKg REAL,
        imageHash TEXT
      )
    ''');
    await _createImageTable(db);

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
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE $tableMeals ADD COLUMN imageHash TEXT');
      await _createImageTable(db);
    }
  }

  Future<void> _createImageTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableImages (
        hash TEXT PRIMARY KEY,
        bytes BLOB NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_meals_imageHash ON $tableMeals(imageHash)',
    );
  }

  /// Stores image bytes once (keyed by SHA-256) and returns the row map
  /// referencing it via `imageHash`. Returns whether the image was new.
  Future<({Map<String, dynamic> row, bool isNewImage})> _toRowWithImageRef(
    DatabaseExecutor txn,
    Meal meal,
  ) async {
    final row = meal.toMap();
    final Uint8List? bytes = row.remove('imageBytes') as Uint8List?;
    row['imageBytes'] = null;
    if (bytes == null || bytes.isEmpty) {
      row['imageHash'] = null;
      return (row: row, isNewImage: false);
    }
    final hash = sha256.convert(bytes).toString();
    final inserted = await txn.insert(tableImages, {
      'hash': hash,
      'bytes': bytes,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    row['imageHash'] = hash;
    return (row: row, isNewImage: inserted > 0);
  }

  /// Removes shared images no longer referenced by any meal row.
  Future<int> _deleteOrphanImages(DatabaseExecutor db) {
    return db.rawDelete('''
      DELETE FROM $tableImages
      WHERE hash NOT IN (
        SELECT imageHash FROM $tableMeals WHERE imageHash IS NOT NULL
      )
    ''');
  }

  // CRUD Operations

  Future<int> insertMeal(Meal meal) async {
    final Database db = await database;
    return await db.transaction((txn) async {
      final prepared = await _toRowWithImageRef(txn, meal);
      final id = await txn.insert(
        tableMeals,
        prepared.row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // A replaced row may have dropped the last reference to an image.
      await _deleteOrphanImages(txn);
      return id;
    });
  }

  Future<List<Meal>> getAllMeals({bool includeImages = false}) async {
    final Database db = await database;

    final List<String> columns = _columns(includeImages: includeImages);

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
      columns: _columns(includeImages: true),
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
      columns: _columns(includeImages: true),
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
    return await db.transaction((txn) async {
      final prepared = await _toRowWithImageRef(txn, meal);
      final count = await txn.update(
        tableMeals,
        prepared.row,
        where: 'id = ?',
        whereArgs: [meal.id],
      );
      await _deleteOrphanImages(txn);
      return count;
    });
  }

  /// Updates only the favorite flag without touching the image reference.
  Future<int> updateMealFavorite(Meal meal) async {
    final Database db = await database;
    return await db.update(
      tableMeals,
      {
        'isFavorite': meal.isFavorite,
        'synced': meal.synced,
        'updatedAt': meal.updatedAt,
      },
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
        final count = await db.delete(
          tableMeals,
          where: 'id = ?',
          whereArgs: [id],
        );
        await _deleteOrphanImages(db);
        return count;
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
    final count = await db.delete(tableMeals);
    await db.delete(tableImages);
    return count;
  }

  Future<List<Meal>> getUnsyncedMeals() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: _columns(includeImages: true),
      where: 'synced = 0',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<List<Meal>> getActiveAndDeletedMeals() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      columns: _columns(includeImages: false),
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  Future<void> finalizeSync(String shortId, bool wasDeleted) async {
    final Database db = await database;
    if (wasDeleted) {
      await db.delete(tableMeals, where: 'shortId = ?', whereArgs: [shortId]);
      await _deleteOrphanImages(db);
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
    int offset = 0,
    String filterType = 'all',
    String typeFilter = 'all',
    DateTime? customStart,
    DateTime? customEnd,
    String searchQuery = '',
    bool includeImages = false,
  }) async {
    final Database db = await database;

    final List<String> columns = _columns(includeImages: includeImages);

    final filter = _buildFilterConditions(
      filterType: filterType,
      typeFilter: typeFilter,
      customStart: customStart,
      customEnd: customEnd,
    );
    final List<String> whereClauses = ['deleted = 0', ...filter.clauses];
    final List<dynamic> whereArgs = [...filter.args];

    final search = _buildSearchConditions(searchQuery);
    if (search != null) {
      whereClauses.add(search.clause);
      whereArgs.addAll(search.args);
    }
    if (beforeTimestamp != null) {
      whereClauses.add('timestamp < ?');
      whereArgs.add(beforeTimestamp);
    }

    final query = StringBuffer(
      'SELECT ${columns.join(', ')} FROM $tableMeals '
      'WHERE ${whereClauses.join(' AND ')} '
      'ORDER BY ${search?.orderBy ?? 'timestamp DESC'}',
    );
    final queryArgs = <dynamic>[...whereArgs, ...?search?.orderArgs];
    if (limit != null) {
      query.write(' LIMIT ?');
      queryArgs.add(limit);
      if (search != null) {
        query.write(' OFFSET ?');
        queryArgs.add(offset);
      }
    }
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      query.toString(),
      queryArgs,
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

    final List<String> columns = _columns(includeImages: includeImages);

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
    String searchQuery = '',
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
    final search = _buildSearchConditions(searchQuery);
    if (search != null) {
      whereClauses.add(search.clause);
      whereArgs.addAll(search.args);
    }

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
      columns: [_imageColumn],
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
    final List<String> columns = _columns(includeImages: includeImages);
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

  /// Builds a case-insensitive all-words search and ranks title matches before
  /// note matches.
  ({String clause, List<String> args, String orderBy, List<String> orderArgs})?
  _buildSearchConditions(String query) {
    final words = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return null;

    final patterns = words
        .map(
          (word) =>
              '%${word.replaceAllMapped(RegExp(r'[\\%_]'), (match) => '\\${match[0]}')}%',
        )
        .toList();
    final titleClauses = patterns
        .map((_) => "foodName LIKE ? ESCAPE '\\' COLLATE NOCASE")
        .join(' AND ');
    final noteClauses = patterns
        .map((_) => "COALESCE(notes, '') LIKE ? ESCAPE '\\' COLLATE NOCASE")
        .join(' AND ');

    return (
      clause: "(($titleClauses) OR ($noteClauses))",
      args: [...patterns, ...patterns],
      orderBy: "CASE WHEN $titleClauses THEN 0 ELSE 1 END, timestamp DESC",
      orderArgs: patterns,
    );
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
        SUM(CASE WHEN shortId LIKE 'ACT-%' THEN calories ELSE 0 END) as burned_calories,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN 1 ELSE 0 END) as meal_count,
        SUM(CASE WHEN shortId LIKE 'ACT-%' THEN 1 ELSE 0 END) as activity_count,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN protein ELSE 0 END) as total_protein,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN carbs ELSE 0 END) as total_carbs,
        SUM(CASE WHEN shortId NOT LIKE 'ACT-%' THEN fat ELSE 0 END) as total_fat
      FROM $tableMeals
      WHERE deleted = 0
      GROUP BY log_date
      ORDER BY log_date ASC
    ''');
  }

  Future<Map<String, dynamic>> getImageStorageStats() async {
    final Database db = await database;
    // count = entries with a photo; total_bytes = bytes actually stored
    // (shared images counted once, plus legacy inline images).
    final result = await db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM $tableMeals
          WHERE deleted = 0
            AND (imageHash IS NOT NULL OR imageBytes IS NOT NULL)) as count,
        (SELECT COALESCE(SUM(LENGTH(bytes)), 0) FROM $tableImages
          WHERE hash IN (SELECT imageHash FROM $tableMeals
            WHERE deleted = 0 AND imageHash IS NOT NULL))
        + (SELECT COALESCE(SUM(LENGTH(imageBytes)), 0) FROM $tableMeals
          WHERE deleted = 0 AND imageBytes IS NOT NULL) as total_bytes
    ''');
    return result.first;
  }

  /// Image storage overview for maintenance: unique stored images, their
  /// size and legacy (not yet deduplicated) inline images.
  Future<({int sharedCount, int sharedBytes, int legacyCount, int legacyBytes})>
  getImageDedupStats() async {
    final Database db = await database;
    final result = await db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM $tableImages) as shared_count,
        (SELECT COALESCE(SUM(LENGTH(bytes)), 0) FROM $tableImages)
          as shared_bytes,
        (SELECT COUNT(*) FROM $tableMeals WHERE imageBytes IS NOT NULL)
          as legacy_count,
        (SELECT COALESCE(SUM(LENGTH(imageBytes)), 0) FROM $tableMeals
          WHERE imageBytes IS NOT NULL) as legacy_bytes
    ''');
    final row = result.first;
    return (
      sharedCount: (row['shared_count'] as num?)?.toInt() ?? 0,
      sharedBytes: (row['shared_bytes'] as num?)?.toInt() ?? 0,
      legacyCount: (row['legacy_count'] as num?)?.toInt() ?? 0,
      legacyBytes: (row['legacy_bytes'] as num?)?.toInt() ?? 0,
    );
  }

  /// Moves legacy inline images into the shared image table so identical
  /// images are stored once, removes orphaned images and compacts the file.
  /// Content of entries is unchanged, so no re-sync is triggered.
  Future<({int processed, int duplicates, int savedBytes})>
  deduplicateImages() async {
    final Database db = await database;
    final ids = await db.query(
      tableMeals,
      columns: ['id'],
      where: 'imageBytes IS NOT NULL',
    );

    int processed = 0;
    int duplicates = 0;
    int savedBytes = 0;

    // Process row by row to keep memory low with many large images.
    for (final idRow in ids) {
      final id = idRow['id'] as int;
      await db.transaction((txn) async {
        final rows = await txn.query(
          tableMeals,
          columns: ['imageBytes'],
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rows.isEmpty) return;
        final bytes = rows.first['imageBytes'] as Uint8List?;
        if (bytes == null) return;
        if (bytes.isEmpty) {
          await txn.update(
            tableMeals,
            {'imageBytes': null, 'imageHash': null},
            where: 'id = ?',
            whereArgs: [id],
          );
          return;
        }
        final hash = sha256.convert(bytes).toString();
        final inserted = await txn.insert(tableImages, {
          'hash': hash,
          'bytes': bytes,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        if (inserted == 0) {
          duplicates++;
          savedBytes += bytes.length;
        }
        await txn.update(
          tableMeals,
          {'imageBytes': null, 'imageHash': hash},
          where: 'id = ?',
          whereArgs: [id],
        );
        processed++;
      });
    }

    await _deleteOrphanImages(db);
    // Reclaim freed pages so the database file actually shrinks.
    await db.execute('VACUUM');

    return (
      processed: processed,
      duplicates: duplicates,
      savedBytes: savedBytes,
    );
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
