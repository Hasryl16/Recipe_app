import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe_model.dart';
import '../service_locator.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel? recipe;

  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  RecipeModel? _detailedRecipe;
  bool _isLoading = false;
  bool _isBookmarked = false;
  bool _isTogglingBookmark = false;
  final Set<String> _selectedIngredients = {};

  @override
  void initState() {
    super.initState();
    _detailedRecipe = widget.recipe;
    _fetchDetailsIfNeeded();
    _checkBookmarkStatus();
  }

  Future<void> _fetchDetailsIfNeeded() async {
    final r = _detailedRecipe;
    if (r == null || r.id == null) return;

    if (r.ingredients == null || r.ingredients!.isEmpty || r.steps == null || r.steps!.isEmpty) {
      setState(() => _isLoading = true);

      try {
        final fullRecipe = await locator.recipeService.getRecipeById(r.id!);
        if (mounted) {
          setState(() {
            _detailedRecipe = fullRecipe;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkBookmarkStatus() async {
    final r = _detailedRecipe;
    if (r == null || r.id == null) return;

    final auth = locator.authService;
    if (auth.token == null) return;

    try {
      // We can fetch saved recipes and check if this one is in the list
      final savedRecipes = await locator.recipeService.getSavedRecipes(auth.token!);
      if (mounted) {
        setState(() {
          _isBookmarked = savedRecipes.any((sr) => sr.id == r.id);
        });
      }
    } catch (e) {
      // Silent error
    }
  }

  Future<void> _toggleBookmark() async {
    final r = _detailedRecipe;
    if (r == null || r.id == null) return;

    final auth = locator.authService;
    if (auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save recipes')),
      );
      return;
    }

    setState(() => _isTogglingBookmark = true);

    try {
      final success = await locator.recipeService.toggleBookmark(auth.token!, r.id!);
      if (mounted) {
        if (success) {
          setState(() {
            _isBookmarked = !_isBookmarked;
            _isTogglingBookmark = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isBookmarked ? 'Recipe saved to profile' : 'Recipe removed from profile'),
              backgroundColor: const Color(0xFF53D22D),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          setState(() => _isTogglingBookmark = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isTogglingBookmark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _detailedRecipe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context, isDark, recipe),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(recipe),
                      const SizedBox(height: 24),
                      _buildQuickStats(isDark, recipe),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Color(0xFF53D22D)),
                          ),
                        )
                      else ...[
                        _buildIngredients(recipe),
                        const SizedBox(height: 32),
                        _buildCookingSteps(isDark, recipe),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingActionButton(recipe),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, RecipeModel? recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      centerTitle: true,
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      elevation: 0,
      title: Text(
        'Recipe Details',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.05),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.05),
            child: IconButton(
              icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Container(
            width: 220,
            height: 220,
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF53D22D).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
            child: ClipOval(
              child: recipe?.imageUrl != null
                  ? Image.network(
                      recipe!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RecipeModel? recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                recipe?.title ?? 'Loading...',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ),
            _isTogglingBookmark 
              ? const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF53D22D))),
                )
              : IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                    color: const Color(0xFF53D22D),
                    size: 32,
                  ),
                  onPressed: _toggleBookmark,
                ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          recipe?.description ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark, RecipeModel? recipe) {
    return Row(
      children: [
        _buildStatCard('Time', '${recipe?.prepTime ?? '--'} mins', Icons.schedule, isDark),
        const SizedBox(width: 12),
        _buildStatCard('Level', recipe?.difficulty ?? '--', Icons.bar_chart, isDark),
        const SizedBox(width: 12),
        _buildStatCard('Calories', '${recipe?.kcal ?? '--'} kcal', Icons.local_fire_department, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF53D22D).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF53D22D), size: 20),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredients(RecipeModel? recipe) {
    final ingredients = recipe?.ingredients ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${ingredients.length} items', style: const TextStyle(fontSize: 14, color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        if (ingredients.isEmpty && !_isLoading)
          const Text('No ingredients listed.', style: TextStyle(color: Colors.grey))
        else
          ...ingredients.map((i) => _buildIngredientItem(
                i.name,
                i.amount,
                isChecked: _selectedIngredients.contains(i.name),
                onTap: () {
                  setState(() {
                    if (_selectedIngredients.contains(i.name)) {
                      _selectedIngredients.remove(i.name);
                    } else {
                      _selectedIngredients.add(i.name);
                    }
                  });
                },
              )),
      ],
    );
  }

  Widget _buildIngredientItem(String name, String amount, {bool isChecked = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: isChecked ? Border.all(color: const Color(0xFF53D22D).withOpacity(0.3), width: 1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF53D22D), width: 2),
                color: isChecked ? const Color(0xFF53D22D) : Colors.transparent,
              ),
              child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey : (isChecked ? Colors.grey : Colors.white70),
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: isChecked ? Colors.grey.withOpacity(0.5) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingSteps(bool isDark, RecipeModel? recipe) {
    final steps = recipe?.steps ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cooking Steps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        if (steps.isEmpty && !_isLoading)
          const Text('No cooking steps listed.', style: TextStyle(color: Colors.grey))
        else
          ...steps.asMap().entries.map((entry) => _buildStepItem(
                entry.key + 1,
                'Step ${entry.key + 1}',
                entry.value,
                isLast: entry.key == steps.length - 1,
                isDark: isDark,
              )),
      ],
    );
  }

  Widget _buildStepItem(int step, String title, String description, {bool isCompleted = false, bool isLast = false, bool isDark = true}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF53D22D) : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  shape: BoxShape.circle,
                  boxShadow: isCompleted ? [BoxShadow(color: const Color(0xFF53D22D).withOpacity(0.3), blurRadius: 10)] : null,
                ),
                child: Center(
                  child: Text(
                    step.toString(),
                    style: TextStyle(
                      color: isCompleted ? Colors.black : (isDark ? Colors.white : Colors.black),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF53D22D).withOpacity(isCompleted ? 0.5 : 0.2),
                          const Color(0xFF53D22D).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(RecipeModel? recipe) {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: () {
          if (recipe != null) {
            context.push('/cooking_mode', extra: recipe);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF53D22D),
          foregroundColor: const Color(0xFF152012),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 12,
          shadowColor: const Color(0xFF53D22D).withOpacity(0.4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 12),
            Text('Start Cooking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
