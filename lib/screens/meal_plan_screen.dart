import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';
import '../models/meal_plan_model.dart';
import 'package:intl/intl.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = true;
  List<MealPlanModel> _mealPlans = [];

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    try {
      // Mocking userId for now, in real app it would come from AuthService
      final plans = await locator.mealPlanService.getWeeklyPlan(1);
      setState(() {
        _mealPlans = plans;
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
                  _buildCalendar(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Today\'s Meals', 'Scheduled via API'),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF53D22D)))
                        else if (_mealPlans.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No meals scheduled for today.\nAdd some to your plan!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ..._mealPlans.map((plan) => _buildMealCard(plan)),
                        const SizedBox(height: 32),
                        _buildShoppingList(context),
                      ],
                    ),
                  ),
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
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF53D22D), size: 32),
              SizedBox(width: 8),
              Text('Meal Planner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF53D22D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings, color: Color(0xFF53D22D)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildCalendarDay('Mon', '12', isSelected: true),
          _buildCalendarDay('Tue', '13'),
          _buildCalendarDay('Wed', '14'),
          _buildCalendarDay('Thu', '15'),
          _buildCalendarDay('Fri', '16', isToday: true),
          _buildCalendarDay('Sat', '17'),
          _buildCalendarDay('Sun', '18'),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(String day, String date, {bool isSelected = false, bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF53D22D) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isToday && !isSelected ? Border.all(color: const Color(0xFF53D22D).withOpacity(0.3), width: 2) : null,
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black.withOpacity(0.6) : Colors.grey)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : null)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF53D22D), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMealCard(MealPlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              plan.recipeImageUrl ?? 'https://images.unsplash.com/photo-1495195129352-aed325a55b65?q=80&w=150&auto=format&fit=crop',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.mealType.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF53D22D), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(plan.planDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.recipeTitle ?? 'Unknown Recipe', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Scheduled via API', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF53D22D)),
        ],
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF53D22D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_cart, color: Color(0xFF53D22D)),
                  SizedBox(width: 8),
                  Text('Shopping List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Full List', style: TextStyle(color: Color(0xFF53D22D), fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, color: Color(0xFF53D22D), size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildShoppingItem('Ripe Avocado (3)', 'Produce', true),
          _buildShoppingItem('Fresh Salmon Fillet (500g)', 'Meat/Fish', false),
          _buildShoppingItem('Organic Quinoa (1kg)', 'Pantry', false),
          _buildShoppingItem('Greek Yogurt (500ml)', 'Dairy', false),
          const Divider(height: 32),
          Row(
            children: [
              const Text('Estimated total: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('\$42.50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(String title, String category, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF53D22D), width: 2),
                ),
                child: isChecked ? const Icon(Icons.check, size: 14, color: Color(0xFF53D22D)) : null,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey : null,
                ),
              ),
            ],
          ),
          Text(category, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
            _buildNavItem(Icons.calendar_today, 'Rencana', isSelected: true, onTap: () {}),
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

