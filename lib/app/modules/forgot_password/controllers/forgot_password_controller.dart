import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void sendResetLink() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Simulate sending reset link
    Get.snackbar(
      'Sukses',
      'Link reset password telah dikirim ke email Anda',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }
}
