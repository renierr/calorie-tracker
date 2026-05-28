import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart';
import '../models/meal_model.dart';

class SyncService {
  static const String _logPrefix = '[SyncService]';

  /// Check if the backend server is reachable at the given base URL.
  static Future<bool> isBackendAvailable(String baseUrl) async {
    try {
      final sanitizedUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final uri = Uri.parse('$sanitizedUrl/api/sync/ping');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('$_logPrefix Backend check failed: $e');
      return false;
    }
  }

  /// Perform bidirectional synchronization of the SQLite meal database with the cloud backend.
  static Future<Map<String, int>> sync({
    required String baseUrl,
    required String userId,
  }) async {
    final String sanitizedUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final String toolId =
        'calorie-tracker-${userId.trim().isEmpty ? 'user-1' : userId.trim()}';
    final DbHelper dbHelper = DbHelper.instance;

    int pulledCount = 0;
    int pushedCount = 0;
    int deletedCount = 0;

    // 1. Check availability
    final available = await isBackendAvailable(sanitizedUrl);
    if (!available) {
      throw Exception('Backend server unreachable');
    }

    // 2. Fetch server metadata (super lightweight, no image payload)
    final metadataUri = Uri.parse('$sanitizedUrl/api/sync/$toolId/metadata');
    final metadataResponse = await http.get(metadataUri);
    if (metadataResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch metadata from server: ${metadataResponse.statusCode}',
      );
    }

    final Map<String, dynamic> metadataJson = jsonDecode(metadataResponse.body);
    if (metadataJson['success'] != true) {
      throw Exception('Server returned success=false for metadata');
    }

    final List<dynamic> serverMetaList = metadataJson['records'] ?? [];

    // Map server metadata by record ID (shortId)
    final Map<String, _ServerMeta> serverMetaMap = {};
    for (final item in serverMetaList) {
      final id = item['id'] as String;
      serverMetaMap[id] = _ServerMeta(
        id: id,
        updatedAt: item['updatedAt'] as int? ?? 0,
        deleted: item['deleted'] as bool? ?? false,
      );
    }

    // 3. Get local records (including deleted ones)
    final List<Meal> localRecords = await dbHelper.getActiveAndDeletedMeals();

    final List<String> toPullIds = [];
    final List<Map<String, dynamic>> toPush = [];

    // 4. Resolve Deletions & Identify Pull Targets
    for (final sMeta in serverMetaMap.values) {
      final Meal? lRec = localRecords.cast<Meal?>().firstWhere(
        (r) => r?.shortId == sMeta.id,
        orElse: () => null,
      );

      if (sMeta.deleted) {
        if (lRec != null) {
          // Delete locally right away if server has deleted it, without fetching details
          await dbHelper.finalizeSync(lRec.shortId, true);
          deletedCount++;
        }
        continue;
      }

      if (lRec == null || sMeta.updatedAt > lRec.updatedAt) {
        toPullIds.add(sMeta.id);
      }
    }

    // 5. Identify Push Targets (Local -> Server)
    for (final lRec in localRecords) {
      final sMeta = serverMetaMap[lRec.shortId];

      if (lRec.deleted == 1) {
        // If marked as deleted locally and either not on server, or on server but local deletion is newer
        if (sMeta == null || lRec.updatedAt > sMeta.updatedAt) {
          toPush.add({
            'id': lRec.shortId,
            'updatedAt': lRec.updatedAt,
            'deleted': true,
          });
        }
      } else {
        // Active local record: push if not on server or if local record is newer
        if (sMeta == null || lRec.updatedAt > sMeta.updatedAt) {
          // Serialize record, translating imageBytes to base64 imageBlob
          final Map<String, dynamic> serializedData = {
            'shortId': lRec.shortId,
            'foodName': lRec.foodName,
            'calories': lRec.calories,
            'protein': lRec.protein,
            'carbs': lRec.carbs,
            'fat': lRec.fat,
            'confidence': lRec.confidence,
            'notes': lRec.notes ?? '',
            'timestamp': lRec.timestamp,
            'updatedAt': lRec.updatedAt,
            'weightKg': lRec.weightKg,
            'isFavorite': lRec.isFavorite,
            'imageBlob': lRec.imageBytes != null
                ? {
                    '__type': 'blob',
                    'mimeType': _detectMimeType(lRec.imageBytes!),
                    'data': base64Encode(lRec.imageBytes!),
                  }
                : null,
          };

          toPush.add({
            'id': lRec.shortId,
            'data': serializedData,
            'updatedAt': lRec.updatedAt,
            'deleted': false,
          });
        }
      }
    }

    // 6. Fast Path: Exit early if nothing to transfer!
    if (toPullIds.isEmpty && toPush.isEmpty) {
      return {
        'pulled': pulledCount,
        'pushed': pushedCount,
        'deleted': deletedCount,
      };
    }

