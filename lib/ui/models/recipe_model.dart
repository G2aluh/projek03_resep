import 'package:flutter/material.dart';
import 'package:resep/ui/assets.dart' as app_asset;

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
}

class RecipeModel {
  final UniqueKey id;
  final String title;
  final String image;
  final List<String> ingredients;
  final List<String> steps;
  final RecipeCategory category;

  RecipeModel({
    UniqueKey? id,
    required this.title,
    required this.image,
    this.ingredients = const [],
    this.steps = const [],
    this.category = RecipeCategory.appetizer,
  }) : id = id ?? UniqueKey();

  static List<RecipeModel> recipes = [
    RecipeModel(
      title: "Sate Ayam",
      image: app_asset.sate,
      ingredients: ["1. ayam", "2. kacang", "3. kecap"],
      steps: ["- bakar", "- tusuk", "- makan", "- minum"],
      category: RecipeCategory.appetizer,
    ),
    RecipeModel(
      title: "Sate Kambing",
      image: app_asset.sate,
      ingredients: ["1. kambing", "2. kacang", "3. kecap"],
      steps: ["- bakar", "- tusuk", "- makan"],
      category: RecipeCategory.dessert,
    ),
    RecipeModel(
      title: "Sate Sapi",
      image: app_asset.sate,
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
