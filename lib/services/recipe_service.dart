import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeService {
  final RecipeRepository _repository;
  final String _baseUrl = 'http://localhost:8000'; // Match PHP server port

  RecipeService(this._repository);

  Future<List<RecipeModel>> getTrendingRecipes() {
    return _repository.getTrendingRecipes();
  }

  Future<List<RecipeModel>> getRecommendedRecipes() {
    return _repository.getRecommendedRecipes();
  }

  Future<List<RecipeModel>> getFridgeRecipes(List<String> ingredients) {
    if (ingredients.isEmpty) return getRecommendedRecipes();
    return _repository.searchRecipesByIngredients(ingredients);
  }

  Future<RecipeModel> getRecipeById(int id) {
    return _repository.getRecipeById(id);
  }

  Future<void> createNewRecipe(RecipeModel recipe) async {
    if (recipe.title.isEmpty) throw Exception('Title is required');
    await _repository.saveRecipe(recipe);
  }

  Future<List<RecipeModel>> getRecipesByAuthor(int authorId) {
    return _repository.getRecipesByAuthor(authorId);
  }

  Future<List<RecipeModel>> searchRecipes(String query) {
    if (query.trim().isEmpty) return getRecommendedRecipes();
    return _repository.searchRecipes(query);
  }

  // --- Bookmarking (Saved Recipes) ---
  
  Future<List<RecipeModel>> getSavedRecipes(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookmarks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) return [];

      final dynamic decodedBody = jsonDecode(response.body);
      if (decodedBody is! List) return [];

      final List<RecipeModel> recipes = [];
      for (var item in decodedBody) {
        try {
          if (item is Map<String, dynamic>) {
            // Normalizing keys to lowercase for robustness
            final normalized = item.map((k, v) => MapEntry(k.toLowerCase(), v));
            recipes.add(RecipeModel.fromJson(normalized));
          }
        } catch (e) {
          // Log or skip individual broken recipe
          print('Error mapping individual recipe: $e');
        }
      }
      return recipes;
    } catch (e) {
      print('Fatal error in getSavedRecipes: $e');
      return [];
    }
  }

  Future<bool> toggleBookmark(String token, int recipeId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookmarks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'recipe_id': recipeId}),
      );
      
      final data = jsonDecode(response.body);
      return data['status'] == 'added' || data['status'] == 'removed';
    } catch (e) {
      return false;
    }
  }
}
