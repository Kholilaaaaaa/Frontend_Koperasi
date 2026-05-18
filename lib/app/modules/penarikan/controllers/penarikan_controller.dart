import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PenarikanController extends GetxController {
  final selectedSimpanan = 'Simpanan Sukarela'.obs;
  final nominalController = TextEditingController();
  final rekeningTujuanController = TextEditingController(text: 'Bank Central Asia • 8820****12');
  final alasanController = TextEditingController();

  final List<String> daftarSimpanan = [
    'Simpanan Sukarela',
    'Simpanan Pokok',
    'Simpanan Wajib',
  ];

  void submitPenarikan() {
    if (nominalController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Mohon masukkan nominal penarikan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Sukses',
      'Pengajuan penarikan sedang diproses',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    Get.back();
  }

  @override
  void onClose() {
    nominalController.dispose();
    rekeningTujuanController.dispose();
    alasanController.dispose();
    super.onClose();
  }
}
