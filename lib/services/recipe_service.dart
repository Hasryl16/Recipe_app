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

  Future<List<RecipeModel>> getAllRecipes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/recipes-all'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> createNewRecipe(String token, RecipeModel recipe) async {
    if (recipe.title.isEmpty) throw Exception('Title is required');
    await _repository.saveRecipe(token, recipe);
  }

  Future<void> updateRecipe(String token, RecipeModel recipe) async {
    if (recipe.title.isEmpty) throw Exception('Title is required');
    await _repository.updateRecipe(token, recipe);
  }

  Future<void> deleteRecipe(String token, int recipeId) async {
    await _repository.deleteRecipe(token, recipeId);
  }

  Future<List<RecipeModel>> getRecipesByAuthor(int authorId) {
    return _repository.getRecipesByAuthor(authorId);
  }

  Future<List<RecipeModel>> searchRecipes(String query) {
    if (query.trim().isEmpty) return getRecommendedRecipes();
    return _repository.searchRecipes(query);
  }

  // --- Bookmarking (Saved Recipes) ---
  
  // Helper method for robust mapping
  List<RecipeModel> _mapToRecipes(dynamic data) {
    if (data is! List) return [];
    
    final List<RecipeModel> recipes = [];
    for (var item in data) {
      try {
        if (item is Map<String, dynamic>) {
          // Normalize keys to lowercase for robustness
          final normalized = item.map((k, v) => MapEntry(k.toLowerCase(), v));
          recipes.add(RecipeModel.fromJson(normalized));
        }
      } catch (e) {
        print('Error mapping individual recipe in service: $e');
      }
    }
    return recipes;
  }

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
      return _mapToRecipes(jsonDecode(response.body));
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
