import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';
import '../models/recipe_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  RecipeModel? _featuredRecipe;
  List<RecipeModel> _trendingRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final trending = await locator.recipeService.getTrendingRecipes();
      final recommended = await locator.recipeService.getRecommendedRecipes();
      
      setState(() {
        _trendingRecipes = trending;
        _featuredRecipe = recommended.isNotEmpty ? recommended.first : null;
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF53D22D))),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF152012)
          : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF53D22D),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildSearchBar(context),
                    _buildCategories(),
                    if (_featuredRecipe != null) _buildFeaturedRecipe(context, _featuredRecipe!),
                    _buildTrendingSection(context, _trendingRecipes),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi',
                style: TextStyle(
                  color: Color(0xFF53D22D),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Halo, mau masak apa hari ini?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF53D22D).withOpacity(0.1) : Colors.grey[200]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF53D22D)),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari resep, bahan, atau menu...',
                  border: InputBorder.none,
                ),
              ),
            ),
            Icon(Icons.tune, color: Color(0xFF53D22D)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildCategoryChip('Semua', Icons.grid_view, isSelected: true),
          _buildCategoryChip('Sarapan', Icons.breakfast_dining),
          _buildCategoryChip('Makan Siang', Icons.lunch_dining),
          _buildCategoryChip('Cepat', Icons.bolt),
          _buildCategoryChip('Vegan', Icons.eco),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF53D22D) : Colors.grey[200]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          if (!isSelected) Icon(icon, size: 18, color: Colors.grey[700]),
          if (!isSelected) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? const Color(0xFF152012) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRecipe(BuildContext context, RecipeModel recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resep Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF53D22D))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/recipe_detail', extra: recipe),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(
                    recipe.imageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=800&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF53D22D),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "EDITOR'S CHOICE",
                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.star, color: Colors.yellow, size: 12),
                                  SizedBox(width: 4),
                                  Text("4.9", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF53D22D), size: 14),
                            const SizedBox(width: 4),
                            Text("${recipe.prepTime ?? 0} Menit", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(width: 16),
                            const Icon(Icons.restaurant_menu, color: Color(0xFF53D22D), size: 14),
                            const SizedBox(width: 4),
                            Text(recipe.difficulty ?? "Mudah", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context, List<RecipeModel> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sedang Tren',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.trending_up, color: Color(0xFF53D22D)),
            ],
          ),
        ),
        if (recipes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Belum ada resep trending', style: TextStyle(color: Colors.grey)),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: recipes.map((recipe) => _buildTrendingCard(recipe)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () => context.push('/recipe_detail', extra: recipe),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.imageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=800&auto=format&fit=crop',
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    width: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              'Klik untuk detail',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Beranda', isSelected: true, onTap: () {}),
            _buildNavItem(Icons.search, 'Cari', onTap: () => context.push('/search')),
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
          Icon(
            icon,
            color: isSelected ? const Color(0xFF53D22D) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF53D22D) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

