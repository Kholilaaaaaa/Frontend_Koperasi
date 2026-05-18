import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = "Budi Santoso".obs;
  var email = "budi.santoso@email.com".obs;
  var phone = "081234567890".obs;
  var address = "Jl. Sudirman No. 123, Jakarta".obs;
  var memberId = "#KS-B8291".obs;
  
  void saveProfile() {
    // Logic to save profile
    Get.back();
    Get.snackbar(
      'Sukses', 
      'Profil berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B0D0D),
      colorText: Colors.white,
    );
  }
}
