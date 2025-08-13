import 'package:flutter/material.dart';
import 'package:resep/ui/models/menu_category.dart';
import 'package:resep/ui/models/recipe_model.dart';

class MenuCategoryButton extends StatelessWidget {
  final MenuCategoryModel category;
  final RecipeCategory? selectedCategory;
  final ValueChanged<RecipeCategory> onCategorySelected;

  const MenuCategoryButton({
    Key? key,
    required this.category,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = category.title == selectedCategory;

    return ElevatedButton(
      onPressed: () => onCategorySelected(category.title),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.lightGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              category.image,
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category.title.label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            semanticsLabel: category.title.label,
          ),
        ],
      ),
    );
  }
}
