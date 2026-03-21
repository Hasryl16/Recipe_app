enum MealType { Breakfast, Lunch, Dinner, Snack }

class MealPlanModel {
  final int? id;
  final int userId;
  final int recipeId;
  final DateTime planDate;
  final MealType mealType;
  final String? recipeTitle; // Helper for UI
  final String? recipeImageUrl; // Helper for UI

  MealPlanModel({
    this.id,
    required this.userId,
    required this.recipeId,
    required this.planDate,
    required this.mealType,
    this.recipeTitle,
    this.recipeImageUrl,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'],
      userId: json['user_id'],
      recipeId: json['recipe_id'],
      planDate: DateTime.parse(json['plan_date']),
      mealType: MealType.values.firstWhere(
        (e) => e.toString().split('.').last == json['meal_type'],
      ),
      recipeTitle: json['recipe_title'],
      recipeImageUrl: json['recipe_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'plan_date': planDate.toIso8601String().split('T')[0],
      'meal_type': mealType.toString().split('.').last,
    };
  }
}
