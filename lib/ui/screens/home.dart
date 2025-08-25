import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/ui/components/food_card.dart';
import 'package:resep/ui/components/menu_category_button.dart';
import 'package:resep/ui/models/menu_category.dart';
import 'package:resep/ui/models/recipe_model.dart';
import 'package:resep/ui/screens/bookmark.dart';
import 'package:resep/ui/screens/bottom_sheet.dart';
import 'package:resep/ui/models/opsi_menu.dart';
import 'package:resep/ui/screens/setting.dart';
import 'package:resep/ui/screens/login.dart';
import 'package:resep/ui/screens/profile_screen.dart';

import 'package:resep/services/service_makanan.dart'; // Import service untuk fetch dari Supabase


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RecipeCategory? selectedCategory = RecipeCategory.all;
  String searchQuery = '';
  final ServiceMakanan _serviceMakanan = ServiceMakanan(); // Instance service Supabase

  List<RecipeModel> allRecipes = []; // List untuk menyimpan resep dari database
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    _loadRecipes(); // Load data saat init
  }

  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    try {
      final recipes = await _serviceMakanan.fetchRecipes(selectedCategory?.name ?? 'all'); // Fetch dari Supabase
      setState(() {
        allRecipes = recipes;
      });
    } catch (e) {
      print("Error loading recipes: $e");
      // Optional: Tampilkan snackbar error jika diperlukan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat resep: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFACDDB5), Color(0xFFF6F6F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Konfirmasi Logout',
                style: GoogleFonts.ubuntu(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF02480F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Apakah Anda yakin ingin keluar?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF524D4D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Tidak',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF524D4D),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02480F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Ya',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter berdasarkan kategori dari data database (menggunakan enum langsung)
    final List<RecipeModel> displayedRecipes = selectedCategory == RecipeCategory.all
        ? allRecipes
        : allRecipes.where((recipe) => recipe.category == selectedCategory).toList();

    // Filter berdasarkan search query
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 5),
                      blurRadius: 5,
                      spreadRadius: 0,
                      color: const Color(0xFF00000040),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          icon: const Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFF02480F),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => TambahResepBottomSheet(),
                            ).then((_) {
                              _loadRecipes(); // Refresh data dari database setelah tambah resep
                            });
                          },
                          splashColor: const Color(0xFF48742C).withOpacity(0.4),
                          padding: const EdgeInsets.all(10),
                        ),
                        const SizedBox(width: 10),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.menu,
                            size: 30,
                            color: Color(0xFF02480F),
                          ),
                          color: const Color(0xFFF6F6F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color(0xFF6B6767),
                              width: 1,
                            ),
                          ),
                          elevation: 6,
                          splashRadius: 24,
                          offset: const Offset(0, 40),
                          onSelected: (value) async {
                            switch (value) {
                              case 'profile':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                                break;
                             case 'bookmark':
                                Navigator.push(
                                  context,  
                                  MaterialPageRoute(
                                    builder: (context) => const BookmarkScreen(),
                                  ),
                                );
                                break;
                             
                              case 'settings':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                                break;
                              case 'exit':
                                final shouldLogout = await _showLogoutConfirmationDialog(context);
                                if (shouldLogout == true) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                }
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return OpsiMenu.opsiMenu.map((opsi) {
                              return PopupMenuItem<String>(
                                value: opsi.value,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    opsi.icon,
                                    color: const Color(0xFF524D4D),
                                    size: 37,
                                  ),
                                  title: Text(
                                    opsi.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF524D4D),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
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
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Resep...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B6767),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 24,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xFF58545429),
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Category List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  MenuCategoryButton(
                    category: MenuCategoryModel(
                      title: RecipeCategory.all,
                      image: 'assets/sate.png',
                    ),
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ...MenuCategoryModel.category.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MenuCategoryButton(
                        category: category,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recommended Recipe Title
            
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
          color: const Color(0xFF524D4D),
          shadows: [
            Shadow(
              offset: Offset(0, 5),
              blurRadius: 5,
              color: Color(0xFF00000040),
            ),
          ],
        ),
      ),
      // ✅ tampilkan tombol hanya jika bukan ALL
      if (selectedCategory != RecipeCategory.all)
        TextButton(
          onPressed: () {
            setState(() {
              selectedCategory = RecipeCategory.all;
            });
          },
          child: const Text('See All'),
        ),
    ],
  ),
),

            // Recipe Grid
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