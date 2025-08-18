import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show File; // Only used on mobile
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/service_makanan.dart';

class TambahResepBottomSheet extends StatefulWidget {
  const TambahResepBottomSheet({super.key});

  @override
  State<TambahResepBottomSheet> createState() => _TambahResepBottomSheetState();
}

class _TambahResepBottomSheetState extends State<TambahResepBottomSheet> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController langkahController = TextEditingController();

  final List<String> kategoriList = ['Appetizer', 'Main Course', 'Desert', 'Cake'];
  String? selectedKategori;
  XFile? selectedImage; // Use XFile instead of File

  final picker = ImagePicker();
  final serviceMakanan = ServiceMakanan();

  bool isLoading = false;

  Future<void> pilihGambar() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = picked;
      });
    }
  }

  Future<String?> uploadGambar(XFile file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      final path = 'makanan/$userId/$fileName';

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await Supabase.instance.client.storage
            .from('makanan')
            .uploadBinary(path, bytes);
      } else {
        await Supabase.instance.client.storage
            .from('makanan')
            .upload(path, File(file.path));
      }

      return Supabase.instance.client.storage
          .from('makanan')
          .getPublicUrl(path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengunggah gambar: $e")));
      debugPrint('Upload gagal: $e');
      return null;
    }
  }

  Future<void> simpanResep() async {
    if (selectedKategori == null ||
        namaController.text.isEmpty ||
        bahanController.text.isEmpty ||
        langkahController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl;
      if (selectedImage != null) {
        imageUrl = await uploadGambar(selectedImage!);
      }

      await serviceMakanan.tambahMakanan(
        kategori: selectedKategori!,
        nama: namaController.text,
        bahan: bahanController.text,
        langkah: langkahController.text,
        gambarUrl: imageUrl ?? '',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Makanan berhasil disimpan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan resep: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    bahanController.dispose();
    langkahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Resep Baru",
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF02480F),
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Color(0xFF00000040),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 202,
                  height: 194,
                  decoration: BoxDecoration(
                    color: Color(0xFFE4EFDD),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color(0xFF00000040),
                      ),
                    ],
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb
                              ? Image.network(
                                  selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: pilihGambar,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF02480F),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.add,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Kategori",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color(0xFF48742C),
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0xFF00000040),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 365,
            height: 55,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              hint: Text(
                "Pilih Kategori",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF48742C),
                ),
              ),
              value: selectedKategori,
              onChanged: (value) {
                setState(() {
                  selectedKategori = value;
                });
              },
              items: kategoriList.map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(
                    kategori,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF48742C),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          _buildTextField(namaController, "Nama Resep"),
          const SizedBox(height: 16),
          _buildTextField(bahanController, "Bahan-bahan"),
          const SizedBox(height: 16),
          _buildTextField(langkahController, "Langkah-langkah"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02480F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : simpanResep,
                  child: isLoading
                      ? const SizedBox(
                          width: 147,
                          height: 46,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF48742C),
                          ),
                        )
                      : Text(
                          "Simpan",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF48742C),
            shadows: [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Color(0xFF00000040),
              ),
            ],
          ),
        ),
        SizedBox(
            width: 365,
            height: 51,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Berikan Jawaban",
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF48742C),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        ),
      ],
    );
  }
}
