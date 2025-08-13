import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Register user dengan email/password, lalu insert data tambahan ke tabel profiles.
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

      // Insert data tambahan ke tabel profiles
      await _client.from('profiles').insert({
        'id': user.id,
        'name': name.trim(),
        'bio': bio.trim(),
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

  // Bisa tambahkan method lain nanti, seperti logout, getProfile, dll.
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}