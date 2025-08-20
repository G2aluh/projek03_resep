import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/services/service_makanan.dart'; // Import service
import 'package:resep/ui/models/recipe_model.dart';
import 'package:resep/ui/screens/detail_recipe_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import supabase untuk ambil user ID

class FoodCard extends StatefulWidget {
  const FoodCard({Key? key, required this.recipe});

  final RecipeModel recipe;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _isBookmarked = false;
  final ServiceMakanan _service = ServiceMakanan();

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
  }

  // Fungsi untuk cek apakah resep ini sudah dibookmark
  Future<void> _checkIfBookmarked() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      // Handle jika belum login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk bookmark')),
      );
      return;
    }

    final bookmarkedIds = await _service.fetchBookmarks(userId);
    setState(() {
      _isBookmarked = bookmarkedIds.contains(widget.recipe.id.toString());
    });
  }

  // Fungsi untuk toggle bookmark
  Future<void> _toggleBookmark() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk bookmark')),
      );
      return;
    }

    final recipeId = widget.recipe.id.toString();
    if (_isBookmarked) {
      await _service.removeBookmark(userId, recipeId);
    } else {
      await _service.addBookmark(userId, recipeId);
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRecipePage(recipe: widget.recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 180,
          height: 192,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 4)]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: (widget.recipe.image.startsWith('http'))
                    ? Image.network(
                        widget.recipe.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_food.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 80,
                          );
                        },
                      )
                    : Image.asset(
                        widget.recipe.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 80,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.recipe.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: _toggleBookmark, // Panggil fungsi toggle tanpa navigasi
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 37,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}