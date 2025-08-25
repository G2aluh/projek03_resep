  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:resep/ui/components/food_card.dart';
  import 'package:resep/ui/models/recipe_model.dart';
  import 'package:resep/services/service_makanan.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:resep/services/supabase_service.dart';

  class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    final user = Supabase.instance.client.auth.currentUser;
    final ServiceMakanan _serviceMakanan = ServiceMakanan();
    final SupabaseService _supabaseService = SupabaseService();

    List<RecipeModel> userRecipes = [];
    bool isLoading = true;
    bool isUpdating = false;

    String? name;
    String? bio;
    String? photoUrl;

    @override
    void initState() {
      super.initState();
      print('Mencoba load aset: assets/profile_placeholder.png');
      _loadUserData();
      _loadUserRecipes();
    }

    Future<void> _loadUserData() async {
      if (user == null) return;
      try {
        final profileData = await _supabaseService.getProfile(user!.id);
        setState(() {
          name = profileData['name'] ?? "User";
          bio = profileData['bio'] ?? "Bio kosong, tambahkan deskripsi diri!";
          photoUrl = profileData['photo_url'];
        });
      } catch (e) {
        print("Error load profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    }

    Future<void> _loadUserRecipes() async {
      if (user == null) return;

      try {
        final recipes = await _serviceMakanan.fetchRecipesByUser(user!.id);
        setState(() {
          userRecipes = recipes;
        });
      } catch (e) {
        print("Error load user recipes: $e");
      } finally {
        setState(() => isLoading = false);
      }
    }

    Future<void> _uploadPhoto() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Atau ImageSource.camera
      if (pickedFile == null) return;

      setState(() => isUpdating = true);
      try {
        final file = File(pickedFile.path);
        final newUrl = await _supabaseService.uploadProfilePhoto(user!.id, file);
        setState(() {
          photoUrl = newUrl; // Update photoUrl untuk gantikan placeholder
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diupdate!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      } finally {
        setState(() => isUpdating = false);
      }
    }

    Future<void> _editProfile() async {
      final nameController = TextEditingController(text: name);
      final bioController = TextEditingController(text: bio);

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit Profil', style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                setState(() => isUpdating = true);
                try {
                  await _supabaseService.updateProfile(
                    user!.id,
                    name: nameController.text,
                    bio: bioController.text,
                  );
                  setState(() {
                    name = nameController.text;
                    bio = bioController.text;
                  });
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diupdate!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update profil: $e')),
                  );
                } finally {
                  setState(() => isUpdating = false);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );

      if (result == true) {
        _loadUserData();
      }
    }

    @override
    Widget build(BuildContext context) {
      if (user == null) {
        return Scaffold(
          body: Center(
            child: Text("Belum login", style: GoogleFonts.poppins(fontSize: 18)),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text("Profil Saya", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white)),
          backgroundColor: const Color(0xFF02480F),
          iconTheme: const IconThemeData(color: Colors.white), // ✅ Arrow back jadi putih
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white,),
              onPressed: isUpdating ? null : _editProfile,
            ),
          ],
        ),
        body: isUpdating
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _uploadPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                                      ? NetworkImage(photoUrl!) // Gunakan foto yang diupload
                                      : const AssetImage('assets/profile_placeholder.png')
                                          as ImageProvider,
                                  onBackgroundImageError: (error, stackTrace) {
                                    print('Gagal memuat gambar: $error');
                                  },
                                  child: photoUrl == null || photoUrl!.isEmpty
                                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                      : null,
                                ),
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Icon(Icons.camera_alt, color: Colors.black, size: 24),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name ?? "User",
                            style: GoogleFonts.ubuntu(fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                        
                          const SizedBox(height: 8),
                          Text(
                            bio ?? "Bio kosong",
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Resep Saya",
                        style: GoogleFonts.ubuntu(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : userRecipes.isEmpty
                            ? const Text("Belum ada resep yang dibuat")
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: userRecipes.length,
                                itemBuilder: (context, index) {
                                  return FoodCard(recipe: userRecipes[index]);
                                },
                              ),
                  ],
                ),
              ),
      );
    }
  }