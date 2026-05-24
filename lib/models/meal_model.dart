import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as dart_math;

class Meal {
  final int? id;
  final String shortId;
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int confidence;
  final Uint8List? imageBytes;
  final String? notes;
  final int timestamp;
  final int updatedAt;

  Meal({
    this.id,
    required this.shortId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    this.imageBytes,
    this.notes,
    required this.timestamp,
    required this.updatedAt,
  });

  // Convert a Meal into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'shortId': shortId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'confidence': confidence,
      'imageBytes': imageBytes,
      'notes': notes,
      'timestamp': timestamp,
      'updatedAt': updatedAt,
    };
  }

  // Convert a Map from SQLite into a Meal object
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      shortId: map['shortId'] as String? ?? '',
      foodName: map['foodName'] as String? ?? 'Unknown Meal',
      calories: map['calories'] as int? ?? 0,
      protein: map['protein'] as int? ?? 0,
      carbs: map['carbs'] as int? ?? 0,
      fat: map['fat'] as int? ?? 0,
      confidence: map['confidence'] as int? ?? 100,
      imageBytes: map['imageBytes'] as Uint8List?,
      notes: map['notes'] as String?,
      timestamp:
          map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          map['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Convert a Meal into a Map matching the import/export JSON format specification
  Map<String, dynamic> toJsonExport() {
    return {
      'shortId': shortId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'confidence': confidence,
      'notes': notes ?? '',
      'timestamp': timestamp,
      'updatedAt': updatedAt,
      'image': _bytesToBase64DataUri(imageBytes),
    };
  }

  // Convert a JSON Map into a Meal object
  factory Meal.fromJsonExport(Map<String, dynamic> json) {
    // Generate random 9-character alphanumeric shortId matching ^MEAL-[A-Z0-9]{9}$ if missing
    final String parsedShortId =
        json['shortId'] as String? ?? _generateRandomShortId();

    return Meal(
      shortId: parsedShortId,
      foodName: json['foodName'] as String? ?? 'Unknown Meal',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toInt() ?? 100,
      imageBytes: _base64DataUriToBytes(json['image'] as String?),
      notes: json['notes'] as String? ?? '',
      timestamp:
          json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static String _generateRandomShortId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = dart_math.Random();
    final code = List.generate(
      9,
      (index) => chars[rnd.nextInt(chars.length)],
    ).join();
    return 'MEAL-$code';
  }

  static String? _bytesToBase64DataUri(Uint8List? bytes) {
    if (bytes == null) return null;
    String mimeType = 'image/png';
    if (bytes.length > 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        mimeType = 'image/jpeg';
      } else if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        mimeType = 'image/png';
      } else if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x47) {
        mimeType = 'image/webp';
      }
    }
    final base64Str = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64Str';
  }

  static Uint8List? _base64DataUriToBytes(String? dataUri) {
    if (dataUri == null || !dataUri.startsWith('data:image/')) return null;
    try {
      final parts = dataUri.split(',');
      if (parts.length < 2) return null;
      final base64Str = parts[1];
      return base64Decode(base64Str);
    } catch (e) {
      print('[MealModel] Failed to decode base64 image: $e');
      return null;
    }
  }

  // Create a copy of Meal with optional field updates
  Meal copyWith({
    int? id,
    String? shortId,
    String? foodName,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? confidence,
    Uint8List? imageBytes,
    String? notes,
    int? timestamp,
    int? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      shortId: shortId ?? this.shortId,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      confidence: confidence ?? this.confidence,
      imageBytes: imageBytes ?? this.imageBytes,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
