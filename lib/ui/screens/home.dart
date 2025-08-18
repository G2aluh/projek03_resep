import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/ui/components/food_card.dart';
import 'package:resep/ui/components/menu_category_button.dart';
import 'package:resep/ui/models/menu_category.dart';
import 'package:resep/ui/models/recipe_model.dart';
import 'package:resep/ui/screens/bottom_sheet.dart';
import 'package:resep/ui/models/opsi_menu.dart';
import 'package:resep/ui/screens/setting.dart';
import 'package:resep/ui/screens/login.dart';
import 'package:resep/services/service_makanan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RecipeCategory? selectedCategory = RecipeCategory.all;
  String searchQuery = '';
  final ServiceMakanan _serviceMakanan = ServiceMakanan();

  List<RecipeModel> allRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    try {
      final recipes = await _serviceMakanan.fetchRecipes();
      setState(() {
        allRecipes = recipes;
      });
    } catch (e) {
      print("Error load recipes: $e");
    } finally {
      setState(() => isLoading = false);
    }               
  }

  @override
  Widget build(BuildContext context) {
    final List<RecipeModel> displayedRecipes = selectedCategory == RecipeCategory.all
        ? allRecipes
        : allRecipes.where((recipe) => recipe.category == selectedCategory!.name).toList();

    final List<RecipeModel> filteredRecipes = displayedRecipes.where((recipe) {
      return recipe.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFACDDB5), Color(0xFFF6F6F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            // Header + tombol tambah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 5),
                      blurRadius: 5,
                      spreadRadius: 0,
                      color: Color(0xFF00000040),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'L’Atelier du Chef\n',
                            style: GoogleFonts.ubuntu(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF02480F),
                            ),
                          ),
                          TextSpan(
                            text: 'BENGKEL SI KOKI',
                            style: GoogleFonts.ubuntu(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF02480F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => TambahResepBottomSheet(),
                            ).then((_) => _loadRecipes()); // refresh setelah tambah resep
                          },
                          icon: const Icon(Icons.add, size: 30, color: Color(0xFF02480F)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.menu, size: 30, color: Color(0xFF02480F)),
                          onSelected: (value) {
                            switch (value) {
                              case 'settings':
                                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                                break;
                              case 'exit':
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Login()));
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return OpsiMenu.opsiMenu.map((opsi) {
                              return PopupMenuItem<String>(
                                value: opsi.value,
                                child: ListTile(
                                  leading: Icon(opsi.icon),
                                  title: Text(opsi.title),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Center(
              child: SizedBox(
                width: 377,
                height: 62,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Cari Resep...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6767),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Color(0xFF58545429), width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  MenuCategoryButton(
                    category: MenuCategoryModel(
                      title: RecipeCategory.all,
                      image: 'sate.png',
                    ),
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) => setState(() => selectedCategory = category),
                  ),
                  const SizedBox(width: 12),
                  ...MenuCategoryModel.category.map(
                    ( category) => Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MenuCategoryButton(
                        category: category,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) => setState(() => selectedCategory = category),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title rekomendasi
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Recipe',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF524D4D),
                      shadows: [
                        Shadow(offset: Offset(0, 5), blurRadius: 5, color: Color(0xFF00000040)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),

            // Grid resep
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRecipes.isEmpty
                      ? const Center(child: Text('Tidak ada resep ditemukan'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            return FoodCard(recipe: filteredRecipes[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
