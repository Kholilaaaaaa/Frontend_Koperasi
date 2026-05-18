import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pattern_getx_cli/app/network/api_client.dart';

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
  void onInit() {
    super.onInit();
    _googleSignIn.initialize(
      serverClientId: '441708388123-harti7pngma92cde3b7lun8m96erblln.apps.googleusercontent.com',
    );
  }

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

      final identity = emailOrPhoneController.text;
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/mobile-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': nameController.text,
          'identity': identity,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success']) {
        if (data['user'] != null && data['user']['id'] != null) {
          box.write('userId', data['user']['id']);
        }

        final registeredEmail = emailOrPhoneController.text;
        
        // Clear fields AFTER capturing identity
        nameController.clear();
        emailOrPhoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Get.snackbar(
          'Periksa Email',
          'Kode OTP telah dikirim ke email Anda untuk verifikasi.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Pindah ke VerificationPage
        Get.toNamed(Routes.VERIFICATION, arguments: {'email': registeredEmail});
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          data['error'] ?? 'Terjadi kesalahan saat mendaftar',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('DEBUG: Error saat signup: $e');
      Get.snackbar(
        'Error Koneksi',
        'Gagal terhubung ke server: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> signupWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Kirim idToken ke Flask
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google-mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': googleAuth.idToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'Sukses',
          'Berhasil mendaftar dengan akun Google: ${googleUser.displayName}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        box.write('isLoggedIn', true);
        box.write('loginType', 'email');
        box.write('userEmail', googleUser.email);
        
        if (data['user'] != null && data['user']['id'] != null) {
          box.write('userId', data['user']['id']);
        }
        
        // Cek status member dan navigasi
        await _checkMemberStatusAndRoute();
      } else {
        Get.snackbar(
          'Error Backend',
          'Gagal autentikasi di server: ${response.statusCode}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal daftar dengan Google: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _checkMemberStatusAndRoute() async {
    try {
      final userId = box.read('userId');
      if (userId == null) {
        Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/member/status/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] ?? 'not_started').toString().toLowerCase();
        print("DEBUG SIGNUP: Final Status check: $status");

        if (status == 'approved' || status == 'disetujui' || status == 'aktif' || status == 'acc' || status == 'diterima') {
          print("DEBUG SIGNUP: Status Approved -> Routes.MEMBER_DASHBOARD");
          Get.offAllNamed(Routes.MEMBER_DASHBOARD);
        } else if (status == 'pending' || status == 'menunggu') {
          print("DEBUG SIGNUP: Status Pending -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else if (status == 'rejected' || status == 'ditolak') {
          print("DEBUG SIGNUP: Status Rejected -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else {
          // Default for 'not_started' or unknown
          print("DEBUG SIGNUP: Status '$status' -> Routes.VISITOR_DASHBOARD");
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        }
      } else {
        print("DEBUG SIGNUP: Server error ${response.statusCode}. Fallback to VISITOR.");
        Get.offAllNamed(Routes.VISITOR_DASHBOARD);
      }
    } catch (e) {
      Get.offAllNamed(Routes.VISITOR_DASHBOARD);
    }
  }
}
