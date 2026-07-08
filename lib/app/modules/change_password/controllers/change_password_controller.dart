import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:pattern_getx_cli/app/network/api_client.dart';
import 'package:pattern_getx_cli/app/routes/app_routes.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final isOldPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final box = GetStorage();

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> submitChangePassword() async {
    if (oldPasswordController.text.isEmpty || 
        newPasswordController.text.isEmpty || 
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua kolom harus diisi', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Kata sandi baru tidak cocok dengan konfirmasi', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      final response = await authorizedPost('/api/auth/change-password', {
        'old_password': oldPasswordController.text,
        'new_password': newPasswordController.text,
      });

      Get.back(); // Close loading

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Hapus token JWT lama agar sesi tidak valid lagi
        await _secureStorage.delete(key: 'jwt_token');

        // Hapus data sesi login
        box.remove('isLoggedIn');
        box.remove('userId');
        box.remove('userName');
        box.remove('loginType');
        box.remove('userEmail');
        box.remove('userPhone');
        box.remove('memberId');
        box.remove('userAvatarPath');
        box.remove('userAddress');

        // Tampilkan pesan sukses & arahkan ke halaman login
        Get.snackbar(
          'Sukses', 
          'Kata sandi berhasil diubah. Silakan login kembali dengan sandi baru.', 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        );

        // Navigasi ke login dan hapus semua halaman sebelumnya
        Get.offAllNamed(Routes.LOGIN);
      } else {
        Get.snackbar(
          'Gagal', 
          data['error'] ?? data['message'] ?? 'Terjadi kesalahan saat mengubah kata sandi', 
          backgroundColor: Colors.red, 
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error', 
        'Gagal menghubungi server: $e', 
        backgroundColor: Colors.orange, 
        colorText: Colors.white,
      );
    }
  }
}

