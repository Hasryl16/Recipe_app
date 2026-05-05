import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';
import '../models/recipe_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performTextSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      _loadInitialData();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final results = await locator.recipeService.searchRecipes(query);
      setState(() {
        _recipes = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final recommended = await locator.recipeService.getRecommendedRecipes();
      setState(() {
        _recipes = recommended;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(context),
            _buildCategoriesSection(),
            _buildRecommendedSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Explore Recipes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF53D22D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xFF53D22D)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _performTextSearch,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _performTextSearch('');
                },
              )
            : null,
          hintText: 'Search recipes, cuisines...',
          filled: true,
          fillColor: isDark ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.grey[200]!.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'CATEGORIES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildCategoryItem(Icons.wb_sunny, 'Breakfast'),
              _buildCategoryItem(Icons.restaurant, 'Lunch'),
              _buildCategoryItem(Icons.dark_mode, 'Dinner'),
              _buildCategoryItem(Icons.icecream, 'Dessert'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF53D22D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF53D22D), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSearching ? 'Search Results' : 'Recommended for you',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (!_isSearching)
                TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: Color(0xFF53D22D)))),
            ],
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF53D22D))),
            )
          else if (_recipes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No recipes found', style: TextStyle(color: Colors.grey)),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
              children: _recipes.map((recipe) => _buildRecipeCard(recipe)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () => context.push('/recipe_detail', extra: recipe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  recipe.imageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=800&auto=format&fit=crop',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${recipe.prepTime ?? 0} min \u2022 ${recipe.difficulty ?? 'Easy'}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
