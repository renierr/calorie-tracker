class AIAnalysisResult {
  final String foodName;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int confidence;
  final String notes;

  AIAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.notes,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      foodName: json['foodName'] as String? ?? 'Meal',
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      confidence: json['confidence'] as int? ?? 85,
      notes: json['notes'] as String? ?? '',
    );
  }
}
