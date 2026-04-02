import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../service_locator.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';
import 'package:intl/intl.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = true;
  List<MealPlanModel> _mealPlans = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    setState(() => _isLoading = true);
    try {
      final plans = await locator.mealPlanService.getWeeklyPlan(1);
      setState(() {
        // Filter plans locally for the selected date
        _mealPlans = plans.where((plan) {
          return plan.planDate.year == _selectedDate.year &&
                 plan.planDate.month == _selectedDate.month &&
                 plan.planDate.day == _selectedDate.day;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadMealPlan();
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
            _buildCalendar(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    '${DateFormat('EEEE').format(_selectedDate)}\'s Plan', 
                    'Scheduled'
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF53D22D)))
                  else if (_mealPlans.isEmpty)
                    _buildEmptyState()
                  else
                    ..._mealPlans.map((plan) => _buildMealCard(plan)),
                  
                  const SizedBox(height: 32),
                  _buildPilihMenuButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF53D22D).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, color: const Color(0xFF53D22D).withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          const Text(
            'No meals planned for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Pick Menu" to get started!',
            style: TextStyle(color: Color(0xFF53D22D), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihMenuButton() {
    return GestureDetector(
      onTap: () async {
        final result = await context.push('/meal_selection', extra: _selectedDate);
        if (result == true) {
          _loadMealPlan();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF53D22D),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF53D22D).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xFF152012)),
              SizedBox(width: 8),
              Text(
                'Pilih Menu',
                style: TextStyle(
                  color: Color(0xFF152012),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rencana Makan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Plan your weekly meals',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF53D22D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFF53D22D)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    // Generate dates for current week
    final List<DateTime> weekDates = List.generate(7, (i) {
      return now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: i));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: weekDates.map((date) {
          final isSelected = date.year == _selectedDate.year &&
                             date.month == _selectedDate.month &&
                             date.day == _selectedDate.day;
          final isToday = date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;
          
          return _buildCalendarDay(
            DateFormat('E').format(date),
            date.day.toString(),
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => _onDateSelected(date),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDay(String day, String date, {
    bool isSelected = false, 
    bool isToday = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53D22D) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF53D22D) 
              : (isToday ? const Color(0xFF53D22D).withOpacity(0.3) : Colors.transparent),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black.withOpacity(0.6) : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : null,
              ),
            ),
          ],
        ),
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

  Future<void> _deleteMealPlan(int planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF152012),
        title: const Text('Hapus Rencana', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus menu ini dari rencana makan?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await locator.mealPlanService.cancelMeal(planId);
        _loadMealPlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
          );
        }
      }
    }
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
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
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
                Text(
                  plan.mealType.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF53D22D), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(plan.recipeTitle ?? 'Unknown Recipe', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(plan.planDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteMealPlan(plan.id!),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
          IconButton(
            onPressed: () async {
              // Show a small loading indicator or just fetch
              try {
                final fullRecipe = await locator.recipeService.getRecipeById(plan.recipeId);
                if (mounted) {
                  context.push('/recipe_detail', extra: fullRecipe);
                }
              } catch (e) {
                // If fetch fails, pass partial info
                if (mounted) {
                  context.push('/recipe_detail', extra: RecipeModel(
                    id: plan.recipeId,
                    authorId: 0, // Fallback author ID
                    title: plan.recipeTitle ?? 'Recipe',
                    imageUrl: plan.recipeImageUrl,
                  ));
                }
              }
            },
            icon: const Icon(Icons.chevron_right, color: Color(0xFF53D22D), size: 20),
          ),
        ],
      ),
    );
  }
}
