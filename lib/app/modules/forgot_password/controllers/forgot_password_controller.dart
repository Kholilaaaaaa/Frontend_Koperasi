import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:pattern_getx_cli/app/network/api_client.dart';
import 'package:pattern_getx_cli/app/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final step = 1.obs; // 1 = Request OTP, 2 = Verify OTP, 3 = Reset Password
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> sendOtp() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      final response = await authorizedPost('/api/forgot-password/send-otp', {
        'email': emailController.text.trim(),
      });

      Get.back(); // Close loading dialog

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        step.value = 2; // Move to Verify OTP step
        Get.snackbar(
          'Sukses',
          data['message'] ?? 'Kode OTP telah dikirim ke email Anda.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['error'] ?? 'Gagal mengirim kode OTP.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal menghubungi server: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Kode OTP harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      final response = await authorizedPost('/api/forgot-password/verify-otp', {
        'email': emailController.text.trim(),
        'otp_code': otpController.text.trim(),
      });

      Get.back(); // Close loading dialog

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        step.value = 3; // Move to Reset Password step
        Get.snackbar(
          'Sukses',
          'Kode OTP berhasil diverifikasi.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['error'] ?? 'Kode OTP salah atau sudah kadaluarsa.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal menghubungi server: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua kolom password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Kata sandi minimal 8 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      final response = await authorizedPost('/api/forgot-password/reset', {
        'email': emailController.text.trim(),
        'otp_code': otpController.text.trim(),
        'new_password': newPasswordController.text.trim(),
      });

      Get.back(); // Close loading dialog

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar(
          'Sukses',
          data['message'] ?? 'Kata sandi berhasil diubah.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        // Redirect to Login
        Get.offAllNamed(Routes.LOGIN);
      } else if (data['error_code'] == 'SAME_PASSWORD') {
        // Tampilkan modal keterangan bahwa sandi tidak boleh sama
        _showSamePasswordModal();
      } else {
        Get.snackbar(
          'Gagal',
          data['error'] ?? 'Gagal mereset kata sandi.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Gagal menghubungi server: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _showSamePasswordModal() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Peringatan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B0D0D)),
            ),
          ],
        ),
        content: const Text(
          'Kata sandi baru tidak boleh sama dengan kata sandi sebelumnya. Silakan gunakan kata sandi yang berbeda.',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B0D0D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
