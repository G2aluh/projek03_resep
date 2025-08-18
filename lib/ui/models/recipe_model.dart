
enum RecipeCategory {
  all,
  appetizer,
  mainCourse,
  dessert,
  cake;

  String get label {
    switch (this) {
      case RecipeCategory.all:
        return 'All';
      case RecipeCategory.appetizer:
        return 'Appetizer';
      case RecipeCategory.mainCourse:
        return 'Main Course';
      case RecipeCategory.dessert:
        return 'Dessert';
      case RecipeCategory.cake:
        return 'Cake';
    }
  }

  // Convert string kategori dari DB ke enum
  static RecipeCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'appetizer':
        return RecipeCategory.appetizer;
      case 'main course':
        return RecipeCategory.mainCourse;
      case 'dessert':
        return RecipeCategory.dessert;
      case 'cake':
        return RecipeCategory.cake;
      default:
        return RecipeCategory.all;
    }
  }
}

class RecipeModel {
  final dynamic id; // bisa int atau String dari database
  final String title;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final RecipeCategory category;

  RecipeModel({
    required this.id,
    required this.title,
    required this.image,
    this.ingredients = const [],
    this.steps = const [],
    this.category = RecipeCategory.appetizer,
  });

  // Factory buat convert dari Supabase
  factory RecipeModel.fromMap(Map<String, dynamic> data) {
    return RecipeModel(
      id: data['id'],
      title: data['nama'] ?? '',
      image: data['gambar_url'] ?? '',
      ingredients: (data['bahan'] ?? '')
          .toString()
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      steps: (data['langkah'] ?? '')
          .toString()
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      category: RecipeCategory.fromString(data['kategori'] ?? ''),
    );
  }

  // Data dummy
  static List<RecipeModel> recipes = [
    RecipeModel(
      id: 1,
      title: "Sate Ayam",
      image: "assets/images/sate.png",
      ingredients: ["1. ayam", "2. kacang", "3. kecap"],
      steps: ["- bakar", "- tusuk", "- makan", "- minum"],
      category: RecipeCategory.appetizer,
    ),
    RecipeModel(
      id: 2,
      title: "Sate Kambing",
      image: "assets/images/sate.png",
      ingredients: ["1. kambing", "2. kacang", "3. kecap"],
      steps: ["- bakar", "- tusuk", "- makan"],
      category: RecipeCategory.dessert,
    ),
    RecipeModel(
      id: 3,
      title: "Sate Sapi",
      image: "assets/images/sate.png",
      ingredients: ["1. sapi", "2. kacang", "3. kecap"],
      steps: ["- bakar", "- tusuk", "- makan"],
      category: RecipeCategory.cake,
    ),
  ];

  static List<RecipeModel> getByCategory(RecipeCategory category) {
    if (category == RecipeCategory.all) {
      return recipes;
    }
    return recipes.where((recipe) => recipe.category == category).toList();
  }
}

