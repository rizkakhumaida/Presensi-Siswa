import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final namaCtrl = TextEditingController();
  final nimNipCtrl = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    namaCtrl.dispose();
    nimNipCtrl.dispose();
    super.dispose();
  }

  Future<void> doRegister() async {
    FocusScope.of(context).unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();

    final result = await auth.register(
      emailCtrl.text.trim(),
      passCtrl.text,
      namaCtrl.text.trim(),
      nimNipCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi berhasil")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Icon(Icons.person_add, color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Register PresensiKu",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      "Buat akun presensi siswa",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            if (auth.error != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  auth.error!,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),

                            SizedBox(height: 12),

                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  _input(
                                    controller: namaCtrl,
                                    hint: "Nama Lengkap",
                                    icon: Icons.badge,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty ? "Nama wajib diisi" : null,
                                  ),
                                  SizedBox(height: 12),

                                  _input(
                                    controller: nimNipCtrl,
                                    hint: "NIM / NIP",
                                    icon: Icons.numbers,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty ? "NIM/NIP wajib diisi" : null,
                                  ),
                                  SizedBox(height: 12),

                                  _input(
                                    controller: emailCtrl,
                                    hint: "Email",
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Email wajib diisi";
                                      }
                                      if (!v.contains("@")) {
                                        return "Format email tidak valid";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 12),

                                  _input(
                                    controller: passCtrl,
                                    hint: "Password",
                                    icon: Icons.lock,
                                    obscureText: obscure,
                                    suffix: IconButton(
                                      icon: Icon(
                                        obscure ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => setState(() => obscure = !obscure),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return "Password wajib diisi";
                                      }
                                      if (v.length < 6) {
                                        return "Minimal 6 karakter";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1E40AF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: auth.isLoading ? null : doRegister,
                                child: auth.isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        "Register",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),

                            SizedBox(height: 10),

                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Sudah punya akun? Login",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
