import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe_model.dart';
import '../service_locator.dart';
import '../services/recipe_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  bool _isSubmitting = false;

  // Controllers for Step 1
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Main Course';

  // State for Step 2 (Ingredients)
  final List<IngredientAmount> _ingredients = [
    IngredientAmount(name: '', amount: '')
  ];

  // State for Step 3 (Instructions)
  final List<String> _instructions = [''];

  // State for Step 4 (Settings)
  String _difficulty = 'Medium';
  String _cookingTime = '30';
  String _servings = '2';

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      if (_validateStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _submitRecipe();
    }
  }

  bool _validateStep() {
    if (_currentStep == 1) {
      if (_titleController.text.isEmpty) {
        _showError('Please enter a recipe title');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitRecipe() async {
    setState(() => _isSubmitting = true);

    try {
      // Filter out empty ingredients/steps
      final finalIngredients = _ingredients.where((i) => i.name.isNotEmpty).toList();
      final finalSteps = _instructions.where((s) => s.isNotEmpty).toList();

      final recipe = RecipeModel(
        authorId: 1, // Fallback for now
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        prepTime: int.tryParse(_cookingTime) ?? 30,
        difficulty: _difficulty,
        ingredients: finalIngredients,
        steps: finalSteps,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800', // Default placeholder
      );

      await locator.recipeService.createNewRecipe(recipe);

      if (!mounted) return;
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF152012),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Color(0xFF53D22D), width: 1)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF53D22D), size: 60),
              SizedBox(height: 16),
              Text('Recipe Posted!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ],
          ),
          content: const Text('Your culinary creation is now live for others to enjoy.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Go back to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53D22D),
                foregroundColor: const Color(0xFF152012),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Failed to post recipe: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6);
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(_currentStep == 1 ? Icons.close : Icons.arrow_back, 
                    color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                if (_currentStep == 1) {
                  context.pop();
                } else {
                  _prevStep();
                }
              },
            ),
            title: const Text('Create Recipe', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Drafts', style: TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressHeader(),
                    const SizedBox(height: 32),
                    if (_currentStep == 1) _buildStep1(isDark),
                    if (_currentStep == 2) _buildStep2(isDark),
                    if (_currentStep == 3) _buildStep3(isDark),
                    if (_currentStep == 4) _buildStep4(isDark),
                  ],
                ),
              ),
              _buildBottomButton(context),
            ],
          ),
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF53D22D)),
                  SizedBox(height: 24),
                  Text('Posting your recipe...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    String stepTitle = '';
    switch (_currentStep) {
      case 1: stepTitle = 'Basic Info'; break;
      case 2: stepTitle = 'Ingredients'; break;
      case 3: stepTitle = 'Instructions'; break;
      case 4: stepTitle = 'Cooking Settings'; break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $_currentStep: $stepTitle', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('$_currentStep of $_totalSteps', 
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _currentStep / _totalSteps,
            backgroundColor: const Color(0xFF53D22D).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF53D22D)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadArea(isDark),
        const SizedBox(height: 32),
        _buildRecipeTitleField(isDark),
        const SizedBox(height: 32),
        _buildCategorySelection(),
        const SizedBox(height: 32),
        _buildDescriptionField(isDark),
      ],
    );
  }

  Widget _buildUploadArea(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF53D22D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF53D22D).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF53D22D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_a_photo, size: 36, color: Color(0xFF53D22D)),
          ),
          const SizedBox(height: 16),
          const Text('Upload Cover Photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF53D22D),
              foregroundColor: const Color(0xFF152012),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Select Image', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTitleField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recipe Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _titleController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(isDark, 'e.g. Grandma\'s Famous Lasagna'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
      filled: true,
      fillColor: isDark ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF53D22D)),
      ),
    );
  }

  Widget _buildCategorySelection() {
    final categories = ['Main Course', 'Breakfast', 'Dessert', 'Appetizer', 'Snack'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((cat) => _buildCategoryChip(cat)).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53D22D) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF53D22D) : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF152012) : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(isDark, 'Share the story behind this dish...'),
        ),
      ],
    );
  }

  // --- Step 2: Ingredients ---
  Widget _buildStep2(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What do we need?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Add all the ingredients required for this recipe', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        ...List.generate(_ingredients.length, (index) => _buildIngredientInput(index, isDark)),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _ingredients.add(IngredientAmount(name: '', amount: ''))),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF53D22D)),
            label: const Text('Add Ingredient', style: TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientInput(int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) {
                _ingredients[index] = IngredientAmount(name: val, amount: _ingredients[index].amount);
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _inputDecoration(isDark, 'Ingredient Name'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (val) {
                _ingredients[index] = IngredientAmount(name: _ingredients[index].name, amount: val);
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _inputDecoration(isDark, 'Amt'),
            ),
          ),
          if (_ingredients.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => setState(() => _ingredients.removeAt(index)),
            ),
        ],
      ),
    );
  }

  // --- Step 3: Instructions ---
  Widget _buildStep3(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How to cook it?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Describe each step clearly for others to follow', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        ...List.generate(_instructions.length, (index) => _buildInstructionInput(index, isDark)),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _instructions.add('')),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF53D22D)),
            label: const Text('Add New Step', style: TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionInput(int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF53D22D),
            radius: 14,
            child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF152012), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              maxLines: 3,
              onChanged: (val) => _instructions[index] = val,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _inputDecoration(isDark, 'Step detail...'),
            ),
          ),
          if (_instructions.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => setState(() => _instructions.removeAt(index)),
            ),
        ],
      ),
    );
  }

  // --- Step 4: Settings ---
  Widget _buildStep4(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fine Tuning', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Almost done! Just a few more details', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        _buildSettingField('Time (Minutes)', _cookingTime, (val) => setState(() => _cookingTime = val), isDark, Icons.timer_outlined),
        const SizedBox(height: 24),
        _buildSettingField('Servings', _servings, (val) => setState(() => _servings = val), isDark, Icons.people_outline),
        const SizedBox(height: 32),
        const Text('Difficulty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Easy', 'Medium', 'Hard'].map((d) => _buildDifficultyChip(d)).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingField(String label, String value, Function(String) s, bool isDark, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          onChanged: s,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _inputDecoration(isDark, 'Enter number').copyWith(
            prefixIcon: Icon(icon, color: const Color(0xFF53D22D)),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(String label) {
    bool isSelected = _difficulty == label;
    return GestureDetector(
      onTap: () => setState(() => _difficulty = label),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF53D22D) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF53D22D) : Colors.grey.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF152012) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String buttonText = '';
    switch (_currentStep) {
      case 1: buttonText = 'Continue to Ingredients'; break;
      case 2: buttonText = 'Continue to Instructions'; break;
      case 3: buttonText = 'Continue to Settings'; break;
      case 4: buttonText = 'POST RECIPE'; break;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF152012).withOpacity(0) : Colors.white.withOpacity(0),
              isDark ? const Color(0xFF152012) : Colors.white,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF53D22D),
            foregroundColor: const Color(0xFF152012),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            shadowColor: const Color(0xFF53D22D).withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (_currentStep < 4) const Icon(Icons.arrow_forward) else const Icon(Icons.check_circle),
            ],
          ),
        ),
      ),
    );
  }
}

