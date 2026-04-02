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
  List<RecipeModel> _savedRecipes = [];
  int _recipeCount = 0;
  int _bookmarkCount = 0;
  int _selectedTab = 0; // 0 for My Recipes, 1 for Saved

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final auth = locator.authService;
      final recipeService = locator.recipeService;
      
      _user = auth.currentUser;
      
      if (_user != null) {
        // Fetch stats
        final stats = await auth.getUserStats();
        
        // Fetch My Recipes
        final myRecipes = await recipeService.getRecipesByAuthor(_user!.id ?? 0);
        
        // Fetch Saved Recipes
        final savedRecipes = await recipeService.getSavedRecipes(auth.token ?? '');
        
        if (mounted) {
          setState(() {
            _recipeCount = stats['recipe_count'] ?? 0;
            _bookmarkCount = stats['bookmark_count'] ?? 0;
            _myRecipes = myRecipes;
            _savedRecipes = savedRecipes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileBottomSheet(
        initialUser: _user!,
        onUpdate: () => _loadProfileData(),
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 100), // Added 100px bottom padding
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 20),
              child: Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Account Preferences',
              subtitle: 'Edit your profile details',
              onTap: () {
                context.pop();
                _showEditProfileSheet();
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Manage alerts',
              onTap: () => context.pop(),
            ),
            const Divider(height: 32),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: Colors.redAccent,
              onTap: () {
                locator.authService.logout();
                context.pop();
                context.go('/login');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap, 
    Color? color
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF53D22D)).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? const Color(0xFF53D22D), size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF53D22D)));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF53D22D)),
          onPressed: _showSettingsMenu,
        ),
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF53D22D))),
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
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        color: const Color(0xFF53D22D),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              _buildProfileHeader(isDark, _user),
              _buildStats(),
              _buildTabs(),
              _buildRecipeGrid(_selectedTab == 0 ? _myRecipes : _savedRecipes, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, UserModel? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                      color: Colors.grey[900],
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _showEditProfileSheet,
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.username ?? 'Chef Participant',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              user?.bio ?? 'Passionate chef sharing the best homemade recipes.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
          ),
          const SizedBox(height: 16), // Reduced height since button is removed
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatItem(_recipeCount.toString(), 'RESEP'),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 40)),
          _buildStatItem(_bookmarkCount.toString(), 'SAVED'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF53D22D))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        children: [
          _buildTabItem('My Recipes', index: 0),
          _buildTabItem('Saved', index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, {required int index}) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          // Optional: Force reload when switching to saved tab
          if (index == 1) _loadProfileData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              color: isActive ? const Color(0xFF53D22D) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(List<RecipeModel> recipes, bool isDark) {
    if (recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              _selectedTab == 0 ? 'No recipes created yet' : 'No saved recipes found',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 12),
            Text(
              _selectedTab == 0 ? 'Start sharing your culinary creations with the world!' : 'Recipes you bookmark will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13)
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return GestureDetector(
          onTap: () => context.push('/recipe_detail', extra: recipe),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: DecorationImage(
                        image: NetworkImage(recipe.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 10, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.prepTime ?? 0} Mins',
                            style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            recipe.difficulty ?? 'Med',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF53D22D), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final UserModel initialUser;
  final VoidCallback onUpdate;

  const _EditProfileBottomSheet({
    required this.initialUser,
    required this.onUpdate,
  });

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.username);
    _bioController = TextEditingController(text: widget.initialUser.bio ?? '');
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    
    setState(() => _isSaving = true);
    final results = await locator.authService.updateProfile(
      _nameController.text.trim(),
      _bioController.text.trim(),
    );
    
    if (mounted) {
      if (results['success']) {
        widget.onUpdate();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'), 
            backgroundColor: Color(0xFF53D22D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(results['message'] ?? 'Failed to update profile')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              IconButton(
                icon: const Icon(Icons.close_rounded), 
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('USERNAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: _inputDecoration('Chef Name'),
          ),
          const SizedBox(height: 24),
          const Text('ABOUT ME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: _inputDecoration('A little about your culinary journey...'),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53D22D),
                foregroundColor: const Color(0xFF152012),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _isSaving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF152012)))
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}
