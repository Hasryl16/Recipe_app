import '../models/meal_plan_model.dart';
import '../repositories/meal_plan_repository.dart';

class MealPlanService {
  final MealPlanRepository _repository;

  MealPlanService(this._repository);

  Future<List<MealPlanModel>> getWeeklyPlan(int userId) {
    return _repository.getMealPlanForUser(userId);
  }

  Future<void> scheduleMeal(int userId, int recipeId, DateTime date, MealType type) async {
    final plan = MealPlanModel(
      userId: userId,
      recipeId: recipeId,
      planDate: date,
      mealType: type,
    );
    await _repository.addMealToPlan(plan);
  }

  Future<void> cancelMeal(int planId) {
    return _repository.removeMealFromPlan(planId);
  }
}
