import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserModel? _user;
  List<RecipeModel> _myRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // Mocking UID for now
      final user = await locator.authService.getCurrentUser('mock-uid-123');
      final recipes = await locator.recipeService.getTrendingRecipes(); // Using trending as mock for user recipes
      
      setState(() {
        _user = user;
        _myRecipes = recipes;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF152012).withOpacity(0.8) : const Color(0xFFF6F8F6).withOpacity(0.8),
        elevation: 0,
        leading: const Icon(Icons.settings, color: Color(0xFF53D22D)),
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF53D22D).withOpacity(0.1),
              child: const Icon(Icons.share, color: Color(0xFF53D22D), size: 20),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildProfileHeader(isDark, _user),
                _buildStats(),
                _buildTabs(),
                _buildRecipeGrid(_myRecipes),
              ],
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.2), width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    user?.profilePicture ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF53D22D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF152012), width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Color(0xFF152012)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'Budi Santoso',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            user?.bio ?? 'Pecinta masakan nusantara & healthy food blogger. Mari berbagi resep sehat!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF53D22D),
              foregroundColor: const Color(0xFF152012),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            child: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('24', 'Resep'),
          _buildStatItem('156', 'Koleksi'),
          _buildStatItem('1.2k', 'Pengikut'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF53D22D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1))),
      ),
      child: Row(
        children: [
          _buildTabItem('Resep Saya', isActive: true),
          _buildTabItem('Tersimpan'),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, {bool isActive = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF53D22D) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF53D22D) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(List<RecipeModel> recipes) {
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('Belum ada resep', style: TextStyle(color: Colors.grey))),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () => context.push('/recipe_detail', extra: recipe),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(recipe.imageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=800&auto=format&fit=crop'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, size: 12, color: Color(0xFF53D22D)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${recipe.prepTime ?? 0} Menit • ${recipe.difficulty ?? 'Mudah'}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
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
            _buildNavItem(Icons.person, 'Profil', isSelected: true, onTap: () {}),
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
