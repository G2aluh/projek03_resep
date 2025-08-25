import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resep/services/supabase_service.dart';
import 'package:resep/ui/screens/home.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.white70),
          errorStyle: const TextStyle(color: Colors.red),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 3),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 3),
          ),
        ),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6F6F6), Color(0xFFACDDB5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'L’Atelier du Chef\n',
                            style: GoogleFonts.ubuntu(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF02480F),
                            ),
                          ),
                          TextSpan(
                            text: 'BENGKEL SI KOKI',
                            style: GoogleFonts.ubuntu(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF02480F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Sudah siap memperkaya koleksi masakan di rumah?\nAyo, lihat semua resep yang kami sajikan dan temukan ide-ide baru untuk setiap waktu makanmu!',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF02480F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset(
                      'assets/logo.png',
                      width: 295,
                      height: 283,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    _AuthButton(
                      text: 'Create Account',
                      color: const Color(0xFF02480F),
                      textColor: const Color(0xFFFFFFFF),
                      onTap: () => _showAuthModal(context, isLogin: false),
                      width: 296,
                      height: 50,
                      borderRadius: 30,
                    ),
                    _AuthButton(
                      text: 'Login',
                      color: Colors.white,
                      textColor: const Color(0xFF02480F),
                      borderColor: const Color(0xFF02480F),
                      onTap: () => _showAuthModal(context, isLogin: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAuthModal(BuildContext context, {required bool isLogin}) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final nameController = TextEditingController();
    final bioController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: const Color(0xFFB6EDC0),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            passwordController.addListener(() {
              if (confirmPasswordController.text.isNotEmpty) setState(() {});
            });

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Login' : 'Create Account',
                        style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF02480F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _AuthTextField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'info@example.com',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Email tidak boleh kosong'
                            : !RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)
                            ? 'Format email tidak valid'
                            : null,
                      ),
                      if (!isLogin) ...[
                        const SizedBox(height: 20),
                        _AuthTextField(
                          controller: nameController,
                          label: 'Nama',
                          hint: 'Nama lengkap',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _AuthTextField(
                          controller: bioController,
                          label: 'Bio',
                          hint: 'Deskripsi singkat',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Bio tidak boleh kosong'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _AuthTextField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Password',
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Password tidak boleh kosong'
                            : value.length < 6
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      if (!isLogin) ...[
                        const SizedBox(height: 20),
                        _AuthTextField(
                          controller: confirmPasswordController,
                          label: 'Konfirmasi Password',
                          hint: 'Konfirmasi password',
                          obscureText: obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () => setState(
                              () => obscureConfirmPassword = !obscureConfirmPassword,
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Konfirmasi password tidak boleh kosong'
                              : value != passwordController.text
                              ? 'Password tidak cocok'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _AuthButton(
                        text: isLogin ? 'Login' : 'Register',
                        color: Colors.white,
                        textColor: const Color(0xFF02480F),
                        isLoading: isLoading,
                        onTap: isLoading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);
                                  try {
                                    final service = SupabaseService();
                                    if (isLogin) {
                                      await service.login(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    } else {
                                      await service.register(
                                        email: emailController.text,
                                        password: passwordController.text,
                                        name: nameController.text,
                                        bio: bioController.text,
                                      );
                                    }
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomeScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (isLogin &&
                                        (e.toString().contains('invalid credentials') ||
                                            e.toString().contains('Invalid login credentials'))) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'Login Gagal',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          content: Text(
                                            'Akun tidak ada atau kata sandi salah.',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 16,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'OK',
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 16,
                                                  color: const Color(0xFF02480F),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (!isLogin &&
                                        (e.toString().contains('email already exists') ||
                                            e.toString().contains('Email already registered'))) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'Registrasi Gagal',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          content: Text(
                                            'Akun sudah tersedia. Gunakan email lain atau login.',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 16,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'OK',
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 16,
                                                  color: const Color(0xFF02480F),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            isLogin ? 'Login Gagal' : 'Registrasi Gagal',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          content: Text(
                                            'Akun sudah tersedia silahkan gunakan email lain atau login.',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 16,
                                              color: const Color(0xFF02480F),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'OK',
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 16,
                                                  color: const Color(0xFF02480F),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  setState(() {});
                                }
                              },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin
                                ? 'Don’t have an account? '
                                : 'Already have account? ',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              color: Color(0xFF02480F),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _showAuthModal(context, isLogin: !isLogin);
                            },
                            child: const Text(
                              'Switch',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
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
          },
        );
      },
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final double borderRadius;

  const _AuthButton({
    required this.text,
    required this.color,
    required this.textColor,
    this.borderColor,
    this.isLoading = false,
    this.onTap,
    this.width = 296,
    this.height = 50,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 3)
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 5,
              spreadRadius: 0,
              color: Color(0xFF00000040),
            ),
          ],
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Color(0xFF02480F))
            : Text(
                text,
                style: GoogleFonts.ubuntu(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}