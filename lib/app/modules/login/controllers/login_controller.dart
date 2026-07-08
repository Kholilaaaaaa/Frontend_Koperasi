import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pattern_getx_cli/app/routes/app_routes.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';

class LoginController extends GetxController {
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  // Secure storage for JWT token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  Future<void> login() async {
    if (isLoading.value) return;

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
      isLoading.value = true;
      // print('DEBUG: Starting login request to $baseUrl/api/login');
          
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      // print('DEBUG: Response Status Code: ${response.statusCode}');
      // print('DEBUG: Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        Get.snackbar(
          'Sukses',
          'Berhasil masuk! Selamat datang ${data['user']['full_name']}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Store JWT token securely if provided
        // print("DEBUG LOGIN: Checking token in response: ${data['token']} or ${data['access_token']}");
        if (data['token'] != null) {
          await _secureStorage.write(key: 'jwt_token', value: data['token']);
        } else if (data['access_token'] != null) {
          await _secureStorage.write(key: 'jwt_token', value: data['access_token']);
        } else {
          // print("WARNING: No token or access_token received from backend upon login!");
        }
        // Store user identity
        final identity = emailController.text;
        if (identity.contains('@')) {
          box.write('loginType', 'email');
          box.write('userEmail', identity);
        } else {
          box.write('loginType', 'phone');
          box.write('userPhone', identity);
        }

        box.write('userId', data['user']['id']);
        box.write('userName', data['user']['full_name']);
        box.write('isLoggedIn', true);
        
        // Cek status member dan navigasi
        await _checkMemberStatusAndRoute();
      } else if (response.statusCode == 403 && data['needs_verification'] == true) {
        Get.snackbar(
          'Verifikasi Diperlukan',
          data['error'] ?? 'Silakan verifikasi email Anda terlebih dahulu.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Login Gagal',
          data['error'] ?? 'Terjadi kesalahan saat masuk',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // print('DEBUG: Error saat login: $e');
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

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      isLoading.value = true;

      // Panggil endpoint BARU yang hanya menerima user yang sudah terdaftar
      final response = await authorizedPost(
        '/api/auth/google-login-mobile',
        {'idToken': googleAuth.idToken ?? ''},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Login berhasil
        if (data['token'] != null) {
          await _secureStorage.write(key: 'jwt_token', value: data['token']);
        }
        box.write('isLoggedIn', true);
        box.write('loginType', 'email');
        box.write('userEmail', googleUser.email);
        if (data['user'] != null) {
          box.write('userId', data['user']['id']);
          box.write('userName', data['user']['full_name']);
        }
        Get.snackbar(
          'Berhasil',
          'Selamat datang, ${googleUser.displayName ?? 'Pengguna'}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _checkMemberStatusAndRoute();

      } else if (response.statusCode == 404 && data['needs_signup'] == true) {
        // Akun belum terdaftar — arahkan ke Signup
        Get.snackbar(
          'Belum Terdaftar',
          'Akun Google ini belum terdaftar. Silakan Signup terlebih dahulu.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => Get.offNamed(Routes.SIGNUP),
            child: const Text('Signup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );

      } else if (response.statusCode == 403 && data['needs_verification'] == true) {
        // Sudah daftar tapi belum verifikasi OTP
        final email = data['email'] ?? googleUser.email;
        Get.snackbar(
          'Verifikasi Diperlukan',
          'Akun Anda belum diverifikasi. Silakan selesaikan verifikasi OTP.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        Get.toNamed(Routes.VERIFICATION, arguments: {'email': email});

      } else {
        Get.snackbar(
          'Login Gagal',
          data['error'] ?? 'Terjadi kesalahan saat login dengan Google',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal login dengan Google: $e',
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

      final response = await authorizedGet('/api/member/status/$userId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] ?? 'not_started').toString().toLowerCase();
        // print("DEBUG LOGIN: Final Status check: $status");

        if (data['full_name'] != null) {
          box.write('userName', data['full_name']);
        }
        if (data['member_id'] != null) {
          box.write('memberId', data['member_id']);
        }
        if (data['avatar_path'] != null) {
          box.write('userAvatarPath', data['avatar_path']);
        }
        if (data['address'] != null) {
          box.write('userAddress', data['address']);
        }
        if (data['phone'] != null) {
          box.write('userPhone', data['phone']);
        }

        if (status == 'approved' || status == 'disetujui' || status == 'aktif' || status == 'acc' || status == 'diterima') {
          // print("DEBUG LOGIN: Status Approved -> Routes.MEMBER_DASHBOARD");
          Get.offAllNamed(Routes.MEMBER_DASHBOARD);
        } else if (status == 'pending' || status == 'menunggu') {
          // print("DEBUG LOGIN: Status Pending -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else if (status == 'rejected' || status == 'ditolak') {
          // print("DEBUG LOGIN: Status Rejected -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else {
          // Default for 'not_started' or unknown
          // print("DEBUG LOGIN: Status '$status' -> Routes.VISITOR_DASHBOARD");
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        }
      } else {
        // print("DEBUG LOGIN: Server error ${response.statusCode}. Fallback to VISITOR.");
        Get.offAllNamed(Routes.VISITOR_DASHBOARD);
      }
    } catch (e) {
      // print('DEBUG: Error checking member status: $e');
      Get.snackbar('Connection Error', 'Gagal cek status: $e');
      // Jika gagal cek status (misal timeout), arahkan ke visitor dashboard
      Get.offAllNamed(Routes.VISITOR_DASHBOARD);
    }
  }
}
