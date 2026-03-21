import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF152012) : const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Recipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Drafts', style: TextStyle(color: Color(0xFF53D22D), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: const Color(0xFF53D22D).withOpacity(0.1)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeader(),
                const SizedBox(height: 24),
                _buildUploadArea(isDark),
                const SizedBox(height: 32),
                _buildRecipeTitleField(isDark),
                const SizedBox(height: 32),
                _buildCategorySelection(),
                const SizedBox(height: 32),
                _buildDescriptionField(isDark),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step 1: Basic Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('1 of 4', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: const Color(0xFF53D22D).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF53D22D)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF53D22D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF53D22D).withOpacity(0.2),
          style: BorderStyle.solid, // Flutter doesn't have dashed borders built-in easily, using solid with low opacity
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
          const SizedBox(height: 8),
          const Text(
            'High-quality photos make your recipes more appealing to other foodies',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
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
          decoration: InputDecoration(
            hintText: 'e.g. Grandma\'s Famous Lasagna',
            filled: true,
            fillColor: isDark ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('Main Course', isSelected: true),
            _buildCategoryChip('Breakfast'),
            _buildCategoryChip('Dessert'),
            _buildCategoryChip('Appetizer'),
            _buildCategoryChip('+ More'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF53D22D).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? const Color(0xFF53D22D) : Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF53D22D) : Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Optional', style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Share the story behind this dish or any special tips...',
            filled: true,
            fillColor: isDark ? const Color(0xFF53D22D).withOpacity(0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF152012).withOpacity(0.8) : Colors.white.withOpacity(0.9),
          border: Border(top: BorderSide(color: const Color(0xFF53D22D).withOpacity(0.1))),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF53D22D),
            foregroundColor: const Color(0xFF152012),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            shadowColor: const Color(0xFF53D22D).withOpacity(0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Continue to Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

