import 'package:flutter/foundation.dart';
import 'repositories/recipe_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/meal_plan_repository.dart';
import 'services/recipe_service.dart';
import 'services/auth_service.dart';
import 'services/meal_plan_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RecipeService recipeService;
  late final AuthService authService;
  late final MealPlanService mealPlanService;

  void init() {
    final baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

    final recipeRepo = RemoteRecipeRepository(baseUrl: baseUrl);
    final userRepo = RemoteUserRepository(baseUrl: baseUrl);
    final mealPlanRepo = RemoteMealPlanRepository(baseUrl: baseUrl);

    recipeService = RecipeService(recipeRepo);
    authService = AuthService(userRepo);
    mealPlanService = MealPlanService(mealPlanRepo);
  }
}

final locator = ServiceLocator();
