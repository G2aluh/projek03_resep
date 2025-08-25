import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/ui/models/recipe_model.dart';
import 'package:resep/services/service_makanan.dart'; // Import service untuk handle bookmark
import 'package:supabase_flutter/supabase_flutter.dart'; // Import untuk akses auth

class DetailRecipePage extends StatefulWidget {
  const DetailRecipePage({Key? key, required this.recipe}) : super(key: key);

  final RecipeModel recipe;

  @override
  State<DetailRecipePage> createState() => _DetailRecipePageState();
}

class _DetailRecipePageState extends State<DetailRecipePage> {
  final ServiceMakanan _serviceMakanan = ServiceMakanan(); // Instance service Supabase
  final supabase = Supabase.instance.client; // Untuk akses user ID
  bool isBookmarked = false; // Status bookmark awal
  String userId = ''; // User ID

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id ?? '';
    if (userId.isNotEmpty) {
      _checkBookmarkStatus(); // Cek status bookmark saat init jika user login
    } else {
      // Optional: Handle jika user belum login, misal disable bookmark
      print('User belum login, bookmark dinonaktifkan');
    }
  }

  /// Fungsi untuk cek apakah resep sudah di-bookmark
  Future<void> _checkBookmarkStatus() async {
    final bookmarks = await _serviceMakanan.fetchBookmarks(userId);
    setState(() {
      isBookmarked = bookmarks.contains(widget.recipe.id);
    });
  }

  /// Fungsi untuk toggle bookmark
  Future<void> _toggleBookmark() async {
    if (userId.isEmpty) {
      // Optional: Tampilkan pesan jika user belum login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk bookmark resep')),
      );
      return;
    }

    setState(() {
      isBookmarked = !isBookmarked;
    });

    try {
      if (isBookmarked) {
        await _serviceMakanan.addBookmark(userId, widget.recipe.id);
      } else {
        await _serviceMakanan.removeBookmark(userId, widget.recipe.id);
      }
      // Note: Ini akan otomatis tercermin di home dan bookmark screen jika mereka fetch ulang data dari Supabase
      // Untuk sync real-time, pertimbangkan Supabase Realtime subscriptions di masa depan
    } catch (e) {
      // Rollback state jika gagal
      setState(() {
        isBookmarked = !isBookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE4EFDD), Color(0xFFF5F8F2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildRecipeHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(child: _buildBahanSection(context)),
                    SingleChildScrollView(child: _buildLangkahSection(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Widget untuk header dengan gambar, tombol kembali, dan tombol bookmark
  Widget _buildRecipeHeader(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'recipe_image_${widget.recipe.id}',
          child: _buildRecipeImage(widget.recipe.image),
        ),
        // Gradient overlay untuk membuat teks/ikon lebih jelas
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Tombol kembali
        Positioned(
          top: 40,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: Color(0xFF02480F), size: 30),
            ),
          ),
        ),
        // Tombol bookmark
        Positioned(
          top: 40,
          right: 16,
          child: GestureDetector(
            onTap: _toggleBookmark,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Color(0xFF02480F),
                size: 30,
              ),
            ),
          ),
        ),
        // Judul resep dan kategori di bawah gambar
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipe.title,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Text(
                widget.recipe.category.label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 212, 212, 212),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 Widget untuk load gambar dari URL atau asset
  Widget _buildRecipeImage(String path) {
    final isNetworkImage = path.startsWith('http');
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: isNetworkImage
          ? FadeInImage(
              placeholder: AssetImage('assets/images/default_food.png'),
              image: NetworkImage(path),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 300),
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/default_food.png',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              path,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
    );
  }

  /// 🔹 Widget untuk tab bar dengan animasi
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        tabs: [
          Tab(
            child: Text(
              "Bahan",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tab(
            child: Text(
              "Langkah",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF02480F), Color(0xFF48742C)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF48742C),
        indicatorPadding: EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(24),
      ),
    );
  }

  /// 🔹 Widget untuk section bahan-bahan
  Widget _buildBahanSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
      },
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bahan-bahan",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF02480F),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16),
            ...widget.recipe.ingredients.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${entry.key + 1}. ",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Color(0xFF48742C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget untuk section langkah-langkah
  Widget _buildLangkahSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
      },
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Langkah-langkah",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF02480F),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16),
            ...widget.recipe.steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${entry.key + 1}. ",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Color(0xFF48742C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}