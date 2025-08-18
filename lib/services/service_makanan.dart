import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resep/ui/models/recipe_model.dart';

class ServiceMakanan {
  final supabase = Supabase.instance.client;

  Future<void> tambahMakanan({
    required String kategori,
    required String nama,
    required String bahan,
    required String langkah,
    String? gambarUrl,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login');

    await supabase.from('makanan').insert({
      'user_id': userId,
      'kategori': kategori,
      'nama': nama,
      'bahan': bahan,
      'langkah': langkah,
      'gambar_url': gambarUrl ?? '',
    });
  }

  /// Ambil semua makanan dari Supabase
 Future<List<RecipeModel>> fetchRecipes() async {
  try {
    final response = await supabase.from('makanan').select();
    return (response as List)
        .map((data) => RecipeModel.fromMap(data))
        .toList();
  } catch (e) {
    throw Exception('Gagal mengambil data makanan: $e');
  }
}


  /// Ambil daftar kategori unik
  Future<List<String>> fetchCategories() async {
    try {
      final response = await supabase
          .from('makanan')
          .select('kategori')
          .order('kategori', ascending: true);

      final kategoriUnik = <String>{};
      for (var item in response as List) {
        if (item['kategori'] != null) {
          kategoriUnik.add(item['kategori']);
        }
      }
      return kategoriUnik.toList();
    } catch (e) {
      throw Exception('Gagal mengambil kategori: $e');
    }
  }
}
