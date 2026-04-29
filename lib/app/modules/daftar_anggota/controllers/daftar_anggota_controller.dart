import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DaftarAnggotaController extends GetxController {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void nextStep() {
    // Logic for next step (step 2)
    Get.snackbar(
      'Informasi',
      'Lanjut ke tahap Verifikasi Dokumen',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
