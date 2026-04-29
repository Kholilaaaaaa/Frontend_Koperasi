import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupController extends GetxController {
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final nameController = TextEditingController();
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final box = GetStorage();

  @override
  void onClose() {
    nameController.dispose();
    emailOrPhoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> signup() async {
    if (nameController.text.isEmpty ||
        emailOrPhoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua kolom harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.110.95:5000/api/auth/mobile-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': nameController.text,
          'identity': emailOrPhoneController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success']) {
        Get.snackbar(
          'Sukses',
          'Akun berhasil dibuat! Silakan masuk.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Clear fields
        nameController.clear();
        emailOrPhoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        // Navigate to login
        Get.offAllNamed(Routes.LOGIN);
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          data['error'] ?? 'Terjadi kesalahan saat mendaftar',
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

  Future<void> signupWithGoogle() async {
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

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'Sukses',
            'Berhasil daftar dengan akun Google: ${googleUser.displayName}',
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
        'Gagal daftar dengan Google: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
