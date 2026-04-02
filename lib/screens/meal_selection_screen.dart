import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';
import '../service_locator.dart';

class MealSelectionScreen extends StatefulWidget {
  final DateTime selectedDate;

  const MealSelectionScreen({super.key, required this.selectedDate});

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RecipeModel> _recipes = [];
  bool _isLoading = true;
  MealType _selectedType = MealType.Breakfast;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final recipes = query.isEmpty 
          ? await locator.recipeService.getRecommendedRecipes()
          : await locator.recipeService.searchRecipes(query);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRecipeSelected(RecipeModel recipe) async {
    if (recipe.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid recipe ID. Cannot schedule.')),
      );
      return;
    }

    try {
      // Mock userId as 1
      await locator.mealPlanService.scheduleMeal(
        1, 
        recipe.id!, 
        widget.selectedDate, 
        _selectedType
      );
      if (mounted) {
        context.pop(true); // Return true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception:', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildMealTypeFilters(),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF53D22D)))
                    : _buildRecipeGrid(),
                ),
              ],
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
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const Expanded(
            child: Text(
              'Pilih Menu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            DateFormat('d MMM').format(widget.selectedDate),
            style: const TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => _loadRecipes(val),
          decoration: const InputDecoration(
            hintText: 'Cari menu sarapan, makan siang...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Color(0xFF53D22D)),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeFilters() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildFilterChip('Pagi', MealType.Breakfast),
          _buildFilterChip('Siang', MealType.Lunch),
          _buildFilterChip('Malam', MealType.Dinner),
          _buildFilterChip('Cemilan', MealType.Snack),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MealType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53D22D) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF53D22D) : const Color(0xFF53D22D).withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeGrid() {
    if (_recipes.isEmpty) {
      return const Center(child: Text('No recipes found', style: TextStyle(color: Colors.grey)));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    recipe.imageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=300&auto=format&fit=crop',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.category ?? 'Healthy',
                  style: const TextStyle(color: Color(0xFF53D22D), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${recipe.kcal ?? 200} kkal', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    GestureDetector(
                      onTap: () => _onRecipeSelected(recipe),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF53D22D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Color(0xFF152012)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          color: isDark ? const Color(0xFF152012).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, 'Beranda', onTap: () => context.pushReplacement('/home')),
            _buildNavItem(Icons.search_rounded, 'Cari', onTap: () => context.pushReplacement('/search')),
            Transform.translate(
              offset: const Offset(0, -10),
              child: FloatingActionButton(
                onPressed: () => context.push('/add_recipe'),
                backgroundColor: const Color(0xFF53D22D),
                elevation: 4,
                mini: false,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Color(0xFF152012), size: 30),
              ),
            ),
            _buildNavItem(Icons.calendar_month_rounded, 'Rencana', isSelected: true, onTap: () => context.pushReplacement('/meal_plan')),
            _buildNavItem(Icons.person_rounded, 'Profil', onTap: () => context.pushReplacement('/profile')),
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
