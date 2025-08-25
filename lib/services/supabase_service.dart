import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Register user dengan email/password, lalu insert data tambahan ke tabel profile.
  /// Throw exception jika gagal.
  Future<String> register({
    required String email,
    required String password,
    required String name,
    required String bio,
  }) async {
    try {
      // Sign up dengan email dan password
      final authResponse = await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Gagal membuat akun: User null');
      }

      // Insert data tambahan ke tabel profile (photo_url default null)
      await _client.from('profile').insert({
        'id': user.id,
        'name': name.trim(),
        'bio': bio.trim(),
        'photo_url': null,
      });

      return user.id; // Return user ID jika sukses
    } catch (e) {
      throw Exception('Error register: $e');
    }
  }

  /// Login dengan email/password.
  /// Throw exception jika gagal.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in dengan email dan password
      final authResponse = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Gagal login: User null');
      }

      return user.id; // Return user ID jika sukses
    } catch (e) {
      throw Exception('Error login: $e');
    }
  }

  /// Logout user.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Fetch data profile dari tabel profile berdasarkan user ID.
  /// Return map dengan name, bio, photo_url.
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await _client.from('profile').select('name, bio, photo_url').eq('id', userId).single();

      if (response.isEmpty) {
        throw Exception('Profile tidak ditemukan');
      }

      return response;
    } catch (e) {
      throw Exception('Error fetch profile: $e');
    }
  }

  /// Update profile (name, bio, atau photo_url) di tabel profile.
  /// Field yang null tidak diupdate.
  Future<void> updateProfile(
    String userId, {
    String? name,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (bio != null) updates['bio'] = bio.trim();
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      if (updates.isEmpty) return; // Tidak ada yang diupdate

      await _client.from('profile').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Error update profile: $e');
    }
  }

  /// Upload foto profil ke Storage, lalu update photo_url di profile.
  /// Return public URL foto baru.
  Future<String> uploadProfilePhoto(String userId, File file) async {
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      // Upload file dan dapatkan path response (String)
      await _client.storage.from('profile_photos').upload(fileName, file);

      // Dapatkan public URL
      final publicUrl = _client.storage.from('profile_photos').getPublicUrl(fileName);

      // Update photo_url di profile
      await updateProfile(userId, photoUrl: publicUrl);

      return publicUrl;
    } on StorageException catch (e) {
      throw Exception('Gagal upload foto: ${e.message}');
    } catch (e) {
      throw Exception('Error upload foto: $e');
    }
  }
}