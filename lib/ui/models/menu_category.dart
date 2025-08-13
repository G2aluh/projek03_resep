import 'package:resep/ui/models/recipe_model.dart';

class MenuCategoryModel {
  final RecipeCategory title;
  final String image;

  MenuCategoryModel({
    required this.title,
    required this.image,
  });

  static List<MenuCategoryModel> category = [
    MenuCategoryModel(title: RecipeCategory.appetizer, image: 'assets/sate.png'),
    MenuCategoryModel(title: RecipeCategory.mainCourse, image: 'assets/sate.png'),
    MenuCategoryModel(title: RecipeCategory.dessert, image: 'assets/sate.png'),
    MenuCategoryModel(title: RecipeCategory.cake, image: 'assets/sate.png'),
  ];
}
