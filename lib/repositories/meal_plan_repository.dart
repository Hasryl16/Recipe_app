import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_plan_model.dart';

abstract class MealPlanRepository {
  Future<List<MealPlanModel>> getMealPlanForUser(int userId);
  Future<void> addMealToPlan(MealPlanModel plan);
  Future<void> removeMealFromPlan(int planId);
}

class RemoteMealPlanRepository implements MealPlanRepository {
  final String baseUrl;
  RemoteMealPlanRepository({required this.baseUrl});

  @override
  Future<List<MealPlanModel>> getMealPlanForUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/meal-plan?user_id=$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MealPlanModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addMealToPlan(MealPlanModel plan) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/meal-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(plan.toJson()),
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> removeMealFromPlan(int planId) async {
    // Implement delete if needed
  }
}
