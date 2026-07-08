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
  final isLoading = false.obs;

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
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> signup() async {
    if (isLoading.value) return;

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
      isLoading.value = true;
      final identity = emailOrPhoneController.text;
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/mobile-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': nameController.text,
          'identity': identity,
          'password': passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signupWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      isLoading.value = true;

      // Panggil endpoint BARU: register google → kirim OTP ke email Google
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google-register-mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': googleAuth.idToken ?? ''}),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        final email = data['email'] ?? googleUser.email;

        Get.snackbar(
          'Kode OTP Terkirim',
          'Kode verifikasi telah dikirim ke $email. Silakan cek inbox Anda.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Arahkan ke halaman Verifikasi OTP (sama seperti signup manual)
        Get.toNamed(Routes.VERIFICATION, arguments: {'email': email});

      } else if (response.statusCode == 409 && data['already_registered'] == true) {
        // Sudah terdaftar — arahkan ke Login
        Get.snackbar(
          'Sudah Terdaftar',
          'Akun Google ini sudah terdaftar. Silakan Login.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => Get.offNamed(Routes.LOGIN),
            child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );

      } else {
        Get.snackbar(
          'Signup Gagal',
          data['error'] ?? 'Terjadi kesalahan saat mendaftar dengan Google',
          backgroundColor: Colors.red,
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
    } finally {
      isLoading.value = false;
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
