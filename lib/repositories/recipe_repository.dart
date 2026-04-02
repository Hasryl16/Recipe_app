import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

abstract class RecipeRepository {
  Future<List<RecipeModel>> getTrendingRecipes();
  Future<List<RecipeModel>> getRecommendedRecipes();
  Future<RecipeModel> getRecipeById(int id);
  Future<List<RecipeModel>> searchRecipesByIngredients(List<String> ingredients);
  Future<void> saveRecipe(RecipeModel recipe);
  Future<List<RecipeModel>> getRecipesByAuthor(int authorId);
  Future<List<RecipeModel>> searchRecipes(String query);
}

class RemoteRecipeRepository implements RecipeRepository {
  final String baseUrl;
  RemoteRecipeRepository({required this.baseUrl});

  @override
  Future<List<RecipeModel>> getTrendingRecipes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trending'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RecipeModel.fromJson(item)).toList();
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
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RecipeModel.fromJson(item)).toList();
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
        final data = jsonDecode(response.body);
        return RecipeModel.fromJson(data);
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
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RecipeModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recipes'),
        headers: {'Content-Type': 'application/json'},
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
  Future<List<RecipeModel>> getRecipesByAuthor(int authorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes?author_id=$authorId'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RecipeModel.fromJson(item)).toList();
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
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => RecipeModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
