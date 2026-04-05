import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

abstract class RecipeRepository {
  Future<List<RecipeModel>> getTrendingRecipes();
  Future<List<RecipeModel>> getRecommendedRecipes();
  Future<RecipeModel> getRecipeById(int id);
  Future<List<RecipeModel>> searchRecipesByIngredients(List<String> ingredients);
  Future<void> saveRecipe(String token, RecipeModel recipe);
  Future<void> updateRecipe(String token, RecipeModel recipe);
  Future<void> deleteRecipe(String token, int recipeId);
  Future<List<RecipeModel>> getRecipesByAuthor(int authorId);
  Future<List<RecipeModel>> searchRecipes(String query);
}

class RemoteRecipeRepository implements RecipeRepository {
  final String baseUrl;
  RemoteRecipeRepository({required this.baseUrl});

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
        print('Error mapping individual recipe in repository: $e');
        // Continue to next recipe instead of failing the whole list
      }
    }
    return recipes;
  }

  @override
  Future<List<RecipeModel>> getTrendingRecipes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trending'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RecipeModel>> getRecommendedRecipes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recommended'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipe?id=$id'));
      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        if (item is Map<String, dynamic>) {
          final normalized = item.map((k, v) => MapEntry(k.toLowerCase(), v));
          return RecipeModel.fromJson(normalized);
        }
      }
      throw Exception('Recipe not found');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipesByIngredients(List<String> ingredients) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fridge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': ingredients}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRecipe(String token, RecipeModel recipe) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recipes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(recipe.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to save recipe: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRecipe(String token, RecipeModel recipe) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/recipes?id=${recipe.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(recipe.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update recipe: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteRecipe(String token, int recipeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/recipes?id=$recipeId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete recipe: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByAuthor(int authorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes?author_id=$authorId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapToRecipes(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
