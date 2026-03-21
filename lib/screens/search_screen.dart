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
  final Set<String> _selectedIngredients = {'Egg', 'Tomato', 'Avocado'};
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<void> _searchByIngredients() async {
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });
    try {
      final results = await locator.recipeService.getFridgeRecipes(_selectedIngredients.toList());
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

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
    _searchByIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF152012)
          : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSearchBar(context),
                  _buildCategoriesSection(),
                  _buildFridgeSection(context),
                  _buildRecommendedSection(context),
                ],
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
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
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search recipes, cuisines...',
          filled: true,
          fillColor: isDark ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.grey[200]!.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
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

  Widget _buildFridgeSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF53D22D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.kitchen, color: Color(0xFF53D22D)),
                    SizedBox(width: 8),
                    Text('What\'s in my Fridge?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Logic to add new ingredient (could show a dialog)
                  },
                  child: const Text('Add Item +', style: TextStyle(color: Color(0xFF53D22D), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedIngredients.map((item) => _buildIngredientChip(item, isDark)),
                if (_selectedIngredients.isEmpty)
                  const Text('Select ingredients to search', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientChip(String label, bool isDark) {
    return GestureDetector(
      onTap: () => _toggleIngredient(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 14, color: Colors.grey),
          ],
        ),
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
              child: Text('No recipes found with these ingredients', style: TextStyle(color: Colors.grey)),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
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
                '${recipe.prepTime ?? 0} min • ${recipe.difficulty ?? 'Easy'}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 20,
      left: 24,
      right: 24,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Beranda', onTap: () => context.push('/home')),
            _buildNavItem(Icons.search, 'Cari', isSelected: true, onTap: () {}),
            Transform.translate(
              offset: const Offset(0, -10),
              child: FloatingActionButton(
                onPressed: () => context.push('/add_recipe'),
                backgroundColor: const Color(0xFF53D22D),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Color(0xFF152012), size: 32),
              ),
            ),
            _buildNavItem(Icons.calendar_today, 'Rencana', onTap: () => context.push('/meal_plan')),
            _buildNavItem(Icons.person, 'Profil', onTap: () => context.push('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF53D22D) : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF53D22D) : Colors.grey)),
        ],
      ),
    );
  }
}

