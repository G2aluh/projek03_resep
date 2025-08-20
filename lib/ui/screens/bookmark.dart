import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/services/service_makanan.dart'; // Service untuk fetch resep dan bookmark
import 'package:resep/ui/components/food_card.dart';
import 'package:resep/ui/models/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk ambil user ID

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ServiceMakanan _serviceMakanan = ServiceMakanan();
  List<RecipeModel> allRecipes = []; // Semua resep dari Supabase
  List<String> bookmarkedIds = []; // Daftar ID resep yang dibookmark
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk melihat bookmark')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      // Load semua resep dari Supabase
      allRecipes = await _serviceMakanan.fetchRecipes(userId);
      
      // Load bookmark IDs dari Supabase
      bookmarkedIds = await _serviceMakanan.fetchBookmarks(userId);
      
      setState(() {});
    } catch (e) {
      print("Error loading bookmarks: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat bookmark: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter resep yang dibookmark
    final List<RecipeModel> bookmarkedRecipes = allRecipes.where((recipe) {
      return bookmarkedIds.contains(recipe.id.toString());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmark',
          style: GoogleFonts.ubuntu(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF02480F),
          ),
        ),
        backgroundColor: const Color(0xFFACDDB5),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFACDDB5), Color(0xFFF6F6F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookmarkedRecipes.isEmpty
                ? const Center(child: Text('Tidak ada resep yang dibookmark'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: bookmarkedRecipes.length,
                    itemBuilder: (context, index) {
                      return FoodCard(recipe: bookmarkedRecipes[index]);
                    },
                  ),
      ),
    );
  }
}