    // 7. Delta Pulling: Retrieve only full records that changed
    List<dynamic> pulledRecords = [];
    if (toPullIds.isNotEmpty) {
      final pullUri = Uri.parse('$sanitizedUrl/api/sync/$toolId/pull');
      final pullResponse = await http.post(
        pullUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': toPullIds}),
      );

      if (pullResponse.statusCode != 200) {
        throw Exception(
          'Failed to pull records from server: ${pullResponse.statusCode}',
        );
      }

      final Map<String, dynamic> pullJson = jsonDecode(pullResponse.body);
      if (pullJson['success'] != true) {
        throw Exception('Server returned success=false for pull request');
      }

      pulledRecords = pullJson['records'] ?? [];
    }

    // 8. Merge Pulled Records -> Local SQLite
    for (final sRec in pulledRecords) {
      final String shortId = sRec['id'] as String;
      final bool serverDeleted = sRec['deleted'] as bool? ?? false;
      final int serverUpdatedAt = sRec['updatedAt'] as int? ?? 0;

      final Meal? lRec = localRecords.cast<Meal?>().firstWhere(
        (r) => r?.shortId == shortId,
        orElse: () => null,
      );

      if (serverDeleted) {
        if (lRec != null) {
          await dbHelper.finalizeSync(shortId, true);
          deletedCount++;
        }
        continue;
      }

      if (lRec == null || serverUpdatedAt > lRec.updatedAt) {
        final data = sRec['data'] as Map<String, dynamic>;
        final Uint8List? imageBytes = _deserializeImage(data['imageBlob']);

        final mealToSave = Meal(
          id: lRec?.id, // Keep SQLite database row ID if updating
          shortId: shortId,
          foodName: data['foodName'] as String? ?? 'Unknown Meal',
          calories: (data['calories'] as num?)?.toInt() ?? 0,
          protein: (data['protein'] as num?)?.toInt() ?? 0,
          carbs: (data['carbs'] as num?)?.toInt() ?? 0,
          fat: (data['fat'] as num?)?.toInt() ?? 0,
          confidence: (data['confidence'] as num?)?.toInt() ?? 100,
          imageBytes: imageBytes,
          notes: data['notes'] as String?,
          weightKg: (data['weightKg'] as num?)?.toDouble(),
          timestamp:
              data['timestamp'] as int? ??
              DateTime.now().millisecondsSinceEpoch,
          updatedAt: serverUpdatedAt,
          synced: 1, // Marked as synced in SQLite immediately
          deleted: 0,
          isFavorite:
              (data['isFavorite'] as num?)?.toInt() ?? lRec?.isFavorite ?? 0,
        );

        if (lRec != null) {
          await dbHelper.updateMeal(mealToSave);
        } else {
          await dbHelper.insertMeal(mealToSave);
        }
        pulledCount++;
      }
    }

    // 9. Push Local Changes to Server
    if (toPush.isNotEmpty) {
      final pushUri = Uri.parse('$sanitizedUrl/api/sync/$toolId');
      final pushResponse = await http.post(
        pushUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'records': toPush}),
      );

      if (pushResponse.statusCode != 200) {
        throw Exception(
          'Failed to push records to server: ${pushResponse.statusCode}',
        );
      }

      final Map<String, dynamic> pushJson = jsonDecode(pushResponse.body);
      if (pushJson['success'] != true) {
        throw Exception('Server returned success=false for push request');
      }

      // Finalize database states locally
      for (final pushItem in toPush) {
        final String shortId = pushItem['id'] as String;
        final bool isDel = pushItem['deleted'] as bool;
        await dbHelper.finalizeSync(shortId, isDel);
        pushedCount++;
      }
    }

    return {
      'pulled': pulledCount,
      'pushed': pushedCount,
      'deleted': deletedCount,
    };
  }

  static String _detectMimeType(Uint8List bytes) {
    if (bytes.length > 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return 'image/jpeg';
      } else if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      } else if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x47) {
        return 'image/webp';
      }
    }
    return 'image/png';
  }

  static Uint8List? _deserializeImage(dynamic imageBlobObj) {
    if (imageBlobObj == null) return null;
    if (imageBlobObj is Map<String, dynamic>) {
      if (imageBlobObj['__type'] == 'blob' && imageBlobObj['data'] is String) {
        try {
          return base64Decode(imageBlobObj['data'] as String);
        } catch (e) {
          debugPrint('$_logPrefix Failed to decode base64 image: $e');
        }
      }
    } else if (imageBlobObj is Map) {
      if (imageBlobObj['__type'] == 'blob' && imageBlobObj['data'] is String) {
        try {
          return base64Decode(imageBlobObj['data'] as String);
        } catch (e) {
          debugPrint('$_logPrefix Failed to decode base64 image: $e');
        }
      }
    }
    return null;
  }
}

class _ServerMeta {
  final String id;
  final int updatedAt;
  final bool deleted;

  _ServerMeta({
    required this.id,
    required this.updatedAt,
    required this.deleted,
  });
}
