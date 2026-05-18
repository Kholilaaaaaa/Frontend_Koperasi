import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BukaSimpananController extends GetxController {
  final jenisSimpanan = 'Simpanan Berjangka'.obs;
  final nominalController = TextEditingController();
  final nomorRekeningController = TextEditingController();
  final selectedBank = 'Pilih Bank Sumber'.obs;

  final List<String> daftarSimpanan = [
    'Simpanan Berjangka',
    'Simpanan Sukarela',
    'Simpanan Hari Tua',
  ];

  final List<String> daftarBank = [
    'Pilih Bank Sumber',
    'Bank Mandiri',
    'Bank BNI',
    'Bank BRI',
    'Bank BCA',
  ];


  @override
  void onClose() {
    nominalController.dispose();
    nomorRekeningController.dispose();
    super.onClose();
  }

  void submitBukaSimpanan() {
    if (nominalController.text.isEmpty || selectedBank.value == 'Pilih Bank Sumber') {
      Get.snackbar(
        'Error',
        'Mohon lengkapi semua data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Logic to submit
    Get.snackbar(
      'Sukses',
      'Permohonan buka simpanan sedang diproses',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    Get.back();
  }
}
