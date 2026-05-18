import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pattern_getx_cli/app/network/api_client.dart';
import 'package:pattern_getx_cli/app/routes/app_routes.dart';
import 'dart:convert';
import 'dart:async';

class VerificationController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;
  final countdown = 60.obs;
  Timer? _timer;
  
  late String email;

  @override
  void onInit() {
    super.onInit();
    // Mendapatkan email dari arguments saat navigasi
    email = Get.arguments?['email'] ?? '';
    if (email.isEmpty) {
      Get.snackbar("Error", "Email tidak ditemukan. Silakan ulangi proses login/daftar.");
      Get.offAllNamed(Routes.LOGIN);
    } else {
      startTimer();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }

  Future<void> verifyOtp() async {
    final code = otpController.text.trim();
    if (code.isEmpty || code.length < 6) {
      Get.snackbar("Perhatian", "Masukkan 6 digit kode OTP", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp_code': code,
        }),
      ).timeout(const Duration(seconds: 30));

      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar("Sukses", "Akun berhasil diverifikasi, silakan login.", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Gagal", data['error'] ?? "Kode salah atau kadaluarsa", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      print('DEBUG VERIFY OTP: $e');
      Get.snackbar("Error", "Gagal terhubung ke server: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void startTimer() {
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (countdown.value > 0) return;

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      isLoading.value = false;
      if (response.statusCode == 200) {
        Get.snackbar("Info", "Kode baru telah dikirim ke email Anda.", backgroundColor: Colors.blue, colorText: Colors.white);
        startTimer();
      } else {
        Get.snackbar("Gagal", "Gagal mengirim ulang kode OTP.", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isLoading.value = false;
      print('DEBUG RESEND OTP: $e');
      Get.snackbar("Error", "Gagal terhubung ke server: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
