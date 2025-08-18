import 'package:flutter/material.dart';
import 'package:resep/ui/models/recipe_model.dart';

class DetailRecipePage extends StatelessWidget {
  const DetailRecipePage({Key? key, required this.recipe}) : super(key: key);

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                _buildRecipeImage(recipe.image),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: "Bahan-bahan"),
                  Tab(text: "Langkah-langkah"),
                ],
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(child: buildBahanSection()),
                  SingleChildScrollView(child: buildLangkahSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget helper untuk load gambar dari URL atau asset
  Widget _buildRecipeImage(String path) {
    final isNetworkImage = path.startsWith('http');
    return isNetworkImage
        ? Image.network(
            path,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/default_food.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            path,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          );
  }

  Widget buildBahanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bahan-bahan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              ...recipe.ingredients.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(item, style: const TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLangkahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Langkah-langkah",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              ...recipe.steps.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(item, style: const TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
