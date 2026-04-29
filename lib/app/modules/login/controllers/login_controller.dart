import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends GetxController {
  final isPasswordVisible = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final box = GetStorage();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email/Telepon dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.110.95:5000/api/auth/mobile-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': emailController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        Get.snackbar(
          'Sukses',
          'Berhasil masuk! Selamat datang ${data['user']['full_name']}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        box.write('isLoggedIn', true);
        // Navigate to Visitor Dashboard
        Get.offAllNamed(Routes.VISITOR_DASHBOARD);
      } else {
        Get.snackbar(
          'Login Gagal',
          data['error'] ?? 'Terjadi kesalahan saat masuk',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Koneksi',
        'Gagal terhubung ke server: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Kirim idToken ke Flask
        final response = await http.post(
          Uri.parse('http://192.168.110.95:5000/api/auth/google-mobile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': googleAuth.idToken}),
        );

        if (response.statusCode == 200) {
          Get.snackbar(
            'Sukses',
            'Berhasil masuk dengan akun Google: ${googleUser.displayName}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          box.write('isLoggedIn', true);
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        } else {
          Get.snackbar(
            'Error Backend',
            'Gagal autentikasi di server: ${response.statusCode}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Gagal login dengan Google: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
