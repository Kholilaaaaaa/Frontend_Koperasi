import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../network/api_client.dart';

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

  final isLoading = false.obs;

  Future<void> submitBukaSimpanan() async {
    if (nominalController.text.isEmpty || selectedBank.value == 'Pilih Bank Sumber') {
      Get.snackbar(
        'Error',
        'Mohon lengkapi semua data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      // Map jenis simpanan to ID (e.g., 1 for Wajib, 2 for Sukarela, 3 for Berjangka/Pokok)
      // For backend we assume 'SW' = 1, 'SS' = 2, 'SP' = 3 or use fixed IDs. 
      // It's better to pass saving_type_id=2 (Sukarela) for new deposits if not specified
      int savingTypeId = 2; // Default to Sukarela
      if (jenisSimpanan.value == 'Simpanan Berjangka') savingTypeId = 3;
      if (jenisSimpanan.value == 'Simpanan Hari Tua') savingTypeId = 2;
      
      final response = await authorizedPost('/api/member/deposit', {
        'amount': nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'saving_type_id': savingTypeId,
        'source_bank': selectedBank.value,
        'source_account_no': nomorRekeningController.text.isNotEmpty ? nomorRekeningController.text : '-',
      });

      final resData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && resData['success'] == true) {
        Get.snackbar(
          'Sukses',
          'Permohonan buka simpanan berhasil dikirim dan sedang diproses',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Gagal',
          resData['error'] ?? 'Terjadi kesalahan saat memproses permohonan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghubungi server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
