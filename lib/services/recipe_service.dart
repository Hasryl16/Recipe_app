import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeService {
  final RecipeRepository _repository;

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
    // Business logic: validate recipe before saving
    if (recipe.title.isEmpty) throw Exception('Title is required');
    await _repository.saveRecipe(recipe);
  }
}
