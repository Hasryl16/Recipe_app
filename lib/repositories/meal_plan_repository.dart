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
      final response = await http.post(
        Uri.parse('$baseUrl/meal-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(plan.toJson()),
      );
      
      if (response.body.isEmpty) {
        throw Exception('Empty response from server (Status: ${response.statusCode})');
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Server returned invalid JSON: ${response.body.substring(0, 50)}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(data is Map ? (data['message'] ?? 'Status ${response.statusCode}') : 'Status ${response.statusCode}');
      }
      
      if (data is Map && data['status'] == 'error') {
        throw Exception(data['message'] ?? 'Backend error when planning meal');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeMealFromPlan(int planId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/meal-plan?id=$planId'),
      );
      
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (response.statusCode != 200) {
          throw Exception(data['message'] ?? 'Failed to delete meal plan');
        }
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Backend error when deleting');
        }
      } else if (response.statusCode != 200) {
        throw Exception('Failed to delete meal plan (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
