class RecipeModel {
  final int? id;
  final int authorId;
  final String title;
  final String? description;
  final String? category;
  final int? prepTime;
  final String? difficulty;
  final int? kcal;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<IngredientAmount>? ingredients;
  final List<String>? steps;

  RecipeModel({
    this.id,
    required this.authorId,
    required this.title,
    this.description,
    this.category,
    this.prepTime,
    this.difficulty,
    this.kcal,
    this.imageUrl,
    this.createdAt,
    this.ingredients,
    this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return RecipeModel(
      id: _toInt(json['id']),
      authorId: _toInt(json['author_id']) ?? 0,
      title: json['title'] ?? 'Untitled',
      description: json['description'],
      category: json['category'],
      prepTime: _toInt(json['prep_time']),
      difficulty: json['difficulty'],
      kcal: _toInt(json['kcal']),
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      ingredients: (json['ingredients'] as List?)
          ?.map((i) => IngredientAmount.fromJson(i))
          .toList(),
      steps: (json['steps'] as List?)?.map((s) => s.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'description': description,
      'category': category,
      'prep_time': prepTime,
      'difficulty': difficulty,
      'kcal': kcal,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'ingredients': ingredients?.map((i) => i.toJson()).toList(),
      'steps': steps,
    };
  }
}

class IngredientAmount {
  final String name;
  final String amount;

  IngredientAmount({required this.name, required this.amount});

  factory IngredientAmount.fromJson(Map<String, dynamic> json) {
    return IngredientAmount(
      name: json['name'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}
