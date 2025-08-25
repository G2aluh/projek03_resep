import 'dart:convert'; // Untuk jsonDecode

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
    dynamic bahanRaw = data['bahan'] ?? [];
    dynamic langkahRaw = data['langkah'] ?? [];

    List<String> parsedIngredients = [];
    List<String> parsedSteps = [];

    // Handle ingredients
    if (bahanRaw is List) {
      // Jika sudah List dari Supabase array, cast ke List<String>
      parsedIngredients = bahanRaw.map((e) => e.toString()).toList();
    } else if (bahanRaw is String) {
      // Jika String, coba parse JSON atau split newline
      try {
        if (bahanRaw.startsWith('[') && bahanRaw.endsWith(']')) {
          parsedIngredients = List<String>.from(jsonDecode(bahanRaw));
        } else {
          parsedIngredients = bahanRaw
              .split('\n')
              .where((e) => e.trim().isNotEmpty)
              .toList();
        }
      } catch (e) {
        print('Gagal parse ingredients: $e');
        parsedIngredients = [];
      }
    } else {
      print('Tipe bahan tidak didukung: ${bahanRaw.runtimeType}');
    }

    // Serupa untuk steps
    if (langkahRaw is List) {
      parsedSteps = langkahRaw.map((e) => e.toString()).toList();
    } else if (langkahRaw is String) {
      try {
        if (langkahRaw.startsWith('[') && langkahRaw.endsWith(']')) {
          parsedSteps = List<String>.from(jsonDecode(langkahRaw));
        } else {
          parsedSteps = langkahRaw
              .split('\n')
              .where((e) => e.trim().isNotEmpty)
              .toList();
        }
      } catch (e) {
        print('Gagal parse steps: $e');
        parsedSteps = [];
      }
    } else {
      print('Tipe langkah tidak didukung: ${langkahRaw.runtimeType}');
    }

    return RecipeModel(
      id: data['id'],
      title: data['nama'] ?? '',
      image: data['gambar_url'] ?? '',
      ingredients: parsedIngredients,
      steps: parsedSteps,
      category: RecipeCategory.fromString(data['kategori'] ?? ''),
    );
  }

  // Data dummy
  static List<RecipeModel> recipes = [
    RecipeModel(
      id: 1,
      title: "Sate Ayam",
      image: "assets/images/sate.png",
      ingredients: ["ayam", "kacang", "kecap"], // Dihapus nomor manual untuk konsistensi
      steps: ["bakar", "tusuk", "makan", "minum"], // Dihapus tanda '-' untuk konsistensi
      category: RecipeCategory.appetizer,
    ),
    RecipeModel(
      id: 2,
      title: "Sate Kambing",
      image: "assets/images/sate.png",
      ingredients: ["kambing", "kacang", "kecap"],
      steps: ["bakar", "tusuk", "makan"],
      category: RecipeCategory.dessert,
    ),
    RecipeModel(
      id: 3,
      title: "Sate Sapi",
      image: "assets/images/sate.png",
      ingredients: ["sapi", "kacang", "kecap"],
      steps: ["bakar", "tusuk", "makan"],
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