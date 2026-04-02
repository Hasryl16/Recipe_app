import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe_model.dart';

class CookingModeScreen extends StatefulWidget {
  final RecipeModel recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  int _currentStep = 0;
  late List<String> _steps;
  final List<bool> _ingredientsChecked = [];

  @override
  void initState() {
    super.initState();
    _steps = widget.recipe.steps ?? [];
    // Initialize ingredient check state for current step (mocking 3 ingredients per step for interactivity)
    for (int i = 0; i < 3; i++) {
      _ingredientsChecked.add(false);
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        // Reset ingredient checks for next step
        for (int i = 0; i < _ingredientsChecked.length; i++) {
          _ingredientsChecked[i] = false;
        }
      });
    } else {
      context.pop(); // Finish cooking
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        // Reset ingredient checks for previous step
        for (int i = 0; i < _ingredientsChecked.length; i++) {
          _ingredientsChecked[i] = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No cooking steps available'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6);
    final primaryColor = const Color(0xFF53D22D);
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Cooking Mode',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.recipe.title.toUpperCase(),
              style: TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.remove_red_eye_outlined, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Progress Tracker Step & Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time_filled, color: primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${(_steps.length - _currentStep) * 2} min remaining', // Mock timer
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Segmented Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == _steps.length - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? primaryColor : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // Step Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    widget.recipe.imageUrl ?? 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white.withOpacity(0.05),
                      child: const Icon(Icons.restaurant, color: Colors.white24, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Instruction Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStepActionTitle(_currentStep),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _steps[_currentStep],
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Ingredients Needed Card
            _buildIngredientsCard(isDark, cardColor, primaryColor),
            const SizedBox(height: 16),
            // Pro Tip Box
            _buildTipBox(isDark, primaryColor),
            const SizedBox(height: 100), // Space for floating buttons
          ],
        ),
      ),
      bottomSheet: Container(
        color: backgroundColor,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _prevStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: const Text('Previous', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: const Color(0xFF152012),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == _steps.length - 1 ? 'FINISH' : 'Next Step',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.pop(),
              child: const Text(
                'FINISH COOKING',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsCard(bool isDark, Color cardColor, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INGREDIENTS NEEDED',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          // Mock ingredients for current step
          _buildIngredientItem('2 Salmon Fillets', 0, isDark),
          _buildIngredientItem('1 tbsp Olive Oil', 1, isDark),
          _buildIngredientItem('Salt & Pepper', 2, isDark),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String label, int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _ingredientsChecked[index] = !_ingredientsChecked[index];
              });
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _ingredientsChecked[index] ? const Color(0xFF53D22D) : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
                color: _ingredientsChecked[index] ? const Color(0xFF53D22D) : Colors.transparent,
              ),
              child: _ingredientsChecked[index]
                  ? const Icon(Icons.check, color: Color(0xFF152012), size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              decoration: _ingredientsChecked[index] ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox(bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pro Tip: Keep the pan at medium-high heat for that perfect crisp skin.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepActionTitle(int stepIndex) {
    // Special case for the last step
    if (stepIndex == _steps.length - 1) {
      return 'Sajikan dan Nikmati';
    }

    // Generate representative titles based on step content
    final stepText = _steps[stepIndex].toLowerCase();
    
    if (stepText.contains('glaze') || stepText.contains('finish') || stepText.contains('garnish')) {
      return 'Glaze and Finish';
    } else if (stepText.contains('sear') || stepText.contains('fry') || stepText.contains('grill')) {
      return 'High Heat Cooking';
    } else if (stepText.contains('heat') || stepText.contains('boil') || stepText.contains('cook') || stepText.contains('simmer')) {
      return 'Cook Ingredient';
    } else if (stepText.contains('mix') || stepText.contains('stir') || stepText.contains('combine') || stepText.contains('whisk')) {
      return 'Mix Everything';
    } else if (stepText.contains('cut') || stepText.contains('chop') || stepText.contains('slice') || stepText.contains('dice')) {
      return 'Prep Ingredients';
    } else if (stepText.contains('pour') || stepText.contains('add') || stepText.contains('spread')) {
      return 'Adding Flavors';
    } else if (stepText.contains('bake') || stepText.contains('roast') || stepText.contains('oven')) {
      return 'Baking Moment';
    }
    
    return 'Preparation';
  }
}
