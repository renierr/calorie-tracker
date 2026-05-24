import 'dart:typed_data';

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
