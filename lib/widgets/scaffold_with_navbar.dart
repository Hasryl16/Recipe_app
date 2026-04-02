import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  /// The widget to display in the body of the Scaffold.
  /// In this case, it will be the child from ShellRoute.
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          child,
          _buildBottomNav(context, location, isDark),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String location, bool isDark) {
    // Hide the navbar on certain routes if necessary
    final hideNavbar = location.startsWith('/recipe_detail') || 
                       location.startsWith('/cooking_mode') ||
                       location.startsWith('/meal_selection') ||
                       location.startsWith('/add_recipe');
                       
    if (hideNavbar) return const SizedBox.shrink();

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
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, Icons.home_filled, 'Beranda', '/home', location == '/home'),
            _buildNavItem(context, Icons.search_rounded, 'Cari', '/search', location == '/search'),
            Transform.translate(
              offset: const Offset(0, -10),
              child: FloatingActionButton(
                onPressed: () => context.push('/add_recipe'),
                backgroundColor: const Color(0xFF53D22D),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Color(0xFF152012), size: 30),
              ),
            ),
            _buildNavItem(context, Icons.calendar_month_rounded, 'Rencana', '/meal_plan', location == '/meal_plan'),
            _buildNavItem(context, Icons.person_rounded, 'Profil', '/profile', location == '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String route, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
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
